defmodule Appointments.Repo.Migrations.CreateClient do
  use Ecto.Migration

  def change do
    create table(:clients, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :phone, :string
      add :email, :string
      add :notes, :text
      add :company_id, references(:companies, on_delete: :nothing, type: :binary_id)

      timestamps
    end
    create index(:clients, [:company_id])

  end
end
