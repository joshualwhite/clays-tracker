defmodule Clays.SkeetFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Clays.Skeet` context.
  """

  @doc """
  Generate a round.
  """
  def round_fixture(attrs \\ %{}) do
    {:ok, round} =
      attrs
      |> Enum.into(%{
        created_at: ~U[2024-06-01 14:48:00Z],
        misses: [1, 2],
        option: 42,
        score: 42,
        total: 42,
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Clays.Skeet.create_round()

    round
  end
end
