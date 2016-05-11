defmodule Appointments.ConfirmTest do
  use Appointments.ConnCase
  alias Appointments.Employee

  @employees [
    %{id: 1, email: "gladys@mail.com", name: "gladys", role: "full", password: "^hEsdg*F899"},
    %{id: 3, email: "matt@damon.com", name: "matt", role: "full", password: "banani"}
  ]

  @valid_link "email=gladys%40mail.com&key=pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
  @invalid_link "email=gladys%40mail.com&key=pu9-VNdgE8V9QzO19RLCG3KUNjpxuixg"
  @valid_attrs %{email: "matt@damon.com", password: "^hEsdg*F899",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}
  @invalid_attrs %{email: "matt@damon.com",  password: "^hEsdg*F899",
    key: "pu9-VNDGe8v9QzO19RLCg3KUNjpxuixg"}
  @invalid_pass %{email: "matt@damon.com", password: "qwe",
    key: "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"}

  setup do
    key = "pu9-VNdgE8V9qZo19rlcg3KUNjpxuixg"
    for employee <- @employees do
      %Employee{}
      |> Employee.auth_changeset(employee, key)
      |> Employee.reset_changeset(employee, key)
      |> Repo.insert!
    end

    conn = conn()
    { :ok, conn: conn }
  end

  # The first two tests are for email confirmation.
  # In this case, you need to add the confirmation_token (key)
  # to a user with the email "gladys@mail.com" before running these tests
  test "confirmation succeeds for correct key" do
    conn = conn() |> get("/confirm?" <> @valid_link)
    assert conn.private.phoenix_flash["info"] =~ "successfully confirmed"
    assert redirected_to(conn) == "/login"
  end

  test "confirmation fails for incorrect key" do
    conn = conn() |> get("/confirm?" <> @invalid_link)
    assert conn.private.phoenix_flash["error"] =~ "failed"
    assert redirected_to(conn) == "/login"
  end

  # The next three tests are for resetting passwords.
  # You need to add the reset_token (key) to a user
  # with the email "gladys@mail.com" before running these tests
  test "reset password succeeds for correct key" do
    conn = conn() |> post("/resetting", user: @valid_attrs)
    assert conn.private.phoenix_flash["info"] =~ "successfully confirmed"
    assert redirected_to(conn) == "/login"
  end

  test "reset password fails for incorrect key" do
    conn = conn() |> post("/resetting", user: @invalid_attrs)
    assert conn.private.phoenix_flash["error"] =~ "failed"
  end

  test "reset password fails for too short passwords" do
    conn = conn() |> post("/resetting", user: @invalid_pass)
    assert conn.private.phoenix_flash["error"] =~ "too short"
  end

end
