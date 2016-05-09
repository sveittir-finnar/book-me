defmodule Appointments.Repo.Migrations.CreateCompany do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :name, :string
      add :phone, :string
      add :email, :string
      add :description, :string

      timestamps
    end

  end
end
