defmodule Appointments.ServiceControllerTest do
  use Appointments.ConnCase

  alias Appointments.Service

  setup do
    company = insert(:company)
    employee = insert(:employee, company_id: company.id)
    service = insert(:service, company_id: company.id)

    {:ok, token} = create_token(company, employee)
    conn = conn() |> put_req_cookie("access_token", token)

    {:ok, conn: conn, service: service}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, service_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing services"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, service_path(conn, :new)
    assert html_response(conn, 200) =~ "New service"
  end

  test "creates resource and redirects when data is valid",
    %{conn: conn, service: service} do
    valid_attrs = %{name: "Test", duration: 50, company_id: service.company_id}
    conn = post conn, service_path(conn, :create), service: valid_attrs
    assert redirected_to(conn) == service_path(conn, :index)
    assert Repo.get_by(Service, valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid",
    %{conn: conn} do
    invalid_attrs = %{name: "testing"}
    conn = post conn, service_path(conn, :create), service: invalid_attrs
    assert html_response(conn, 200) =~ "New service"
  end

  test "shows chosen resource", %{conn: conn, service: service} do
    conn = get conn, service_path(conn, :show, service)
    assert html_response(conn, 200) =~ "Show service"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      # This should be unlikely enough:
      get conn, service_path(conn, :show, Ecto.UUID.generate)
    end
  end

  test "renders form for editing chosen resource",
    %{conn: conn, service: service} do
    conn = get conn, service_path(conn, :edit, service)
    assert html_response(conn, 200) =~ "Edit service"
  end

  test "updates chosen resource and redirects when data is valid",
    %{conn: conn, service: service} do
    update_attrs = %{cleanup_duration: 59}
    conn = patch conn, service_path(conn, :update, service), service: update_attrs
    assert redirected_to(conn) == service_path(conn, :show, service)
    assert Repo.get_by(Service, update_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid",
    %{conn: conn, service: service} do
    update_attrs = %{cleanup_duration: -1}
    conn = put conn, service_path(conn, :update, service), service: update_attrs
    assert html_response(conn, 200) =~ "Edit service"
  end

  test "deletes chosen resource", %{conn: conn, service: service} do
    conn = delete conn, service_path(conn, :delete, service)
    assert redirected_to(conn) == service_path(conn, :index)
    refute Repo.get(Service, service.id)
  end
end
