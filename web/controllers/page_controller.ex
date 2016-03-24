defmodule Appointments.PageController do
  use Appointments.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
