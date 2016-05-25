defmodule Appointments.Repo.Migrations.CreateEmployee do
  use Ecto.Migration

  def change do
    create table(:employees, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :name, :string
      add :phone, :string
      add :email, :string
      add :bio, :string
      add :avatar_url, :string
      add :company_id, references(:companies, on_delete: :nothing, type: :binary_id)

      timestamps
    end
    create index(:employees, [:company_id])

  end
end
