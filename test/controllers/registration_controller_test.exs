defmodule Appointments.RegistrationControllerTest do
  use Appointments.ConnCase

  @valid_company %{"name": "dawg inc"}
  @valid_employee %{
    "first_name" => "Aron",
    "last_name" => "Edvardsson",
    "email" => "aron@edvarsson.com"
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "should fail when company data is missing", %{conn: conn} do
    conn = post(conn, registration_path(conn, :registration_post), %{
      company: %{name: "s"}, # too short name
      employee: @valid_employee
    })
    assert json_response(conn, :unprocessable_entity)
  end

  test "should fail when employee data is missing", %{conn: conn} do
    conn = post(conn, registration_path(conn, :registration_post), %{
      company: @valid_company,
      employee: %{"first_name" => "Aron"}
    })
    assert json_response(conn, :unprocessable_entity)
  end

  test "should fail when email is already in use", %{conn: conn} do
    company = insert(:company)
    employee = insert(:employee, company_id: company.id)
    conn = post(conn, registration_path(conn, :registration_post), %{
      company: @valid_company,
      employee: %{@valid_employee | "email" => employee.email}
    })
    assert json_response(conn, :unprocessable_entity)
  end

  test "should be successful for valid payloads", %{conn: conn} do
    conn = post(conn, registration_path(conn, :registration_post), %{
      company: @valid_company,
      employee: @valid_employee
    })
    assert json_response(conn, :created)
  end
end
