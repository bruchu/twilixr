defmodule Twilixr.Router do
  use Twilixr.Web, :router

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

  scope "/", Twilixr do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

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
