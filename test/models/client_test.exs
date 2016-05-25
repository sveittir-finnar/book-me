defmodule Appointments.ClientTest do
  use Appointments.ModelCase

  alias Appointments.Client

  @valid_attrs %{email: "some content", first_name: "some content", last_name: "some content", notes: "some content", phone: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Client.changeset(%Client{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Client.changeset(%Client{}, @invalid_attrs)
    refute changeset.valid?
  end
end
