defmodule Twilixr.Spotify.Query do

  @spotify_url "https://api.spotify.com/v1/search?type=track&q="

  def start_link(song, twilio_data, query_ref, owner) do
    Task.start_link(__MODULE__, :fetch, [song, twilio_data, query_ref, owner])
  end

  def fetch(song, twilio_data, query_ref, owner) do
    case String.lstrip(song) do
      "" ->
        send_results(nil, twilio_data, query_ref, owner)
      _ ->
        song
        |> String.lstrip |> String.rstrip
        |> fetch_from_spotify
        |> send_results(twilio_data, query_ref, owner)
    end
  end

  defp send_results(nil, twilio_data, query_ref, owner) do
    send(owner, {:results, query_ref, nil, twilio_data})
  end

  defp send_results(preview_url, twilio_data, query_ref, owner) do
    send(owner, {:results, query_ref, preview_url, twilio_data})
  end

  defp fetch_from_spotify(query_str) do
    # IO.puts("fetch_from_spotify #1")
    {:ok, %{:body => response}} =
      HTTPoison.get(@spotify_url <> URI.encode(query_str))
    # IO.puts("fetch_from_spotify #2")
    {:ok, body} = Poison.decode(response)
    IO.puts("fetch_from_spotify #3")
    IO.puts("body: #{inspect(body)}")
    body
    |> get_in(["tracks", "items"])
    |> List.first
    |> get_in(["preview_url"])
  end

end
