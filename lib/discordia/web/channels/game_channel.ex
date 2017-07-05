defmodule Discordia.Web.GameChannel do
  use Phoenix.Channel

  alias Discordia.Web.Presence
  alias Discordia.{Game, GameServer, Player}

  def join("room:" <> room_name, _, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :room, room_name)}
  end

  def terminate(message, socket) do
    Game.stop(socket.assigns.room)
    broadcast!(socket, "game_stopped", %{})
    message
  end

  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.username, %{
      online_at: :os.system_time(:milli_seconds)
    })
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("start_game", %{"players" => players}, socket) do
    %{room: game} = socket.assigns
    assign(socket, :players, players)

    Game.start(game, players)
    broadcast!(socket, "game_started", %{})
    broadcast!(socket, "game_info", game_info(socket))
    {:reply, :ok, socket}
  end

  def handle_in("player_info", _, socket) do
    %{room: game, username: player} = socket.assigns
    payload = %{cards: Player.cards(game, player)}
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("play_card", [card, next], socket) do
    %{room: game, username: player} = socket.assigns
    card = convert(card)
    case Game.play(game, player, card, next) do
      {:ok, _card} ->
        broadcast!(socket, "game_info", game_info(socket))
        {:noreply, socket}
      {:ok, {:ended, player}} ->
        broadcast!(socket, "game_over", player)
        {:noreply, socket}
      _ ->
        {:noreply, socket}
    end
  end

  def handle_in("draw_card", _, socket) do
    %{room: game, username: player} = socket.assigns
    Game.draw(game, player)
    broadcast!(socket, "game_info", game_info(socket))
    {:noreply, socket}
  end

  defp game_info(socket) do
    %{room: game} = socket.assigns

    %{
      current_player: GameServer.current_player(game),
      current_card: GameServer.current_card(game),
      player_queue: GameServer.player_queue(game),
      history: GameServer.history(game)
    }
  end

  defp convert(card) do
    for {k, v} <- card, into: %{} do
      {String.to_atom(k), v}
    end
  end
end
