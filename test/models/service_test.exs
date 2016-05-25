defmodule Appointments.ServiceTest do
  use Appointments.ModelCase

  alias Appointments.Service

  @valid_service %{
    name: "Bike bag rental",
    duration: 5,
    cleanup_duration: 0,
    company_id: Ecto.UUID.generate()
  }

  test "services without a company reference should be invalid" do
    changeset = Service.changeset(%Service{}, %{name: "abc", duration: 13})
    refute changeset.valid?
  end

  test "services without a name should be invalid" do
    changeset = Service.changeset(%Service{}, %{duration: 45, company_id: 1})
    refute changeset.valid?
  end

  test "the duration of service should be in the range <0, 1440>" do
    changeset = Service.changeset(%Service{}, %{@valid_service | duration: 0})
    refute changeset.valid?
    changeset = Service.changeset(%Service{}, %{@valid_service | duration: 1440})
    refute changeset.valid?
    changeset = Service.changeset(%Service{}, %{@valid_service | duration: 1439})
    assert changeset.valid?
  end

  test "cleanup_duration should be in the range [0, 60]" do
    changeset = Service.changeset(%Service{}, %{@valid_service | cleanup_duration: -1})
    refute changeset.valid?
    changeset = Service.changeset(%Service{}, %{@valid_service | cleanup_duration: 61})
    refute changeset.valid?
    changeset = Service.changeset(%Service{}, %{@valid_service | cleanup_duration: 60})
    assert changeset.valid?
  end

  test "changeset with valid attributes" do
    changeset = Service.changeset(%Service{}, @valid_service)
    assert changeset.valid?
  end
end
