defmodule ClaysWeb.RoundLiveTest do
  use ClaysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Clays.SkeetFixtures

  @create_attrs %{total: 42, user_id: "7488a646-e31f-11e4-aace-600308960662", score: 42, misses: [1, 2], option: 42, created_at: "2024-06-01T14:48:00Z"}
  @update_attrs %{total: 43, user_id: "7488a646-e31f-11e4-aace-600308960668", score: 43, misses: [1], option: 43, created_at: "2024-06-02T14:48:00Z"}
  @invalid_attrs %{total: nil, user_id: nil, score: nil, misses: [], option: nil, created_at: nil}

  defp create_round(_) do
    round = round_fixture()
    %{round: round}
  end

  describe "Index" do
    setup [:create_round]

    test "lists all skeet_rounds", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/skeet_rounds")

      assert html =~ "Listing Skeet rounds"
    end

    test "saves new round", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/skeet_rounds")

      assert index_live |> element("a", "New Round") |> render_click() =~
               "New Round"

      assert_patch(index_live, ~p"/skeet_rounds/new")

      assert index_live
             |> form("#round-form", round: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#round-form", round: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/skeet_rounds")

      html = render(index_live)
      assert html =~ "Round created successfully"
    end

    test "updates round in listing", %{conn: conn, round: round} do
      {:ok, index_live, _html} = live(conn, ~p"/skeet_rounds")

      assert index_live |> element("#skeet_rounds-#{round.id} a", "Edit") |> render_click() =~
               "Edit Round"

      assert_patch(index_live, ~p"/skeet_rounds/#{round}/edit")

      assert index_live
             |> form("#round-form", round: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#round-form", round: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/skeet_rounds")

      html = render(index_live)
      assert html =~ "Round updated successfully"
    end

    test "deletes round in listing", %{conn: conn, round: round} do
      {:ok, index_live, _html} = live(conn, ~p"/skeet_rounds")

      assert index_live |> element("#skeet_rounds-#{round.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#skeet_rounds-#{round.id}")
    end
  end

  describe "Show" do
    setup [:create_round]

    test "displays round", %{conn: conn, round: round} do
      {:ok, _show_live, html} = live(conn, ~p"/skeet_rounds/#{round}")

      assert html =~ "Show Round"
    end

    test "updates round within modal", %{conn: conn, round: round} do
      {:ok, show_live, _html} = live(conn, ~p"/skeet_rounds/#{round}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Round"

      assert_patch(show_live, ~p"/skeet_rounds/#{round}/show/edit")

      assert show_live
             |> form("#round-form", round: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#round-form", round: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/skeet_rounds/#{round}")

      html = render(show_live)
      assert html =~ "Round updated successfully"
    end
  end
end
