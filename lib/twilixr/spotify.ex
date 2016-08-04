defmodule Twilixr.Spotify do

  @process Twilixr.Spotify.Query
  @supervisor Twilixr.Spotify.Supervisor
  @ngrok_url Application.get_env(:twilixr, Twilixr.Endpoint)[:external_url] <> "/twiml?song="

  alias ExTwilio

  def start_link(proc, song, twilio_data, query_ref, owner) do
    proc.start_link(song, twilio_data, query_ref, owner)
  end

  def search(song, twilio_data) do
    IO.puts("Song " <> song)
    IO.puts("twilio_data #{inspect(twilio_data)}")
    song
    |> spawn_search(twilio_data)
    |> await_results
  end

  def spawn_search(song, twilio_data) do
    query_ref = make_ref()
    opts = [@process, song, twilio_data, query_ref, self()]
    {:ok, pid} = Supervisor.start_child(@supervisor, opts)
    monitor_ref = Process.monitor(pid)
    {pid, monitor_ref, query_ref}
  end

  defp await_results(process) do
    timeout = 9000
    timer = Process.send_after(self(), :timedout, timeout)
    results = await_result(process, "", :infinity)
    cleanup(timer)
    results
  end

  defp await_result(query_process, _result, _timeout) do
    {pid, monitor_ref, query_ref} = query_process
    IO.puts('await_result')
    receive do
      {msg} -> IO.puts msg
      {:results, ^query_ref, result, twilio_data} ->
        Process.demonitor(monitor_ref, [:flush])
        notify_success(result, twilio_data)
      {:DOWN, ^monitor_ref, :process, ^pid, _reason} ->
        # some kind of error logging
        IO.puts("oops, down")
        IO.puts(_reason)
      :timedout ->
        kill(pid, monitor_ref)
        IO.puts("oops, timedout")
        #some kind of error logging
    end
  end

  defp notify_success(nil, %{from: from, to: to}) do
    ExTwilio.Message.create([
      From: to,
      To: from,
      Body: "Sorry, I couldn't find your song on Spotify"
    ])
  end

  # make sure you are using your prod api credentials to make
  # a real call
  defp notify_success(preview_url, %{from: from, to: to}) do

    IO.puts("here is your preview_url #{preview_url}")
    IO.puts("from: #{from}")
    IO.puts("to: #{to}")
    result = ExTwilio.Message.create([
      From: to,
      To: from,
      Body: "Your clip is on the way!"
    ])

    IO.puts("Message.create result=#{inspect(result)}")

    result = ExTwilio.Call.create([
      From: to,
      To: from,
      Url: @ngrok_url <> "#{URI.encode_www_form(preview_url)}"
    ])
    IO.puts("Call.create result=#{inspect(result)}")
    result
  end

  defp kill(pid, ref) do
    Process.demonitor(ref, [:flush])
    Process.exit(pid, :kill)
  end

  defp cleanup(timer) do
    :erlang.cancel_timer(timer)
    receive do
      :timedout -> :ok
    after
      0 -> :ok
    end
  end

end
