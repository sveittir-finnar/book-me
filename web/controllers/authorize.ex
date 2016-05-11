defmodule Appointments.Authorize do

  import Plug.Conn
  import Phoenix.Controller

  @doc """
  Custom action that can be used to override the `action` function in any
  Phoenix controller.

  ## Examples

  First, import this module in the controller, and then add the following line:

      def action(conn, _), do: authorize_action conn, __MODULE__

  You will also need to change the other functions in the controller to accept
  a third argument, which is the current user. For example, change:
  `def index(conn, params) do` to: `def index(conn, params, user) do`
  """
  def authorize_action(%Plug.Conn{assigns: %{current_user: nil}} = conn, _, _) do
    unauthenticated conn
  end
  def authorize_action(%Plug.Conn{assigns: %{current_user: current_user},
                                  params: params} = conn, _roles, module) do
    apply(module, action_name(conn), [conn, params, current_user])
  end

  @doc """
  Redirect an unauthenticated user to the login page.
  """
  def unauthenticated(conn, message \\ "You need to log in to view this page") do
    conn |> put_flash(:error, message) |> redirect(to: "/login") |> halt
  end

  @doc """
  Redirect an unauthorized user to that user's role's page.
  """
  def unauthorized(conn, _current_user, message \\ "You are not authorized to view this page") do
    conn |> put_flash(:error, message) |> redirect(to: "/") |> halt
  end

  @doc """
  Login and redirect to the user's role's page if successful.

  ## Examples

  Add the following line to the controller which handles login:

      plug Openmaize.Login when action in [:login_user]

  and then call `handle_login` from the `login_user` function:

      def login_user(conn, params), do: handle_login(conn, params)

  See the documentation for Openmaize.Login for all the login options.

  ## Two factor authentication

  This function can also be used for two factor authentication for any
  user with `otp_required` set to true.
  """
  def handle_login(%Plug.Conn{private: %{openmaize_error: message}} = conn, _params) do
    unauthenticated conn, message
  end
  def handle_login(%Plug.Conn{} = conn, _params) do
    conn |> put_flash(:info, "You have been logged in") |> redirect(to: "/")
  end

  @doc """
  Logout and redirect to the home page.

  ## Examples

  Add the following line to the controller which handles logout:

      plug Openmaize.Logout when action in [:logout]

  and then call `handle_logout` from the `logout` function in the
  controller.
  """
  def handle_logout(%Plug.Conn{private: %{openmaize_info: message}} = conn, _params) do
    conn |> put_flash(:info, message) |> redirect(to: "/")
  end
end
