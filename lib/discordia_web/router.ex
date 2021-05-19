defmodule DiscordiaWeb.Router do
  use DiscordiaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DiscordiaWeb do
    pipe_through :browser

    get "/", SessionController, :new
    get "/:id", GameController, :show
    resources "/game", GameController, only: [:create]
    resources "/session", SessionController, only: [:create]
  end
end
