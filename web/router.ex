defmodule Twilixr.Router do
  use Twilixr.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    # plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :csrf do
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Twilixr do
    pipe_through [:browser, :csrf]

    get "/", PageController, :index

  end

  scope "/", Twilixr do
    pipe_through :browser

    post "/twiml", TwimlController, :index
  end

  scope "/api", Twilixr do
    pipe_through :api

    post "/sms", SmsController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", Twilixr do
  #   pipe_through :api
  # end
end
