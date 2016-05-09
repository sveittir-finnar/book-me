defmodule Appointments.EmployeeControllerTest do
  use Appointments.ConnCase

  alias Appointments.Employee
  @valid_attrs %{avatar_url: "some content", bio: "some content", email: "some content", name: "some content", phone: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, employee_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing employees"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, employee_path(conn, :new)
    assert html_response(conn, 200) =~ "New employee"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, employee_path(conn, :create), employee: @valid_attrs
    assert redirected_to(conn) == employee_path(conn, :index)
    assert Repo.get_by(Employee, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, employee_path(conn, :create), employee: @invalid_attrs
    assert html_response(conn, 200) =~ "New employee"
  end

  test "shows chosen resource", %{conn: conn} do
    employee = Repo.insert! %Employee{}
    conn = get conn, employee_path(conn, :show, employee)
    assert html_response(conn, 200) =~ "Show employee"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, employee_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    employee = Repo.insert! %Employee{}
    conn = get conn, employee_path(conn, :edit, employee)
    assert html_response(conn, 200) =~ "Edit employee"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    employee = Repo.insert! %Employee{}
    conn = put conn, employee_path(conn, :update, employee), employee: @valid_attrs
    assert redirected_to(conn) == employee_path(conn, :show, employee)
    assert Repo.get_by(Employee, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    employee = Repo.insert! %Employee{}
    conn = put conn, employee_path(conn, :update, employee), employee: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit employee"
  end

  test "deletes chosen resource", %{conn: conn} do
    employee = Repo.insert! %Employee{}
    conn = delete conn, employee_path(conn, :delete, employee)
    assert redirected_to(conn) == employee_path(conn, :index)
    refute Repo.get(Employee, employee.id)
  end
end
