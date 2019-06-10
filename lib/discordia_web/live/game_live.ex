defmodule DiscordiaWeb.GameLive do
  use Phoenix.LiveView

  alias Discordia.{GameSupervisor, GameServer}
  alias DiscordiaWeb.GameView
  alias DiscordiaWeb.Presence
  alias Phoenix.Socket.Broadcast

  @impl Phoenix.LiveView
  def render(assigns) do
    GameView.render("show.html", assigns)
  end

  @impl Phoenix.LiveView
  def mount(%{game_name: game_name, current_player: current_player}, socket) do
    Phoenix.PubSub.subscribe(Discordia.PubSub, "game:" <> game_name)
    Presence.track(self(), "game:" <> game_name, current_player, %{})
    socket = assign(socket, %{game_name: game_name, players: nil, game: nil})

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("start_game", _, socket) do
    {:noreply, start_game(socket)}
  end

  def handle_event("stop_game", _, socket) do
    {:noreply, stop_game(socket)}
  end

  @impl Phoenix.LiveView
  def handle_info(%Broadcast{event: "presence_diff"}, socket) do
    %{assigns: %{game_name: game_name}} = socket
    player_list = Presence.list("game:" <> game_name)

    {:noreply, assign(socket, %{players: player_list})}
  end

  def handle_info({:ok, :game_started, game_name}, socket) do
    game = GameServer.summary(game_name)
    {:noreply, assign(socket, %{game: game})}
  end

  def handle_info({:ok, :game_stopped}, socket) do
    {:noreply, assign(socket, %{game: nil})}
  end

  def handle_info({:error, reason}, socket) do
    {:noreply, assign(socket, %{error: reason})}
  end

  defp start_game(%{assigns: %{game_name: game_name, players: players}} = socket) do
    GameSupervisor.start_game(game_name, Map.keys(players))

    Phoenix.PubSub.broadcast!(
      Discordia.PubSub,
      "game:" <> game_name,
      {:ok, :game_started, game_name}
    )

    socket
  end

  defp stop_game(%{assigns: %{game_name: game_name}} = socket) do
    case GameSupervisor.stop_game(game_name) do
      :ok ->
        Phoenix.PubSub.broadcast!(Discordia.PubSub, "game:" <> game_name, {:ok, :game_stopped})

      nil ->
        Phoenix.PubSub.broadcast!(
          Discordia.PubSub,
          "game:" <> game_name,
          {:error, "Unable to stop game"}
        )
    end

    socket
  end
end
