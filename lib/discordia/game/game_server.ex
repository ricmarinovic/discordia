defmodule Discordia.GameServer do
  use GenServer

  require Logger

  alias Discordia.Game
  alias Discordia.PlayerServer, as: Player

  @timeout :timer.minutes(30)
  @initial_cards_count 7

  @doc """
  Returns information about the game.
  """
  def summary(game_name) do
    GenServer.call(via_tuple(game_name), :summary)
  end

  @doc """
  The player plays a card, putting it on the table.
  """
  def play_card(game_name, player_name, card) do
    GenServer.call(via_tuple(game_name), {:play_card, game_name, player_name, card})
  end

  @doc """
  The player draws a card from the deck.

  The card is removed from the deck. If the deck is empty, it will be filled by a new deck.
  The next player in the queue is to play. The game must be in progress (ok status).

  The player must have the card that he is trying to play.
  """
  def draw_card(game_name, player_name) do
    GenServer.call(via_tuple(game_name), {:draw_card, game_name, player_name})
  end

  @spec start_link(String.t(), String.t()) :: {:ok, pid} | {:error, any} | :ignore
  def start_link(game_name, players) do
    GenServer.start_link(__MODULE__, {game_name, players}, name: via_tuple(game_name))
  end

  defp via_tuple(game_name) do
    {:via, Registry, {Discordia.GameRegistry, "#{game_name}"}}
  end

  def game_pid(game_name) do
    game_name
    |> via_tuple()
    |> GenServer.whereis()
  end

  @impl GenServer
  def init({game_name, players}) do
    game =
      Enum.reduce(players, Game.new(game_name, players), fn player_name, game ->
        Player.start_link(game_name, player_name)

        Enum.reduce(1..@initial_cards_count, game, fn _, game ->
          {card, game} = Game.draw_card(game)
          Player.add_card(game_name, player_name, card)
          game
        end)
      end)

    {:ok, game, @timeout}
  end

  @impl GenServer
  def handle_call(:summary, _from, game) do
    players_summary =
      Enum.map(game.players, fn player_name ->
        %{player_name => Player.list_cards(game.name, player_name)}
      end)

    summary = %{
      name: game.name,
      players: players_summary,
      status: game.status,
      table_card: Game.table_card(game),
      current_player: Game.current_player(game)
    }

    {:reply, summary, game}
  end

  def handle_call({:play_card, game_name, player_name, card}, _from, game) do
    with {:ok, :normal} <- game.status,
         {:ok, ^card} <- Player.has_card?(game_name, player_name, card),
         {:ok, game} <- Game.play_card(game, player_name, card) do
      Player.remove_card(game_name, player_name, card)

      case Player.list_cards(game_name, player_name) do
        [] ->
          game = %{game | status: {:winner, player_name}}
          {:reply, card, game}

        _ ->
          {:reply, card, game}
      end
    else
      {:error, _reason} = error ->
        {:reply, error, game}

      {:winner, player_name} ->
        {:reply, game_over_error(player_name), game}
    end
  end

  def handle_call({:draw_card, game_name, player_name}, _from, game) do
    with {:ok, :normal} <- game.status,
         ^player_name <- Game.current_player(game) do
      {card, game} = Game.draw_card(game)
      Player.add_card(game_name, player_name, card)
      game = Game.rotate_players(game)
      {:reply, card, game}
    else
      {:winner, player_name} ->
        {:reply, game_over_error(player_name), game}

      _ ->
        {:reply, {:error, "Not player's turn."}, game}
    end
  end

  @impl GenServer
  def handle_info(:timeout, game) do
    Logger.info("Terminating game #{game.name} due to timeout.")
    {:stop, :normal, game}
  end

  defp game_over_error(player_name) do
    {:error, "Game over. Winner #{player_name}"}
  end
end
