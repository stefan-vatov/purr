defmodule PurrWeb.PageController do
  use PurrWeb, :controller

  def index(conn, _params) do
    repos =
      Enum.filter(GenServer.call(Purr.MainServer, :get_data), fn repo ->
        length(repo[:prs]) > 0
      end)

    render(conn, "index.html", repos: repos)
  end
end
