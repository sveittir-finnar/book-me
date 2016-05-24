defmodule Appointments.Validations do

  import Ecto.Changeset

  @doc """
  Validates that a URI is valid.
  """
  def validate_uri(changeset, column) do
    error_message = "Please enter a valid URL, e.g. http://www.cnn.com."
    value = get_field(changeset, column)
    if value != nil && !is_valid_uri?(value) do
      add_error(changeset, column, error_message)
    else
      changeset
    end
  end

  defp is_valid_uri?(str) do
    uri = URI.parse(str)
    case uri do
      %URI{scheme: nil} -> false
      %URI{host: nil} -> false
      _ -> true
    end
  end

  @doc """
  Validates an "opening hours" JSON schema.
  """
  def validate_opening_hours(changeset, column) do
    if validate_opening_hours(get_field(changeset, column)) do
      changeset
    else
      add_error(changeset, column, "invalid schema")
    end
  end

  def validate_opening_hours(value) do
    # TODO(krummi): It is non-optimal to always be reading this file
    schema = File.read!("web/helpers/schemas.json")
    |> Poison.decode!
    |> ExJsonSchema.Schema.resolve

    opening_hours_schema = schema.schema["definitions"]["opening_hours"]

    ExJsonSchema.Validator.valid?(schema, opening_hours_schema, value)
  end

end
