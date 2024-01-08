defmodule ElixirApiJwtWeb.PageController do
  use ElixirApiJwtWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
