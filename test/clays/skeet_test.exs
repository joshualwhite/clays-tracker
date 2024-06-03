defmodule Clays.SkeetTest do
  use Clays.DataCase

  alias Clays.Skeet

  describe "skeet_rounds" do
    alias Clays.Skeet.Round

    import Clays.SkeetFixtures

    @invalid_attrs %{total: nil, user_id: nil, score: nil, misses: nil, option: nil, created_at: nil}

    test "list_skeet_rounds/0 returns all skeet_rounds" do
      round = round_fixture()
      assert Skeet.list_skeet_rounds() == [round]
    end

    test "get_round!/1 returns the round with given id" do
      round = round_fixture()
      assert Skeet.get_round!(round.id) == round
    end

    test "create_round/1 with valid data creates a round" do
      valid_attrs = %{total: 42, user_id: "7488a646-e31f-11e4-aace-600308960662", score: 42, misses: [1, 2], option: 42, created_at: ~U[2024-06-01 14:48:00Z]}

      assert {:ok, %Round{} = round} = Skeet.create_round(valid_attrs)
      assert round.total == 42
      assert round.user_id == "7488a646-e31f-11e4-aace-600308960662"
      assert round.score == 42
      assert round.misses == [1, 2]
      assert round.option == 42
      assert round.created_at == ~U[2024-06-01 14:48:00Z]
    end

    test "create_round/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Skeet.create_round(@invalid_attrs)
    end

    test "update_round/2 with valid data updates the round" do
      round = round_fixture()
      update_attrs = %{total: 43, user_id: "7488a646-e31f-11e4-aace-600308960668", score: 43, misses: [1], option: 43, created_at: ~U[2024-06-02 14:48:00Z]}

      assert {:ok, %Round{} = round} = Skeet.update_round(round, update_attrs)
      assert round.total == 43
      assert round.user_id == "7488a646-e31f-11e4-aace-600308960668"
      assert round.score == 43
      assert round.misses == [1]
      assert round.option == 43
      assert round.created_at == ~U[2024-06-02 14:48:00Z]
    end

    test "update_round/2 with invalid data returns error changeset" do
      round = round_fixture()
      assert {:error, %Ecto.Changeset{}} = Skeet.update_round(round, @invalid_attrs)
      assert round == Skeet.get_round!(round.id)
    end

    test "delete_round/1 deletes the round" do
      round = round_fixture()
      assert {:ok, %Round{}} = Skeet.delete_round(round)
      assert_raise Ecto.NoResultsError, fn -> Skeet.get_round!(round.id) end
    end

    test "change_round/1 returns a round changeset" do
      round = round_fixture()
      assert %Ecto.Changeset{} = Skeet.change_round(round)
    end
  end
end
