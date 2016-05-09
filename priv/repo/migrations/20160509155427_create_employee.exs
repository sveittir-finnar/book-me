defmodule Appointments.Repo.Migrations.CreateEmployee do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :name, :string
      add :phone, :string
      add :email, :string
      add :bio, :string
      add :avatar_url, :string
      add :company_id, references(:companies, on_delete: :nothing)

      timestamps
    end
    create index(:employees, [:company_id])

  end
end
