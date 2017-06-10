defmodule Discordia.Application do
  @moduledoc false
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Discordia.Repo, []),
      # Start the endpoint when the application starts
      supervisor(Discordia.Web.Endpoint, []),
      supervisor(Discordia.GameSupervisor, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Discordia.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
