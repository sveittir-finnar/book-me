defmodule Appointments.Repo.Migrations.AddFieldsToCompanies do
  use Ecto.Migration

  def change
    alter table(:companies) do
      add :website_url, :string
      add :facebook, :string
      add :twitter, :string
      add :logo_url, :string
      add :timezone, :string

      # location
      add :location_name, :string
      add :location_street, :string
      add :location_city, :string
      add :location_country, :string
      add :zip, :string
    end
  end
end
