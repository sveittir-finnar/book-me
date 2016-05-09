defmodule Appointments.CompanyTest do
  use Appointments.ModelCase

  alias Appointments.Company

  @valid_attrs %{description: "some content", email: "some content", name: "some content", phone: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Company.changeset(%Company{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Company.changeset(%Company{}, @invalid_attrs)
    refute changeset.valid?
  end
end