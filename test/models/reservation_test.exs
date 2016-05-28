defmodule Appointments.ReservationTest do
  use Appointments.ModelCase

  alias Appointments.Reservation

  @valid_attrs %{all_day: true, cleanup_duration: 42, duration: 42, end_time: "2010-04-17 14:00:00", notes: "some content", start_time: "2010-04-17 14:00:00", title: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Reservation.changeset(%Reservation{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Reservation.changeset(%Reservation{}, @invalid_attrs)
    refute changeset.valid?
  end
end
