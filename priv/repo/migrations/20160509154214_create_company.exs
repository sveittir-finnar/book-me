defmodule Appointments.Repo.Migrations.CreateCompany do
  use Ecto.Migration

  def change do
    create table(:companies, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :name, :string
      add :phone, :string
      add :email, :string
      add :description, :string

      timestamps
    end

  end
end
