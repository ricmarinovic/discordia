defmodule DiscordiaWeb.SessionController do
  use DiscordiaWeb, :controller

  alias Discordia.Game

  @spec new(conn, params) :: conn
  def new(conn, _params) do
    render(conn, "new.html")
  end

  @spec create(conn, params) :: conn
  def create(conn, %{"player" => %{"name" => name}}) do
    player = Discordia.Player.new(name)

    conn
    |> put_session(:current_player, player)
    |> redirect_back_or_new_game()
  end

  defp redirect_back_or_new_game(conn) do
    path =
      get_session(conn, :return_to) ||
        Routes.game_path(conn, :show, Game.generate_game_name())

    conn
    |> put_session(:return_to, nil)
    |> redirect(to: path)
  end
end
