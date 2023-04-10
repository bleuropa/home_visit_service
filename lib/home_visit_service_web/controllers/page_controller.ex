defmodule HomeVisitServiceWeb.PageController do
  use HomeVisitServiceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
