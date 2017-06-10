defmodule Discordia.GameSupervisor do
  @moduledoc """
  Supervisor for all games. It supervises a RoomSupervisor, which in turn
  supervises a GameServer worker and several PlayerServer workers.
  """

  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      supervisor(Discordia.RoomSupervisor, []),
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
