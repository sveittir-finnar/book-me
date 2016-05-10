defmodule Appointments.PageControllerTest do
  use Appointments.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "book.me"
  end
end
