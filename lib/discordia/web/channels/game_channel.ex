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
    game = socket.assigns.room
    assign(socket, :players, players)

    case Game.start(game, players) do
      :ok ->
        broadcast!(socket, "game_started", %{})
      _ ->
        broadcast!(socket, "game_stopped", %{})
    end

    {:noreply, socket }
  end

  def handle_in("game_info", _, socket) do
    broadcast!(socket, "game_info", game_info(socket))
    game = socket.assigns.room
    player = socket.assigns.username
    payload = %{cards: Player.cards(game, player)}
    {:reply, {:ok, payload}, socket}
  end

  def handle_in("play_card", [card, next], socket) do
    game = socket.assigns.room
    player = socket.assigns.username

    card = convert(card)

    Game.play(game, player, card, next)
    broadcast!(socket, "game_info", game_info(socket))

    {:noreply, socket}
  end

  def handle_in("draw_card", _, socket) do
    game = socket.assigns.room
    player = socket.assigns.username
    Game.draw(game, player)
    {:noreply, socket}
  end

  defp game_info(socket) do
    game = socket.assigns.room

    %{
      current_player: GameServer.current_player(game),
      current_card: GameServer.current_card(game)
    }
  end

  defp convert(card) do
    for {k, v} <- card, into: %{} do
      {String.to_atom(k), v}
    end
  end
end
