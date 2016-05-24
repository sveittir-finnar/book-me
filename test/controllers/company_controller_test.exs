defmodule Appointments.CompanyControllerTest do
  use Appointments.ConnCase

  alias Appointments.Company

  @valid_attrs %{name: "Hudsucker Industries"}
  @invalid_attrs %{name: ""}

  setup do
    company = insert(:company)
    employee = insert(:employee, company_id: company.id)

    {:ok, token} = create_token(company, employee)
    conn = conn() |> put_req_cookie("access_token", token)

    {:ok, conn: conn, company: company}
  end

  # Company public page

  test "shows a company public page to an anonymous user", %{company: company} do
    conn = get conn(), company_path(conn, :show, company.id)
    assert html_response(conn, 200) =~ "Show company"
  end

  test "shows a company public page to an logged in user",
    %{conn: conn, company: company} do
    conn = get conn, company_path(conn, :show, company.id)
    assert html_response(conn, 200) =~ "Show company"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, company_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    conn = get conn, company_path(conn, :edit)
    assert html_response(conn, 200) =~ "Basic Information"
  end

  test "updates chosen resource and redirects when data is valid",
    %{conn: conn, company: company} do
    conn = patch conn, company_path(conn, :update), company: @valid_attrs
    assert redirected_to(conn) == company_path(conn, :show, company)
    assert Repo.get_by(Company, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid",
    %{conn: conn} do
    conn = patch conn, company_path(conn, :update), company: @invalid_attrs
    assert html_response(conn, 200) =~ "Basic Information"
  end

  # Company.opening_hours validation

  test "should fail when the opening_hour JSON does not match the schema",
    %{conn: conn} do
    invalid_hours = Poison.encode!(%{"mon" => [1, 2]})
    conn = patch conn, company_path(conn, :update), company: %{
      opening_hours: invalid_hours}
    assert html_response(conn, 200) =~ "Basic Information"
  end

  test "should succeed when a valid JSON is supplied for the opening_hours",
    %{conn: conn, company: company} do
    valid_hours = %{"mon" => [[9, 12], [13, 17]], "sat" => [[9,15]]}
    valid_hours_str = Poison.encode!(valid_hours)
    conn = patch conn, company_path(conn, :update), company: %{
      opening_hours: valid_hours_str }
    assert redirected_to(conn) == company_path(conn, :show, company)
    %Company{opening_hours: hours} = Repo.get_by(Company, id: company.id)
    assert hours == valid_hours
  end
end
