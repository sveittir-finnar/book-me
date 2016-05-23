defmodule Appointments.Company do
  use Appointments.Web, :model

  import Appointments.Validators

  schema "companies" do
    # Basics
    field :name, :string
    field :phone, :string
    field :email, :string
    field :website_url, :string
    field :facebook, :string
    field :twitter, :string
    field :description, :string

    # TODO: These
    field :logo_url, :string
    field :timezone, :string

    # Location
    field :location_name, :string
    field :location_street, :string
    field :location_city, :string
    field :location_country, :string
    field :zip, :string

    # Opening hours
    field :opening_hours, :map

    has_many :employees, Appointments.Employee
    has_many :services, Appointments.Service

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(phone email description website_url facebook twitter
    logo_url timezone location_name location_street location_city
    location_country zip opening_hours)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    allowed_country_codes = Enum.map(Countries.all(), &(to_string(&1.alpha2)))
    IO.inspect(allowed_country_codes)
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:name, min: 1, max: 100)
    |> validate_uri(:website_url)
    |> validate_inclusion(:location_country, allowed_country_codes)
  end
end
