defmodule Appointments.Reservation do
  use Appointments.Web, :model
  use Timex.Ecto.Timestamps

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "reservations" do
    field :title, :string
    field :type, :string

    field :all_day, :boolean, default: false
    field :start_time, Timex.Ecto.DateTime
    field :end_time, Timex.Ecto.DateTime, default: nil
    field :duration, :integer
    field :cleanup_duration, :integer

    field :notes, :string

    belongs_to :employee, Appointments.Employee, type: :binary_id
    belongs_to :service, Appointments.Service, type: :binary_id
    belongs_to :company, Appointments.Company, type: :binary_id
    belongs_to :client, Appointments.Client, type: :binary_id

    timestamps
  end

  def shared_validations(model) do
    model
    |> validate_inclusion(:type, ~w(client personal))
  end

  def client_changeset(model, params \\ :empty) do
    required_fields = ~w(type start_time client_id company_id service_id)
    optional_fields = ~w(all_day duration cleanup_duration end_time notes)

    model
    |> cast(params, required_fields, optional_fields)
    |> shared_validations
  end

  def personal_changeset(model, params \\ :empty) do
    required_fields = ~w(type start_time title company_id employee_id)
    optional_fields = ~w(all_day duration cleanup_duration end_time notes)

    model
    |> cast(params, required_fields, optional_fields)
    |> shared_validations
  end
end

defimpl Poison.Encoder, for: Appointments.Reservation do
  def encode(model, opts) do
    model
    |> Map.take([
      :title, :type, :all_day, :start_time, :end_time,
      :duration, :cleanup_duration, :notes,
      :employee_id, :company_id, :service_id, :client_id
    ]) |> Poison.Encoder.encode(opts)
  end
end
