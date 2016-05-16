defmodule Appointments.PageControllerTest do
  use Appointments.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "book.me"
  end

  test "registration should work for valid attributes", %{conn: conn} do
    conn = post conn, page_path(conn, :registration_post), reg: %{
      "company_name" => "zlash inc", "company_slug" => "zlash",
      "first_name" => "Hrafn", "last_name" => "Eiríksson",
      "email" => "hrafne@gmail.com"
    }
    #assert html_response(conn, 200) =~ "New company"
  end
end
