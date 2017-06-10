defmodule Discordia.PlayerServer do
  @moduledoc """
  Holds the state of a single player.
  """

  use GenServer

  def start_link(game, player) do
    GenServer.start_link(__MODULE__,
      %{
        cards: []
      }, name: via(game, player))
  end

  def via(game, player), do: {:global, "@#{game}:#{player}"}
end
