defmodule Discordia.PlayerServer do
  @moduledoc """
  Holds the state of a single player.
  """

  use GenServer

  def start_link(game, player) do
    GenServer.start_link(__MODULE__, %{cards: []}, name: via(game, player))
  end

  def via(game, player), do: {:global, "@#{game}:#{player}"}

  def cards(game, player), do: GenServer.call(via(game, player), :cards)

  def player_draws(game, player, quantity) do
    for _ <- 1..quantity do
      GenServer.cast(via(game, player),
        {:put_card, Discordia.GameServer.draw_card(game)})
    end
  end

  def remove_card(game, player, card) do
    GenServer.cast(via(game, player), {:remove_card, card})
  end

  # Callbacks
  def handle_call(:cards, _from, state) do
    {:reply, state.cards, state}
  end

  def handle_cast({:put_card, card}, state) do
    {:noreply, %{state | cards: [card | state.cards]}}
  end
  def handle_cast({:remove_card, card}, state) do
    {:noreply, %{state | cards: state.cards -- [card]}}
  end
end
