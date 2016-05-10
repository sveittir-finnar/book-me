defmodule Appointments.EmployeeTest do
  use Appointments.ModelCase

  alias Appointments.Employee

  @valid_attrs %{ email: "paolo@gmail.com", name: "Paolo Maldini",
                  password_hash: "123abc456def" }
  @invalid_attrs %{ }

  test "changeset with valid attributes" do
    changeset = Employee.changeset(%Employee{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Employee.changeset(%Employee{}, @invalid_attrs)
    refute changeset.valid?
  end
end
