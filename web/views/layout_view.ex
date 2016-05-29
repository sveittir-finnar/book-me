defmodule Appointments.LayoutView do
  use Appointments.Web, :view

  def active?(conn, path) do
    resource = String.split(conn.request_path, "/") |> Enum.at(1)
    if resource == path, do: "active", else: ""
  end
end
