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

    get "/", GameController, :new
    resources "/game", GameController, only: [:new, :create, :show]
    resources "/session", SessionController, only: [:new, :create, :delete], singleton: true
  end

  # Other scopes may use custom stacks.
  # scope "/api", DiscordiaWeb do
  #   pipe_through :api
  # end
end
