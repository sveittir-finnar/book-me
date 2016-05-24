defmodule Appointments.Company do
  use Appointments.Web, :model

  import Appointments.Validations

  schema "companies" do
    # Basics
    field :name, :string
    field :phone, :string
    field :email, :string
    field :website_url, :string
    field :facebook, :string
    field :twitter, :string
    field :description, :string

    # TODO(krummi): These
    field :logo_url, :string
    field :timezone, :string

    # Location
    field :location_name, :string
    field :location_street, :string
    field :location_city, :string
    field :location_country, :string
    field :location_zip, :string

    """
    Opening hours - format should be:
      { "day": [[from, to], [from, to], etc] }
    where day is one of ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
    and from and to are integers in the range [0, 24].

    Example:

      {
        "mon": [[9, 12], [13, 17]],
        "tue": [[9, 17]],
        "wed": [[9, 12], [13, 19], [20, 24]]
      }

    """
    field :opening_hours, :map, default: %{}

    has_many :employees, Appointments.Employee
    has_many :services, Appointments.Service

    timestamps
  end

  @required_fields ~w(name opening_hours)
  @optional_fields ~w(phone email description website_url facebook twitter
    location_name location_street location_city location_country location_zip
     logo_url timezone)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    allowed_country_codes = Enum.map(Countries.all(), &(to_string(&1.alpha2)))

    # We might want to revisit this. I can't believe that we need to do this
    # serialization step manually, but still I cannot figure out a wednesday
    # to make Ecto do it for me behind the scenes.
    if params != :empty && Map.get(params, "opening_hours") != nil do
      case Poison.Parser.parse(params["opening_hours"]) do
        {:ok, parsed} -> params = Map.put(params, "opening_hours", parsed)
        {:error, _} -> nil
      end
    end

    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:name, min: 1, max: 100)
    |> validate_uri(:website_url)
    |> validate_inclusion(:location_country, allowed_country_codes)
    |> validate_opening_hours(:opening_hours)
  end
end
