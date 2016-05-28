defmodule Appointments.ClientControllerTest do
  use Appointments.ConnCase

  alias Appointments.Client

  setup do
    company = insert(:company)
    employee = insert(:employee, company_id: company.id)
    client = insert(:client, company_id: company.id)

    {:ok, token} = create_token(company, employee)
    conn = conn() |> put_req_cookie("access_token", token)

    {:ok, conn: conn, client: client}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, client_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing clients"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get(conn, client_path(conn, :new))
    assert html_response(conn, 200) =~ "New client"
  end

  test "creates resource and redirects when data is valid",
    %{conn: conn, client: client} do
    client_attrs = %{
      first_name: "a", last_name: "b", company_id: client.company_id}
    conn = post(conn, client_path(conn, :create), client: client_attrs)
    assert redirected_to(conn) == client_path(conn, :index)
    assert Repo.get_by(Client, client_attrs)
  end

  test "does not create resource and renders errors when data is invalid",
    %{conn: conn} do
    invalid_attrs = %{first_name: "Banani"}
    conn = post(conn, client_path(conn, :create), client: invalid_attrs)
    assert html_response(conn, 200) =~ "New client"
  end

  test "shows chosen resource", %{conn: conn, client: client} do
    conn = get(conn, client_path(conn, :show, client))
    assert html_response(conn, 200) =~ "Show client"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent(404, fn ->
      get(conn, client_path(conn, :show, Ecto.UUID.generate()))
    end)
  end

  test "renders form for editing chosen resource",
    %{conn: conn, client: client} do
    conn = get(conn, client_path(conn, :edit, client))
    assert html_response(conn, 200) =~ "Edit client"
  end

  test "updates chosen resource and redirects when data is valid",
    %{conn: conn, client: client} do
    changes = %{phone: "Z"}
    conn = put(conn, client_path(conn, :update, client), client: changes)
    assert redirected_to(conn) == client_path(conn, :show, client)
    assert Repo.get_by(Client, changes)
  end

  test "does not update chosen resource and renders errors when data is invalid",
    %{conn: conn, client: client} do
    conn = put(conn, client_path(conn, :update, client), client: %{first_name: ""})
    assert html_response(conn, 200) =~ "Edit client"
  end

  test "deletes chosen resource", %{conn: conn, client: client} do
    conn = delete(conn, client_path(conn, :delete, client))
    assert redirected_to(conn) == client_path(conn, :index)
    refute Repo.get(Client, client.id)
  end
end
