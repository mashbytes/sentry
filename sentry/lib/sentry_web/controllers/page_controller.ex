defmodule SentryWeb.PageController do
  use SentryWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
