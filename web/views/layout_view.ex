defmodule Appointments.LayoutView do
  use Appointments.Web, :view

  def active?(conn, path) do
    [_ | [resource | _]] = String.split(conn.request_path, "/")
    if resource == path, do: "active", else: ''
  end
end
