defmodule Appointments.Repo.Migrations.NameToFirstAndLast do
  use Ecto.Migration

  def up do
    alter table(:employees) do
      add :last_name, :string
      add :first_name, :string
      remove :name
    end
  end

  def down do
    alter table(:employees) do
      remove :last_name
      remove :first_name
      add :name, :string
    end
  end
end
