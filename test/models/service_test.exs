defmodule Appointments.ServiceTest do
  use Appointments.ModelCase

  alias Appointments.Service

  @valid_attrs %{can_pick_employee: true, cleanup_duration: 42, description: "some content", duration: 42, id: "7488a646-e31f-11e4-aace-600308960662", name: "some content", price: "some content", pricing_type: "some content", public: true}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Service.changeset(%Service{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Service.changeset(%Service{}, @invalid_attrs)
    refute changeset.valid?
  end
end
