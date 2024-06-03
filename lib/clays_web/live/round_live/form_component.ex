defmodule ClaysWeb.RoundLive.FormComponent do
  use ClaysWeb, :live_component

  alias Clays.Skeet

  def split_shots(shots, boundaries) do
    do_split_shots(shots, boundaries, [])
  end

  defp do_split_shots([], _boundaries, acc), do: Enum.reverse(acc)

  defp do_split_shots(shots, [], acc), do: Enum.reverse([shots | acc])

  defp do_split_shots(shots, [boundary | rest_boundaries], acc) do
    {chunk, rest_shots} = Enum.split(shots, boundary)
    do_split_shots(rest_shots, rest_boundaries, [chunk | acc])
  end

  defp find_option_index(0, _boundaries, index) do
    index
  end

  defp find_option_index(option, boundaries, index) do
    cond do
      option + 1 > Enum.at(boundaries, index) ->
        find_option_index(option - Enum.at(boundaries, index), boundaries, index + 1)

      option <= boundaries ->
        index
    end
  end

  defp find_option_index(option, boundaries) do
    find_option_index(option, boundaries, 0)
  end

  def render_shots(assigns) do
    option = Map.get(assigns, :option)

    total =
      if option do
        24
      else
        23
      end

    boundaries = [4, 4, 2, 2, 2, 4, 4, 2]

    station_boundaries =
      if option do
        option_index = find_option_index(option, boundaries)

        boundaries
        |> Enum.with_index()
        |> Enum.map(fn {boundary, index} ->
          case index == option_index do
            true -> boundary + 1
            false -> boundary
          end
        end)
      else
        boundaries
      end

    split_shots(Enum.map(0..total, fn x -> x end), station_boundaries)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= "New Skeet Score" %>
      </.header>

      <div id="score-counter">
        <p class="text-xl"><%= Map.get(assigns, :hits, 0) %>/25</p>
        <%= for station <- render_shots(assigns) do %>
          <div class="flex flex-row justify-start w-full mt-2">
            <%= for shot <- station do %>
              <div class={"w-6 h-6 m-1 #{shot_status(shot, assigns)}"}></div>
            <% end %>
          </div>
        <% end %>

        <div class="flex flex-row justify-start w-full mt-2">
          <button
            class="p-2 text-lg bg-green-900 px-4 text-white rounded mr-2"
            phx-click="hit"
            phx-target={@myself}
          >
            + Hit
          </button>
          <button
            class="p-2 text-lg bg-red-900 px-4 text-white rounded ml-2"
            phx-click="miss"
            phx-target={@myself}
          >
            - Miss
          </button>
        </div>
      </div>

      <.simple_form
        for={@form}
        id="round-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <input type="hidden" name="round[score]" value={Map.get(assigns, :hits, 0)} />
        <input type="hidden" name="round[misses]" value={Map.get(assigns, :misses_array, [])} />
        <input type="hidden" name="round[total]" value={Map.get(assigns, :total, 0)} />
        <input type="hidden" name="round[option]" value={Map.get(assigns, :option, 24)} />
        <input type="hidden" name="round[created_at]" value={DateTime.utc_now()} />
        <:actions>
          <.button disabled={Map.get(assigns, :total, 0) < 25} phx-disable-with="Saving...">
            Save Round
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  defp shot_status(shot, assigns) do
    misses_array = Map.get(assigns, :misses_array, [])
    total = Map.get(assigns, :hits, 0) + Map.get(assigns, :misses, 0)

    cond do
      shot in misses_array -> "bg-red-500"
      shot < total -> "bg-green-500"
      true -> "bg-gray-300"
    end
  end

  def handle_event("hit", _params, socket) do
    hits = Map.get(socket.assigns, :hits, 0)
    misses = Map.get(socket.assigns, :misses, 0)

    if hits + misses < 25 do
      {:noreply, assign(socket, hits: hits + 1, total: hits + misses + 1)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("miss", _params, socket) do
    hits = Map.get(socket.assigns, :hits, 0)
    misses = Map.get(socket.assigns, :misses, 0)
    misses_array = Map.get(socket.assigns, :misses_array, [])
    total = hits + misses + 1
    # idx of miss = total - 1
    misses_array = Enum.concat(misses_array, [hits + misses])

    socket =
      if length(misses_array) == 1 do
        assign(socket, :option, hits + misses)
      else
        socket
      end

    if hits + misses < 25 do
      {:noreply, assign(socket, misses: misses + 1, total: total, misses_array: misses_array)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate", %{"round" => round_params}, socket) do
    changeset =
      socket.assigns.round
      |> Skeet.change_round(round_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"round" => round_params}, socket) do
    save_round(socket, socket.assigns.action, round_params)
  end

  @impl true
  def update(%{round: round} = assigns, socket) do
    changeset = Skeet.change_round(round)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  defp save_round(socket, :edit, round_params) do
    case Skeet.update_round(socket.assigns.round, round_params) do
      {:ok, round} ->
        notify_parent({:saved, round})

        {:noreply,
         socket
         |> put_flash(:info, "Round updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_round(socket, :new, round_params) do
    round_params =
      round_params
      |> Map.put("user_id", socket.assigns.current_user.id)
      |> Map.put("misses", Map.get(socket.assigns, :misses_array, []))

    case Skeet.create_round(round_params) do
      {:ok, round} ->
        notify_parent({:saved, round})

        {:noreply,
         socket
         |> put_flash(:info, "Round created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.puts(changeset)

        put_flash(socket, :info, "Could not save skeet round")
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
