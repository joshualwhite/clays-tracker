defmodule ClaysWeb.RoundLive.Index do
  use ClaysWeb, :live_view

  alias Clays.Skeet
  alias Clays.Skeet.Round

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if socket.assigns.current_user do
        socket
      else
        redirect(socket, to: "/users/log_in")
      end

    IO.puts("index.ex")
    IO.inspect(socket)

    {:ok, stream(socket, :skeet, Skeet.list_skeet_rounds())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Round")
    |> assign(:round, Skeet.get_round!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Round")
    |> assign(:round, %Round{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Skeet rounds")
    |> assign(:round, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    round = Skeet.get_round!(id)
    {:ok, _} = Skeet.delete_round(round)

    {:noreply, stream_delete(socket, :skeet, round)}
  end

  @impl true
  def handle_info({ClaysWeb.RoundLive.FormComponent, {:saved, round}}, socket) do
    {:noreply, stream_insert(socket, :skeet, round)}
  end
end
