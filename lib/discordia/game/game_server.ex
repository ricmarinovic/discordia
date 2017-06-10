defmodule Discordia.GameServer do
  @moduledoc """
  Holds the state of a single game.
  """

  use GenServer

  def start_link(game, players) do
    GenServer.start_link(__MODULE__,
      %{
        players: players,
        deck: Discordia.Dealer.new_deck(),
        turn: 0,
        current_player: nil,
        current_card: nil
      }, name: via(game))
  end

  def via(game), do: {:global, "@#{game}"}

  # Players

  def players(game), do: GenServer.call(via(game), :players)

  def current_player(game), do: GenServer.call(via(game), :current_player)

  def current_player(game, player) do
    GenServer.cast(via(game), {:current_player, player})
  end

  # Deck

  def draw_card(game), do: GenServer.call(via(game), :draw_card)

  def current_card(game) do
    GenServer.call(via(game), :current_card)
  end
  def current_card(game, card) do
    GenServer.cast(via(game), {:current_card, card})
  end

  # Turn

  def current_turn(game), do: GenServer.call(via(game), :turn)

  def inc_turn(game), do: GenServer.call(via(game), :inc_turn)

  # Callbacks

  def handle_call(:players, _from, state) do
    {:reply, state.players, state}
  end
  def handle_call(:current_card, _from, state) do
    {:reply, state.current_card, state}
  end
  def handle_call(:draw_card, _from, state = %{deck: [card | rest]}) do
    {:reply, card, %{state | deck: rest}}
  end
  def handle_call(:turn, _from, state) do
    {:reply, state.turn, state}
  end
  def handle_call(:inc_turn, _from, state = %{turn: turn}) do
    {:reply, turn + 1, %{state | turn: turn + 1}}
  end
  def handle_call(:current_player, _from, state) do
    {:reply, state.current_player, state}
  end

  def handle_cast({:current_player, player}, state) do
    {:noreply, %{state | current_player: player}}
  end
  def handle_cast({:current_card, card}, state) do
    {:noreply, %{state | current_card: card}}
  end
end
