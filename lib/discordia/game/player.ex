defmodule Discordia.Player do
  @enforce_keys [:name]
  defstruct [:name]

  @spec new(String.t()) :: Discordia.Player.t()
  def new(name) do
    %__MODULE__{name: name}
  end
end
