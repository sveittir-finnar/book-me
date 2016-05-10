defmodule Appointments.Employee do
  use Appointments.Web, :model

  # TODO(krummi): alias Openmaize.DB

  schema "employees" do
    field :name, :string
    field :phone, :string
    field :bio, :string
    field :avatar_url, :string

    # Openmaize stuff
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    # Email confirmation
    field :confirmation_token, :string
    field :confirmation_sent_at, Ecto.DateTime
    field :confirmed_at, Ecto.DateTime

    # Password reset fields
    field :reset_token, :string
    field :reset_sent_at, Ecto.DateTime

    belongs_to :company, Appointments.Company

    timestamps
  end

  @required_fields ~w(name email password_hash)
  @optional_fields ~w(phone bio avatar_url
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
    |> unique_constraint(:email)
  end
end
