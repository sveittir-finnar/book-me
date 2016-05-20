defmodule Appointments.RegistrationControllerTest do
  use Appointments.ConnCase
  alias Appointments.{Company, Employee}

  @valid_company %{name: "dawg inc"}
  @valid_employee %{
    first_name: "Aron",
    last_name: "Edvardsson",
    email: "aron@edvarsson.com",
    password: "passwd",
    password_confirmation: "passwd"
  }

  # Validation error helper
  def has_validation_error(conn, model, key) do
    res = json_response(conn, :unprocessable_entity)
    case Enum.find(res, &(Map.has_key?(&1, model))) do
      nil -> false
      map ->
        errors = Map.get(map, model)
        (Map.has_key?(errors, key) && Enum.count(Map.get(errors, key)) > 0)
    end
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "should fail when company data is missing", %{conn: conn} do
    conn = post(conn, registration_path(conn, :registration_post), %{
      company: %{name: ""}, # too short name
      employee: @valid_employee
    })
    assert has_validation_error(conn, "company", "name")
  end

  test "should fail when employee data is missing", %{conn: conn} do
    conn = post(conn, registration_path(conn, :registration_post), %{
      company: @valid_company,
      employee: %{"first_name" => "Aron"}
    })
    assert json_response(conn, :unprocessable_entity)

    # Also test whether the company exists; that should not happen since
    # the transaction that created the company should've been rolled back
    refute Repo.get_by(Company, @valid_company)
  end

  test "should fail when email is already in use", %{conn: conn} do
    company = insert(:company)
    employee = insert(:employee, company_id: company.id)
    conn = post(conn, registration_path(conn, :registration_post), %{
      company: @valid_company,
      employee: %{@valid_employee | email: employee.email}
    })
    assert has_validation_error(conn, "employee", "email")
  end

  test "should ignore the case of emails", %{conn: conn} do
    company = insert(:company)
    employee = insert(:employee, company_id: company.id)
    conn = post(conn, registration_path(conn, :registration_post), %{
      company: @valid_company,
      employee: %{@valid_employee | email: String.upcase(employee.email)}
    })
    assert has_validation_error(conn, "employee", "email")
  end

  test "should not allow too short passwords", %{conn: conn} do
    conn = post(conn, registration_path(conn, :registration_post), %{
      company: @valid_company,
      employee: Map.merge(@valid_employee, %{
        "password" => "abc", "password_confirmation" => "abc"
      })
    })
    assert has_validation_error(conn, "employee", "password")
  end

  test "should be successful for valid payloads", %{conn: conn} do
    conn = post(conn, registration_path(conn, :registration_post), %{
      company: @valid_company,
      employee: @valid_employee
    })
    assert json_response(conn, :created)
    assert Repo.get_by(Company, @valid_company)
  end
end
