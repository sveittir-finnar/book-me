defmodule Appointments.ClientTest do
  use Appointments.ModelCase

  alias Appointments.Client

  @client_base %{
    company_id: Ecto.UUID.generate()
  }

  test "changeset without a last_name" do
    changeset = Client.changeset(
      %Client{}, Map.put(@client_base, :first_name, "Gisli"))
    refute changeset.valid?
  end

  test "changeset with a email that lacks a @-symbol" do
    changeset = Client.changeset(
      %Client{}, Map.put(@client_base, :email, "gislimarteinn.is"))
    refute changeset.valid?
  end

  test "changeset with valid attributes" do
    changeset = Client.changeset(%Client{}, Map.merge(@client_base, %{
      first_name: "Gisli", last_name: "Baldursson"}))
    assert changeset.valid?
  end
end
