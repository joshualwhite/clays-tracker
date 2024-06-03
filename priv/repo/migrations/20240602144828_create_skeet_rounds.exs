defmodule Clays.Repo.Migrations.CreateSkeetRounds do
  use Ecto.Migration

  def change do
    create table(:skeet_rounds, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, :uuid
      add :score, :integer
      add :total, :integer
      add :misses, {:array, :integer}
      add :option, :integer
      add :created_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
