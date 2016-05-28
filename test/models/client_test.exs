defmodule Appointments.ClientTest do
  use Appointments.ModelCase

  alias Appointments.Client

  test "changeset without a last_name" do
    changeset = Client.changeset(%Client{}, %{first_name: "Gisl"})
    refute changeset.valid?
  end

  test "changeset with a email that lacks a @-symbol" do
    changeset = Client.changeset(%Client{}, %{email: "gislimarteinn.is"})
    refute changeset.valid?
  end

  test "changeset with valid attributes" do
    changeset = Client.changeset(%Client{}, %{
      first_name: "Gisli", last_name: "Baldursson"})
    assert changeset.valid?
  end
end
