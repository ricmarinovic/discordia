defmodule Discordia.GameServer do
  @moduledoc """
  Holds the state of a single game.
  """

  use GenServer

  alias Discordia.Dealer

  def start_link(game, players) do
    {:ok, _} = GenServer.start_link(__MODULE__, [game, players],
        name: via(game))
  end

  def via(game), do: {:global, "@#{game}"}

  def init([_game, players]) do
    state = %{
      players: players,
      deck: Dealer.new_deck(),
      turn: 0,
      player_queue: players,
      card_pile: []
    }

    {:ok, state}
  end

  # Players

  def players(game), do: GenServer.call(via(game), :players)

  def player_queue(game), do: GenServer.call(via(game), :player_queue)

  def current_player(game), do: GenServer.call(via(game), :current_player)

  def next_player(game), do: GenServer.call(via(game), :next_player)

  def reverse_queue(game), do: GenServer.cast(via(game), :reverse_queue)

  # Deck

  def deck(game), do: GenServer.call(via(game), :deck)

  def current_card(game), do: GenServer.call(via(game), :current_card)

  def draw_card(game), do: GenServer.call(via(game), :draw_card)

  def play_card(game, card), do: GenServer.cast(via(game), {:play_card, card})

  # Turn

  def current_turn(game), do: GenServer.call(via(game), :turn)

  def inc_turn(game), do: GenServer.call(via(game), :inc_turn)

  # Callbacks

  def handle_call(:players, _from, state) do
    {:reply, state.players, state}
  end
  def handle_call(:player_queue, _from, state = %{player_queue: queue}) do
    {:reply, queue, state}
  end
  def handle_call(:current_player, _from, state = %{player_queue: [player | _]}) do
    {:reply, player, state}
  end
  def handle_call(:next_player, _from,
        state = %{player_queue: [prev | rest]}) do
    [next | _] = rest
    {:reply, next, %{state | player_queue: rest ++ [prev]}}
  end
  def handle_call(:current_card, _from, state = %{card_pile: []}) do
    %{deck: [card | _]} = state
    {:reply, card, %{state | card_pile: [card]}}
  end
  def handle_call(:current_card, _from, state = %{card_pile: [current | _]}) do
    {:reply, current, state}
  end
  def handle_call(:draw_card, _from, state = %{deck: []}) do
    [card | rest] = Dealer.new_deck()
    {:reply, card, %{state | deck: rest}}
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
  def handle_call(:deck, _from, state) do
    {:reply, state.deck, state}
  end

  def handle_cast(:reverse_queue, state) do
    {:noreply, Enum.reverse(state)}
  end
  def handle_cast({:play_card, card}, state) do
    {:noreply, %{state | card_pile: [card | state.card_pile]}}
  end
end
