defmodule Appointments.EmployeeTest do
  use Appointments.ModelCase

  alias Appointments.Employee
  @employee %{ email: "paolo@gmail.com", name: "Paolo Maldini", company_id: 1337 }
  @invalid_attrs %{ }

  test "role needs to be one of [restricted, self, full]" do
    params = Map.put(@employee, :role, "restricted")
    changeset = Employee.changeset(%Employee{}, params)
    assert changeset.valid?

    params = Map.put(@employee, :role, "banana")
    changeset = Employee.changeset(%Employee{}, params)
    refute changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Employee.changeset(%Employee{}, @invalid_attrs)
    refute changeset.valid?
  end

end
