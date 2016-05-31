defmodule Appointments.ReservationControllerTest do
  use Appointments.ConnCase

  alias Appointments.Reservation

  setup %{conn: conn} do
    company = insert(:company)
    employee = insert(:employee, company_id: company.id)
    service = insert(:service, company_id: company.id)
    client = insert(:client, company_id: company.id)
    reservation = insert(
      :client_reservation,
      company_id: company.id,
      employee: employee.id,
      service: service.id
    )

    {:ok, token} = create_token(company, employee)
    conn = conn()
    |> put_req_header("authorization", "Bearer " <> token)
    |> put_req_header("accept", "application/json")

    {:ok, conn: conn, reservation: reservation}
  end

@doc """

  test "shows chosen resource", %{conn: conn} do
    reservation = Repo.insert! %Reservation{}
    conn = get conn, reservation_path(conn, :show, reservation)
    assert json_response(conn, 200)["data"] == %{"id" => reservation.id,
      "title" => reservation.title,
      "type" => reservation.type,
      "all_day" => reservation.all_day,
      "start_time" => reservation.start_time,
      "end_time" => reservation.end_time,
      "duration" => reservation.duration,
      "cleanup_duration" => reservation.cleanup_duration,
      "notes" => reservation.notes,
      "employee_id" => reservation.employee_id,
      "service_id" => reservation.service_id,
      "company_id" => reservation.company_id,
      "client_id" => reservation.client_id}
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, reservation_path(conn, :create), reservation: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Reservation, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, reservation_path(conn, :create), reservation: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    reservation = Repo.insert! %Reservation{}
    conn = put conn, reservation_path(conn, :update, reservation), reservation: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Reservation, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    reservation = Repo.insert! %Reservation{}
    conn = put conn, reservation_path(conn, :update, reservation), reservation: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end
"""

  test "lists all entries on index", %{conn: conn} do
    conn = get(conn, reservation_path(conn, :index))
    assert Enum.count(json_response(conn, 200)["data"]) == 1
  end

  test "does not show resource and instead throw error when id is nonexistent",
    %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, reservation_path(conn, :show, "11111111-1111-1111-1111-111111111111")
    end
  end

  test "deletes chosen resource", %{conn: conn, reservation: reservation} do
    conn = delete(conn, reservation_path(conn, :delete, reservation))
    assert response(conn, 204)
    refute Repo.get(Reservation, reservation.id)
  end

end
