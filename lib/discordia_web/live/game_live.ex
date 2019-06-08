defmodule DiscordiaWeb.GameLive do
  use Phoenix.LiveView

  alias Discordia.{GameSupervisor, GameServer}
  alias DiscordiaWeb.GameView
  alias DiscordiaWeb.Presence
  alias Phoenix.Socket.Broadcast

  def render(assigns) do
    GameView.render("show.html", assigns)
  end

  def mount(%{game_name: game_name, current_player: current_player}, socket) do
    Phoenix.PubSub.subscribe(Discordia.PubSub, "game:" <> game_name)
    Presence.track(self(), "game:" <> game_name, current_player.name, %{})
    socket = assign(socket, game_name: game_name)

    {:ok, fetch(socket)}
  end

  defp fetch(%{assigns: %{game_name: game_name}} = socket) do
    player_list = Presence.list("game:" <> game_name)
    assign(socket, %{players: player_list})
  end

  def handle_event("start_game", _, %{assigns: %{game_name: game_name}} = socket) do
    case GameSupervisor.start_game(game_name) do
      {:ok, _game_pid} ->
        Phoenix.PubSub.broadcast!(Discordia.PubSub, "game:" <> game_name, {:ok, :game_started})

      {:error, _reason} ->
        Phoenix.PubSub.broadcast!(
          Discordia.PubSub,
          "game:" <> game_name,
          {:error, "Unable to start game"}
        )
    end

    {:noreply, socket}
  end

  def handle_event("stop_game", _, socket) do
    {:noreply, stop_game(socket)}
  end

  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    {:noreply, fetch(socket)}
  end

  def handle_info({:ok, :game_started}, socket) do
    socket = assign(socket, %{game: "The game"})
    {:noreply, socket}
  end

  def handle_info({:error, reason}, socket) do
    socket = assign(socket, %{error: reason})
    {:noreply, socket}
  end

  def stop_game(%{assigns: %{game_name: game_name}} = socket) do
    case GameSupervisor.stop_game(game_name) do
      :ok -> assign(socket, %{game: nil})
      nil -> socket
    end
  end
end
