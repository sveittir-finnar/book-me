defmodule Appointments.Repo.Migrations.CreateReservation do
  use Ecto.Migration

  def change do
    create table(:reservations, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, default: nil
      add :type, :string
      add :all_day, :boolean, default: false
      add :start_time, :datetime
      add :end_time, :datetime, default: nil
      add :duration, :integer
      add :cleanup_duration, :integer
      add :notes, :text

      add :employee_id, references(:employees, on_delete: :nothing, type: :binary_id)
      add :service_id, references(:services, on_delete: :nothing, type: :binary_id)
      add :company_id, references(:companies, on_delete: :nothing, type: :binary_id), null: false
      add :client_id, references(:clients, on_delete: :nothing, type: :binary_id)

      timestamps
    end
    create index(:reservations, [:employee_id])
    create index(:reservations, [:service_id])
    create index(:reservations, [:company_id])
    create index(:reservations, [:client_id])
  end
end
