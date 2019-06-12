defmodule Discordia.PlayerServer do
  use GenServer

  @timeout :timer.minutes(30)

  @doc """
  Lists all player's cards.
  """
  def list_cards(game_name, player_name) do
    GenServer.call(via_tuple(game_name, player_name), :list_cards)
  end

  @doc """
  Add given card to player's cards.
  """
  def add_card(game_name, player_name, card) do
    GenServer.cast(via_tuple(game_name, player_name), {:add_card, card})
  end

  @doc """
  Remove given card from player's cards.
  """
  def remove_card(game_name, player_name, card) do
    GenServer.cast(via_tuple(game_name, player_name), {:remove_card, card})
  end

  @doc """
  Checks whether the player has the given card.
  """
  @spec has_card?(String.t(), String.t(), map) :: {:ok, map} | {:error, <<_::272>>}
  def has_card?(game_name, player_name, card) do
    if card in list_cards(game_name, player_name) do
      {:ok, card}
    else
      {:error, "The player doesn't have that card."}
    end
  end

  def start_link(game_name, player_name) do
    GenServer.start_link(__MODULE__, {player_name}, name: via_tuple(game_name, player_name))
  end

  defp via_tuple(game_name, player_name) do
    {:via, Registry, {Discordia.PlayerRegistry, "#{game_name}:#{player_name}"}}
  end

  @impl GenServer
  def init({player_name}) do
    player = %{name: player_name, cards: []}
    {:ok, player, @timeout}
  end

  @impl GenServer
  def handle_call(:list_cards, _from, player) do
    {:reply, player.cards, player}
  end

  @impl GenServer
  def handle_cast({:add_card, card}, player) do
    {:noreply, %{player | cards: [card | player.cards]}}
  end

  def handle_cast({:remove_card, card}, player) do
    {:noreply, %{player | cards: player.cards -- [card]}}
  end
end
