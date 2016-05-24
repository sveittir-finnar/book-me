defmodule Appointments.CompanyTest do
  use ExUnit.Case, async: true

  import Appointments.Validations

  test "only the typical weekdays are allowed" do
    assert validate_opening_hours(%{"mon" => [[9, 12]], "sat" => [[1, 2]]})
    refute validate_opening_hours(%{"NOT A DAY" => [[1, 2]]})
  end

  test "range definitions should only contain two numbers" do
    refute validate_opening_hours(%{"mon" => [[9, 12, 13]]})
    refute validate_opening_hours(%{"mon" => [[9, "a"]]})
  end

  test "no of ranges should be >= 1" do
    assert validate_opening_hours(%{"mon" => [[9, 12], [13, 17], [19, 22]]})
    assert validate_opening_hours(%{"mon" => [[9, 12], [13, 17], [19, 22]]})
    refute validate_opening_hours(%{"mon" => []})
  end

  test "ranges should be within [0, 24]" do
    refute validate_opening_hours(%{"mon" => [[-1, 0]]})
    assert validate_opening_hours(%{"mon" => [[0, 2]]})
    assert validate_opening_hours(%{"mon" => [[23, 24]]})
    refute validate_opening_hours(%{"mon" => [[24, 25]]})
  end
end
