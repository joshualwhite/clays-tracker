defmodule Clays.Skeet.Round do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "skeet_rounds" do
    field :total, :integer, default: 25
    field :user_id, Ecto.UUID
    field :score, :integer
    field :misses, {:array, :integer}
    field :option, :integer
    field :created_at, :utc_datetime
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(round, attrs) do
    round
    |> cast(attrs, [:user_id, :score, :total, :misses, :option, :created_at])
    |> validate_required([:user_id, :score, :total, :misses, :option, :created_at])
  end
end
