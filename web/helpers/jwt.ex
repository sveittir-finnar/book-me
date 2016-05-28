defmodule Appointments.JWT do
  use Phoenix.Controller

  import OpenmaizeJWT.Create
  alias Appointments.{Company, Repo}

  # Based on: https://github.com/riverrun/openmaizejwt/blob/master/lib/openmaize_jwt/plug.ex
  def create_token(user, uniq) do
    company = Repo.get!(Company, user.company_id)
    user = Map.take(user, [:id, :first_name, :role, :company_id, uniq])
    |> Map.put(:company_name, company.name)
    # TODO(krummi): Make 120 a configuration option.
    generate_token(user, {0, 120})
  end

  def add_token(conn, user, {storage, uniq}) do
    {:ok, token} = create_token(user, uniq)
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

end
