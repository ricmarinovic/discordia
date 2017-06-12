defmodule Discordia.Player do
  @moduledoc """
  Holds the state of a single player.
  """

  use GenServer

  alias Discordia.GameServer

  def start_link(game, player) do
    {:ok, _} = GenServer.start_link(__MODULE__, %{cards: []},
        name: via(game, player))
  end

  def via(game, player), do: {:global, "@#{game}:#{player}"}

  def cards(game, player), do: GenServer.call(via(game, player), :cards)

  def draws(game, player, quantity \\ 1) do
    for _ <- 1..quantity do
      GenServer.call(via(game, player),
        {:put_card, GameServer.draw_card(game)})
    end
  end

  def remove_card(game, player, card) do
    GenServer.cast(via(game, player), {:remove_card, card})
  end

  def has_card(game, player, [{key, value}]) do
    cards = cards(game, player)
    Enum.any?(cards, fn(card) -> Map.get(card, key) == value end)
  end
  def has_card(game, player, card) do
    # TODO: handle the case that a player plays a black card
    if card in cards(game, player) do
      {:ok, card}
    else
      {:error, "The player doesn't have the card."}
    end
  end

  def set_cards(game, player, cards) do
    GenServer.cast(via(game, player), {:set_cards, cards})
  end

  # Callbacks

  def handle_call(:cards, _from, state) do
    {:reply, state.cards, state}
  end
  def handle_call({:put_card, card}, _from, state) do
    {:reply, card, %{state | cards: [card | state.cards]}}
  end

  def handle_cast({:remove_card, card}, state) do
    {:noreply, %{state | cards: state.cards -- [card]}}
  end
  # TODO: Remove! For tests only
  def handle_cast({:set_cards, cards}, _state) do
    {:noreply, %{cards: cards}}
  end
end
