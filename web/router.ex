defmodule MithrilBot.Router do
  use MithrilBot.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :guest do
    plug :accepts, ["json"]
    plug Plug.Parsers, parsers: [:json],
                       pass: ["application/json"],
                       json_decoder: Poison
  end

  scope "/", MithrilBot do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/login", MithrilBot do
    pipe_through :guest
    post "/", LoginController, :login_user
  end

  # Other scopes may use custom stacks.
  # scope "/api", MithrilBot do
  #   pipe_through :api
  # end
end
