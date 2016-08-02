defmodule Twilixr.SmsController do
	require Logger

  use Twilixr.Web, :controller
  alias Twilixr.Sms
 
  def index(conn, %{"Body" => song, "From" => from, "To" => to}) do
    Logger.info song
    Logger.info to
    Logger.info from
    Task.start_link(fn -> search_spotify(song, %{from: from, to: to}) end)
    conn
    |> send_resp(200, "")
   end
 
  defp search_spotify(song, twilio_data) do
    Twilixr.Spotify.search(song, twilio_data)
  end
end