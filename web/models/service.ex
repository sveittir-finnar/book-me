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
    field :pricing, :string

    # Visibility
    field :is_public, :boolean, default: true
    field :can_pick_employee, :boolean, default: true

    # Associations
    belongs_to :company, Appointments.Company

    timestamps
  end

  @required_fields ~w(name duration company_id)
  @optional_fields ~w(cleanup_duration description pricing is_public can_pick_employee)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_number(:duration, greater_than: 1, less_than: 1440) # 60 * 24
    |> validate_number(:cleanup_duration, greater_than_or_equal_to: 0, less_than_or_equal_to: 60)
  end
end
