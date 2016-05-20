defmodule Appointments.Service do
  use Appointments.Web, :model

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "services" do

    field :name, :string
    field :description, :string

    # Duration
    field :duration, :integer
    field :cleanup_duration, :integer, default: 0

    # Pricing
    field :pricing_type, :string
    field :price, :string

    # Visibility
    field :public, :boolean, default: true
    field :can_pick_employee, :boolean, default: true

    # Associations
    belongs_to :company, Appointments.Company

    timestamps
  end

  @required_fields ~w(id name duration cleanup_duration pricing_type price public can_pick_employee)
  @optional_fields ~w(description)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
