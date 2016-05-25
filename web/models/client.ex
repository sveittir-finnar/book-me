defmodule Appointments.Client do
  use Appointments.Web, :model

  schema "clients" do
    field :first_name, :string
    field :last_name, :string
    field :phone, :string
    field :email, :string
    field :notes, :string
    belongs_to :company, Appointments.Company

    timestamps
  end

  @required_fields ~w(first_name last_name)
  @optional_fields ~w(phone email notes)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:first_name, min: 1, max: 100)
    |> validate_length(:last_name, min: 1, max: 100)
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase/1)
  end
end
