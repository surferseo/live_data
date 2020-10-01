defmodule PhoenixLivedataTodomvcWeb.PageController do
  use PhoenixLivedataTodomvcWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
