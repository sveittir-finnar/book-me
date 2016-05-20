defmodule Appointments.ServiceTest do
  use Appointments.ModelCase

  alias Appointments.Service

  @valid_service %{
    id: "7488a646-e31f-11e4-aace-600308960662",
    name: "Bike bag rental",
    description: "EVOC bag",
    duration: 5,
    pricing: "5000 kr/klst"
  }
  @invalid_service %{}

  test "changeset with valid attributes" do
    changeset = Service.changeset(%Service{}, @valid_service)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Service.changeset(%Service{}, @invalid_service)
    refute changeset.valid?
  end
end
