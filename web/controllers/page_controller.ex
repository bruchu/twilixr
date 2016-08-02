defmodule Twilixr.PageController do
  use Twilixr.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
