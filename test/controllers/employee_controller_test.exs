defmodule Appointments.EmployeeControllerTest do
  use Appointments.ConnCase
  alias Appointments.{Repo, Employee, Company}

  @valid_attrs %{ email: "david@bowie.com", name: "David Bowie", role: "restricted" }
  @invalid_attrs %{ }

  import OpenmaizeJWT.Create

  setup do
    # TODO(krummi): Use https://github.com/thoughtbot/ex_machina
    company = Repo.insert! %Company{name: "The Test Company!"}

    employee_params = %{
      email: "paolo@gmail.com",
      name: "Paolo Maldini",
      role: "full",
      password: "acmilan",
      company_id: company.id
    }

    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
    employee = %Employee{}
    |> Employee.auth_changeset(employee_params, key)
    |> Employee.reset_changeset(employee_params, key)
    |> Repo.insert!

    {:ok, user_token} = %{
      id: employee.id, email: "paolo@gmail.com", role: "full",
      name: "p", company_id: 1, company_name: "hehe"
    }
    |> generate_token({ 0, 86400 })

    conn = conn()
    |> put_req_cookie("access_token", user_token)
    {:ok, conn: conn, user_token: user_token, company: company}
  end

  # TODO(krummi): fix
  #test "renders form for new resources", %{conn: conn} do
  #  conn = get conn, employee_path(conn, :new)
  #  assert html_response(conn, 200) =~ "New employee"
  #end

  test "creates resource and redirects when data is valid", %{conn: conn, company: company} do
    employee = Map.put(@valid_attrs, :company_id, company.id)
    conn = post conn, employee_path(conn, :create), employee: employee
    assert redirected_to(conn) == employee_path(conn, :index)
    assert Repo.get_by(Employee, @valid_attrs)
  end

  # TODO(krummi): fix
  #test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #  conn = post conn, employee_path(conn, :create), employee: @invalid_attrs
  #  assert html_response(conn, 200) =~ "New employee"
  #end

  test "shows chosen resource", %{conn: conn, company: company} do
    employee = Repo.insert! %Employee{
      email: "ari@gmail.com", name: "ari", role: "full", company_id: company.id
    }
    conn = get conn, employee_path(conn, :show, employee)
    assert html_response(conn, 200) =~ "Show employee"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, employee_path(conn, :show, -1)
    end
  end

  # TODO(krummi): fix
  #test "renders form for editing chosen resource", %{conn: conn} do
  #  employee = Repo.insert! %Employee{}
  #  conn = get conn, employee_path(conn, :edit, employee)
  #  assert html_response(conn, 200) =~ "Edit employee"
  #end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, company: company} do
    employee = Repo.insert! %Employee{
      email: "ari@gmail.com", name: "ari", role: "full", company_id: company.id
    }
    conn = put conn, employee_path(conn, :update, employee), employee: @valid_attrs
    assert redirected_to(conn) == employee_path(conn, :show, employee)
    assert Repo.get_by(Employee, @valid_attrs)
  end

  # TODO(krummi): fix
  #test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #  employee = Repo.insert! %Employee{}
  #  conn = put conn, employee_path(conn, :update, employee), employee: @invalid_attrs
  #  assert html_response(conn, 200) =~ "Edit employee"
  #end

  test "deletes chosen resource", %{conn: conn, company: company} do
    employee = Repo.insert! %Employee{
      email: "ari@gmail.com", name: "ari", role: "full", company_id: company.id
    }
    conn = delete conn, employee_path(conn, :delete, employee)
    assert redirected_to(conn) == employee_path(conn, :index)
    refute Repo.get(Employee, employee.id)
  end

end
