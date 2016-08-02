defmodule Twilixr.TwimlController do
  use Twilixr.Web, :controller

  alias Twilixr.Twiml

  def index(conn, %{"song" => song}) do
    IO.puts("song -> " <> song)
    render(conn, "index.html", song: song)
  end
end

