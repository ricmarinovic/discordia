defmodule Discordia.Game do
  @moduledoc """
  Controls the flow of the game.
  """

  import Discordia.GameServer, except: [start_link: 2, via: 1]
  import Discordia.Player, except: [start_link: 2, via: 2]

  @initial_cards 7

  @doc """
  Starts a game, provided a name for the game and a list of players.
  """
  def start(name, players) do
    {:ok, _} = Supervisor.start_child(Discordia.GameSupervisor, [name, players])
    first_turn(name)
  end

  @doc """
  The `player` plays a `card` and another turn is started.
  """
  def play(_game, _player, %{color: "black"}) do
    {:error, "Must provide the next card color."}
  end

  def play(game, player, card, next \\ nil) do
    with  {:ok, _status} <- check_status(game, card),
          {:ok, _player} <- allowed_to_play(game, player, card),
          {:ok, _card}   <- has_card(game, player, card)
    do
      remove_card(game, player, card) # Remove card from player's hand

      case card do
        %{color: "black"} ->
          make_play(game, player, card, next)
        _ ->
          make_play(game, player, card)
      end

      if Enum.empty?(cards(game, player)) do
        status(game, {:ended, player})
        # :ok = Discordia.RoomSupervisor.stop(game)
      end

      info(game, Mix.env) # TODO: Remove info

      {:ok, card}
    end
  end

  @doc """
  The `player` draws a card from the deck. It is still his turn.
  """
  def draw(game, player) do
    with {:ok, _player} <- allowed_to_draw(game, player) do
      [card] = draws(game, player)
      next_player(game)
      info(game, Mix.env) # TODO: Remove info
      {:ok, card}
    end
  end

  defp check_status(game, card) do
    status = status(game) # {:plus_hold, +2}
    value = card.value

    case status do
      {:plus_hold, ^value, _} ->
        {:ok, status}
      {:plus_hold, status_value, _} ->
        {:error, "Player must play a #{status_value} card."}
      {:ended, _} ->
        {:error, "Game is over."}
      {_, _} ->
        {:ok, status}
    end
  end

  defp allowed_to_play(game, player, card) do
    current_player = current_player(game)
    current_card = current_card(game)
    %{color: color, value: value} = current_card
    next = Map.get(current_card, :next)

    case {player, card} do
      {^current_player, %{color: "black"}} ->
        {:ok, card}
      {^current_player, %{value: ^value}} ->
        {:ok, card}
      {^current_player, %{color: ^color}} ->
        {:ok, card}
      {^current_player, %{color: ^next}} ->
        {:ok, card}
      {_, %{value: ^value, color: ^color}} ->
        cut(game, player)
        {:ok, card}
      {^current_player, _} ->
        {:error, "Card does not match."}
      _ ->
        {:error, "Not this player's turn."}
    end
  end

  defp allowed_to_draw(game, player) do
    case current_player(game) do
      ^player ->
        {:ok, player}
      _ ->
        {:error, "Not this player's turn."}
    end
  end

  defp first_turn(game) do
    # Draw and put the first card on the table
    put_card(game, draw_card(game))

    # Each player gets 7 cards
    for player <- players(game) do
      draws(game, player, @initial_cards)
    end

    info(game, Mix.env) # TODO: Remove info
  end

  # TODO: Remove info
  defp info(game, env) when env == :dev do
    case status(game) do
      {:ended, player} ->
        IO.puts "Game is over. Winner: #{player}"
        :ok = Discordia.RoomSupervisor.stop(game)
      _ ->
        IO.puts "\nTurn #{current_turn(game)}"
        IO.puts "Current card: "
        IO.inspect current_card(game)
        current_player = current_player(game)
        IO.puts "Current player #{current_player}"
        for player <- players(game) do
          IO.puts "Player #{player}: #{length cards(game, player)} cards"
          IO.inspect cards(game, player)
        end
    end

    :ok
  end
  defp info(_game, _env), do: nil
end
