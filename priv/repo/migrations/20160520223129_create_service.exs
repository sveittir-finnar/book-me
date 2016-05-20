defmodule Appointments.Repo.Migrations.CreateService do
  use Ecto.Migration

  def change do
    create table(:services, primary_key: false) do
      add :id, :uuid, primary_key: true, null: false

      add :name, :string, null: false
      add :description, :text

      add :duration, :integer, null: false
      add :cleanup_duration, :integer, default: 0

      add :pricing, :string

      add :is_public, :boolean, default: true, null: false
      add :can_pick_employee, :boolean, default: true, null: false

      add :company_id, references(:companies), null: false

      timestamps
    end

  end
end
