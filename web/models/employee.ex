defmodule Appointments.Employee do
  use Appointments.Web, :model

  alias Openmaize.DB

  schema "employees" do
    field :email, :string
    field :name, :string
    field :phone, :string
    field :bio, :string
    field :avatar_url, :string
    field :role, :string

    # Authentication
    field :password, :string, virtual: true
    field :password_hash, :string

    # Email confirmation
    field :confirmation_token, :string
    field :confirmation_sent_at, Ecto.DateTime
    field :confirmed_at, Ecto.DateTime

    # Password reset fields
    field :reset_token, :string
    field :reset_sent_at, Ecto.DateTime

    # Associations
    belongs_to :company, Appointments.Company

    timestamps
  end

  @required_fields ~w(name email role company_id)
  @optional_fields ~w(phone bio avatar_url password_hash
                      confirmation_token confirmation_sent_at confirmed_at
                      reset_token reset_sent_at)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    # TODO(krummi): validations
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_inclusion(:role, ["restricted", "self", "full"])
    |> unique_constraint(:email)
  end

  def auth_changeset(model, params, key) do
    model
    |> changeset(params)
    |> DB.add_password_hash(params)
    |> DB.add_confirm_token(key)
  end

  def reset_changeset(model, params, key) do
    model
    |> cast(params, ~w(email), [])
    |> DB.add_reset_token(key)
  end

end
