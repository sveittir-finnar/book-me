defmodule Appointments.PageController do
  use Appointments.Web, :controller

  import Appointments.{Authorize, Confirm}
  alias Appointments.{Company, Employee}

  # TODO(krummi): Send this as an email
  def receipt_confirm(email) do
    IO.puts("confirming: #{email}")
  end

  # Taken from: https://github.com/riverrun/openmaizejwt/blob/master/lib/openmaize_jwt/plug.ex
  import OpenmaizeJWT.Create
  def add_token(conn, user, {storage, uniq}) do
    company = Repo.get!(Appointments.Company, user.company_id)
    user = Map.take(user, [:id, :first_name, :role, :company_id, uniq])
    |> Map.put(:company_name, company.name)
    # TODO(krummi): Make 120 a configuration option.
    {:ok, token} = generate_token user, {0, 120}
    put_token(conn, user, token, storage)
  end
  defp put_token(conn, user, token, :cookie) do
    put_resp_cookie(conn, "access_token", token, [http_only: true])
    |> put_private(:openmaize_user, user)
  end
  defp put_token(conn, user, token, nil) do
    resp(conn, 200, ~s({"access_token": "#{token}"}))
    |> put_private(:openmaize_user, user)
  end

  plug Openmaize.ConfirmEmail, [key_expires_after: 30,
    mail_function: &Appointments.PageController.receipt_confirm/1] when action in [:confirm]
  plug Openmaize.ResetPassword, [key_expires_after: 30,
    mail_function: &Appointments.PageController.receipt_confirm/1] when action in [:reset_password]

  plug Openmaize.Login, [
    unique_id: :email,
    add_jwt: &Appointments.PageController.add_token/3
  ] when action in [:login_user]
  plug Openmaize.Logout when action in [:logout]

  def send_an_email(email, link) do
    IO.puts("sending an reset password email: #{email}, link: #{link}")
  end

  def index(conn, _params) do
    render conn, "index.html"
  end

  def login(conn, _params) do
    render conn, "login.html"
  end

  def registration(conn, _params) do
    render conn, "registration.html"
  end

  defp registration_err(conn, changesets) do
    conn
    |> put_status(:unprocessable_entity)
    |> render(Appointments.ChangesetView, "error.json", errors: changesets)
  end

  def registration_post(conn, %{"employee" => employee_params, "company" => company_params}) do
    employee_params = Map.put(employee_params, "role", "full")
    # HACK: Set this temporarily so the company_id validation will not trigger
    employee_params = Map.put(employee_params, "company_id", -1)

    company_changeset = Company.changeset(%Company{}, company_params)
    employee_changeset = Employee.changeset(%Employee{}, employee_params)

    if company_changeset.valid? && employee_changeset.valid? do
      # TODO(krummi): Use Ecto.Multi when we start using Ecto 2.0
      #               See: https://github.com/elixir-lang/ecto/issues/1114
      case Repo.transaction fn ->
        case Repo.insert(company_changeset) do
          {:ok, company} ->
            employee_changeset = Ecto.Changeset.put_change(employee_changeset, :company_id, company.id)
            case Repo.insert(employee_changeset) do
              {:ok, employee} -> employee
              {:error, changeset} -> Repo.rollback(%{employee: changeset, company: company_changeset})
            end
          {:error, changeset} ->
            Repo.rollback(%{employee: employee_changeset, company: changeset})
        end
      end do
        {:ok, _} ->
          conn |> put_status(:created) |> render(Appointments.ShowView, "show.json", res: "good")
        {:error, changesets} -> registration_err(conn, changesets)
      end
    else
      registration_err(conn, %{employee: employee_changeset, company: company_changeset})
    end
  end

  def login_user(conn, params) do
    handle_login conn, params
  end

  def logout(conn, params) do
    handle_logout conn, params
  end

  def confirm(conn, params) do
    handle_confirm conn, params
  end

  def askreset(conn, _params) do
    render conn, "reset.html"
  end

  def askreset_password(conn, %{"employee" => %{"email" => email} = user_params}) do
    {key, link} = Openmaize.ConfirmEmail.gen_token_link(email)
    changeset = Employee.reset_changeset(Repo.get_by(Employee, email: email), user_params, key)

    case Repo.update(changeset) do
      {:ok, _user} ->
        send_an_email(email, link) # TODO(krummi): Actually send an email.
        conn
        |> put_flash(:info, "Check your inbox for instructions on how to reset your password.")
        |> redirect(to: page_path(conn, :index))
      {:error, changeset} ->
        render(conn, "index.html", changeset: changeset)
    end
  end

  def reset(conn, %{"email" => email, "key" => key}) do
    render conn, "resetting.html", email: email, key: key
  end

  def reset_password(conn, params) do
    handle_reset conn, params
  end
end
