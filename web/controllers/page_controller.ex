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
    user = Map.take(user, [:id, :name, :role, :company_id, uniq])
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

  def registration(conn, params) do
    render conn, "registration.html"
  end

  def registration_post(conn, %{"reg" => registration_params}) do
      company_changeset = Company.changeset(%Company{}, %{
        name: registration_params["company_name"]
      })
      employee_changeset = Employee.changeset(%Employee{}, %{
        name: registration_params["first_name"] <> registration_params["last_name"],
        email: registration_params["email"],
        role: "full"
      })

      Repo.transaction fn ->
        company = Repo.insert!(company_changeset)
        employee = Ecto.build_assoc(company, :employees, employee_changeset)
        Repo.insert!(employee)
      end
      conn
      |> redirect(to: page_path(conn, :index))
    else
      IO.inspect(changeset)
      conn
      |> put_flash(:info, "Please correct the following errors in your form.")
      render(conn, "registration.html", changeset: changeset)
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
