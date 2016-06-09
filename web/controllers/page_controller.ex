defmodule Appointments.PageController do
  use Appointments.Web, :controller

  import Appointments.{Authorize, Confirm}
  alias Appointments.{Employee, Reservation}

  # Authentication

  # TODO(krummi): Revisit this when I know something
  def action(conn, _) do
    case action_name(conn) do
      :calendar -> authorize_action(conn, __MODULE__)
      action -> apply(__MODULE__, action, [conn, conn.params])
    end
  end

  # TODO(krummi): Send this as an email
  def receipt_confirm(email) do
    IO.puts("confirming: #{email}")
  end

  plug Openmaize.ConfirmEmail, [
    key_expires_after: 30,
    mail_function: &__MODULE__.receipt_confirm/1
  ] when action in [:confirm]

  plug Openmaize.ResetPassword, [
    key_expires_after: 30,
    mail_function: &__MODULE__.receipt_confirm/1
  ] when action in [:reset_password]

  plug Openmaize.Login, [
    unique_id: :email,
    add_jwt: &Appointments.JWT.add_token/3
  ] when action in [:login_user]

  plug Openmaize.Logout when action in [:logout]

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def login_user(conn, params) do
    handle_login(conn, params)
  end

  def logout(conn, params) do
    handle_logout(conn, params)
  end

  def confirm(conn, params) do
    handle_confirm(conn, params)
  end

  def askreset(conn, _params) do
    render(conn, "reset.html")
  end

  def calendar(conn, params, user) do
    %Plug.Conn{req_cookies: %{"access_token" => access_token}} = conn
    access_token = conn.req_cookies["access_token"]
    render(conn, "calendar.html", access_token: access_token)
  end

  def send_an_email(email, link) do
    IO.puts("sending an reset password email: #{email}, link: #{link}")
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
    render(conn, "resetting.html", email: email, key: key)
  end

  def reset_password(conn, params) do
    handle_reset(conn, params)
  end
end
