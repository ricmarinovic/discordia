defmodule Discordia.GameServer do
  @moduledoc """
  Holds the state of a single game.
  """

  use GenServer

  alias Discordia.{Player, Dealer}

  def start_link(game, players) do
    {:ok, _} = GenServer.start_link(__MODULE__, [game, players],
        name: via(game))
  end

  def via(game), do: {:global, "@#{game}"}

  def init([_game, players]) do
    state = %{
      players: players,
      player_queue: players,
      deck: Dealer.new_deck(),
      history: [%{
        turn: 0,
        card: nil,
        player: nil,
      }],
      status: :started
    }

    {:ok, state}
  end

  # Players

  def players(game), do: GenServer.call(via(game), :players)

  def player_queue(game), do: GenServer.call(via(game), :queue)

  def current_player(game), do: GenServer.call(via(game), :current_player)

  def next_player(game), do: GenServer.call(via(game), :next_player)

  def whois_next(game), do: GenServer.call(via(game), :whois_next)

  def reverse(game), do: GenServer.cast(via(game), :reverse)

  def block(game), do: GenServer.cast(via(game), :block)

  # Deck

  def deck(game), do: GenServer.call(via(game), :deck)

  def current_card(game), do: GenServer.call(via(game), :current_card)

  def draw_card(game), do: GenServer.call(via(game), :draw_card)

  def put_card(game, card, next \\ nil) do
    case card do
      %{color: "black"} ->
        next = next || Dealer.initial_color()
        GenServer.cast(via(game), {:put_card, %{card | next: next}})
      _ ->
        GenServer.cast(via(game), {:put_card, card})
    end
  end

  def make_play(game, player, card) do
    case card do
      %{value: "reverse"} ->
        reverse(game)
      %{value: "block"} ->
        block(game)
      %{value: value = "+" <> quantity} ->
        if Player.has_card(game, next = whois_next(game), value: value) do
          status(game, {:plus_hold, value})
        else
          Player.draws(game, next, String.to_integer(quantity))
          block(game)
        end
      _ ->
        next_player(game)
    end

    play = %{
      turn: current_turn(game) + 1,
      card: card,
      player: player,
    }

    GenServer.cast(via(game), {:make_play, play})
  end

  # Turn

  def current_turn(game), do: GenServer.call(via(game), :turn)

  def history(game), do: GenServer.call(via(game), :history)

  def status(game), do: GenServer.call(via(game), :status)
  def status(game, new_status), do: GenServer.cast(via(game), {:status, new_status})

  # Callbacks

  def handle_call(:players, _from, state) do
    {:reply, state.players, state}
  end
  def handle_call(:queue, _from, state = %{player_queue: queue}) do
    {:reply, queue, state}
  end
  def handle_call(:current_player, _from, state = %{player_queue: [player | _]}) do
    {:reply, player, state}
  end
  def handle_call(:next_player, _from, state = %{player_queue: [prev | rest]}) do
    [next | _] = rest
    {:reply, next, %{state | player_queue: rest ++ [prev]}}
  end
  def handle_call(:whois_next, _from, state = %{player_queue: [_, next | _]}) do
    {:reply, next, state}
  end
  def handle_call(:current_card, _from, state = %{history: [last | _]}) do
    {:reply, last.card, state}
  end
  def handle_call(:draw_card, _from, state = %{deck: []}) do
    [card | rest] = Dealer.new_deck()
    {:reply, card, %{state | deck: rest}}
  end
  def handle_call(:draw_card, _from, state = %{deck: [card | rest]}) do
    {:reply, card, %{state | deck: rest}}
  end
  def handle_call(:deck, _from, state) do
    {:reply, state.deck, state}
  end
  def handle_call(:turn, _from, state = %{history: [last | _]}) do
    {:reply, last.turn, state}
  end
  def handle_call(:history, _from, state = %{history: history}) do
    {:reply, history, state}
  end
  def handle_call(:status, _from, state = %{status: status}) do
    {:reply, status, state}
  end

  def handle_cast(:reverse, state = %{player_queue: queue}) do
    {:noreply, %{state | player_queue: Enum.reverse(queue)}}
  end
  def handle_cast(:block, state = %{player_queue: queue}) do
    [current, blocked | rest] = queue
    {:noreply, %{state | player_queue: rest ++ [current, blocked]}}
  end
  def handle_cast({:put_card, card}, state = %{history: [last | rest]}) do
    {:noreply, %{state | history: [%{last | card: card} | rest]}}
  end
  def handle_cast({:make_play, play}, state = %{history: old}) do
    {:noreply, %{state | history: [play | old]}}
  end
  def handle_cast({:status, new_status}, state) do
    {:noreply, %{state | status: new_status}}
  end
end
