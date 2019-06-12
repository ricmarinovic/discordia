defmodule DiscordiaWeb.SessionController do
  use DiscordiaWeb, :controller

  @spec new(conn, params) :: conn
  def new(conn, _params) do
    render(conn, "new.html")
  end

  @spec create(conn, params) :: conn
  def create(conn, %{"player" => %{"name" => player_name}}) do
    conn
    |> put_session(:current_player, player_name)
    |> redirect_back_or_new_game()
  end

  defp redirect_back_or_new_game(conn) do
    path =
      get_session(conn, :return_to) ||
        Routes.game_path(conn, :show, generate_game_name())

    conn
    |> put_session(:return_to, nil)
    |> redirect(to: path)
  end

  defp generate_game_name do
    name_length = 4

    name_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> binary_part(0, name_length)
  end
end
