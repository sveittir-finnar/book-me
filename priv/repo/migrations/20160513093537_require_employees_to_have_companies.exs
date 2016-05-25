defmodule Appointments.Repo.Migrations.RequireEmployeesToHaveCompanies do
  use Ecto.Migration

  def up do
    alter table(:employees) do
      modify :company_id, :binary_id, null: false
      modify :bio, :text
      modify :role, :string, null: false
      modify :name, :string, null: false
      modify :email, :string, null: false
    end
  end

  def down do
    alter table(:employees) do
      modify :company_id, :binary_id, null: true
      modify :bio, :text
      modify :role, :string, null: true
      modify :name, :string, null: true
      modify :email, :string, null: true
    end
  end

end
