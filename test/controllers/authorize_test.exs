defmodule Appointments.AuthorizeTest do
  use Appointments.ConnCase
  alias Appointments.{Repo, Employee, Company}

  import Openmaize.DB
  import OpenmaizeJWT.Create

  @valid_attrs %{email: "matt@damon.com", password: "burrito"}
  @invalid_attrs %{email: "matt@damon.com", password: "wrong-password"}
  @nonexisting_attrs %{email: "matt@daemon.org", password: "enchillada"}

  # A helper to create an authenticated connection
  def auth_conn, do: auth_conn(0)
  def auth_conn(id) do
    # Creates a token for Matt
    {:ok, user_token} = %{
      id: id,
      email: "matt@damon.com",
      role: "full",
      first_name: "Matt",
      last_name: "Damon",
      company_name: "Test",
      company_id: 1}
    |> generate_token({0, 86400})

    conn() |> put_req_cookie("access_token", user_token)
  end

  setup do
    company = Repo.insert! %Company{name: "The Test Company!"}

    employees = [
      %{email: "matt@damon.com",
        first_name: "Matt",
        last_name: "Damon",
        role: "full",
        password: "burrito",
        company_id: company.id},
      %{email: "jennifer@lopez.com",
        first_name: "Jennifer",
        last_name: "Lopez",
        role: "self",
        password: "tacotaco",
        company_id: company.id}
    ]

    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
    new_employees = for employee <- employees do
      %Employee{}
      |> Employee.auth_changeset(employee, key)
      |> Employee.reset_changeset(employee, key)
      |> Repo.insert!
    end

    jaylo = Enum.find new_employees, &(&1.first_name == "Jennifer")
    matt = Enum.find new_employees, &(&1.first_name == "Matt")

    {:ok, matt: matt, jaylo: jaylo}
  end

  # Login/logout

  test "login succeeds when the password is correct" do
    # Fetch Matt, confirm him and log him in
    Repo.get_by!(Employee, email: "matt@damon.com") |> user_confirmed
    conn = post conn, "/login", user: @valid_attrs
    assert redirected_to(conn) == "/"
  end

  test "login fails when the password is incorrect" do
    Repo.get_by!(Employee, email: "matt@damon.com") |> user_confirmed
    conn = post conn, "/login", user: @invalid_attrs
    assert redirected_to(conn) == "/login"
  end

  test "login fails for non-confirmed users" do
    conn = post conn, "/login", user: @valid_attrs
    assert redirected_to(conn) == "/login"
  end

  test "login fails for non-existing users" do
    conn = post conn, "/login", user: @nonexisting_attrs
    assert redirected_to(conn) == "/login"
  end

  test "logout succeeds and redirects to /" do
    {:ok, user_token} = %{id: 3, email: "matt@damon.com", role: "full"}
      |> generate_token({0, 86400})
    conn = conn()
    |> put_req_cookie("access_token", user_token)
    |> get("/logout")
    assert redirected_to(conn) == "/"
  end

  # Route authentication

  test "authenticated routes should be accessible for logged in users" do
    conn = auth_conn() |> get("/employees")
    assert html_response(conn, 200)
  end

  test "authenticated routes should not be accessible for anonymous" do
    conn = conn() |> get("/employees")
    assert redirected_to(conn) == "/login"
  end

end
