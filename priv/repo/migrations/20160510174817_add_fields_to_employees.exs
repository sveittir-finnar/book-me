defmodule Appointments.Repo.Migrations.AddFieldsToEmployees do
  use Ecto.Migration

  def change do
    alter table(:employees) do
      # Required openmaize stuff
      add :role, :string
      add :password_hash, :string

      # Email confirmation
      add :confirmation_token, :string
      add :confirmation_sent_at, :datetime
      add :confirmed_at, :datetime

      # Password reset fields
      add :reset_token, :string
      add :reset_sent_at, :datetime
    end

    # Ensure that emails are unique
    create unique_index(:employees, [:email])
  end
end
