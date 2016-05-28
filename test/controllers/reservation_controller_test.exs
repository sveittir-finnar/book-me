defmodule Appointments.ReservationControllerTest do
  use Appointments.ConnCase

  alias Appointments.Reservation
  @valid_attrs %{all_day: true, cleanup_duration: 42, duration: 42, end_time: "2010-04-17 14:00:00", notes: "some content", start_time: "2010-04-17 14:00:00", title: "some content", type: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, reservation_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

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

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, reservation_path(conn, :show, "11111111-1111-1111-1111-111111111111")
    end
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

  test "deletes chosen resource", %{conn: conn} do
    reservation = Repo.insert! %Reservation{}
    conn = delete conn, reservation_path(conn, :delete, reservation)
    assert response(conn, 204)
    refute Repo.get(Reservation, reservation.id)
  end
end
