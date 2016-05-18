defmodule Appointments.LayoutView do
  use Appointments.Web, :view

  def active?(conn, path) do
    if conn.request_path == "/#{path}", do: "active", else: ''
  end
end
