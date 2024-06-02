defmodule ClaysWeb.OverviewController do
  use ClaysWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
