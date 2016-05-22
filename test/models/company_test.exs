defmodule Appointments.CompanyTest do
  use Appointments.ModelCase

  alias Appointments.Company

  test "validations: website_url should be comply to the URI standard" do
    changeset = Company.changeset(
      %Company{}, %{name: "a", website_url: "mbl"})
    refute changeset.valid?

    changeset = Company.changeset(
      %Company{}, %{name: "a", website_url: "mbl.is"})
    refute changeset.valid?

    changeset = Company.changeset(
      %Company{}, %{name: "a", website_url: "http://mbl.is"})
    assert changeset.valid?
  end

  test "validations: name is required" do
    changeset = Company.changeset(%Company{}, %{})
    refute changeset.valid?
  end
end
