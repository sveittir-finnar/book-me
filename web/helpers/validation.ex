defmodule Appointments.Validators do

  import Ecto.Changeset

  def validate_uri(changeset, column) do
    error_message = "Please enter a valid URL, e.g. http://www.cnn.com."
    value = get_field(changeset, column)
    if value != nil && !is_valid?(value) do
      add_error(changeset, column, error_message)
    else
      changeset
    end
  end

  defp is_valid?(str) do
    uri = URI.parse(str)
    case uri do
      %URI{scheme: nil} -> false
      %URI{host: nil} -> false
      _ -> true
    end
  end

end
