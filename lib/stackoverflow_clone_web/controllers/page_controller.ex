defmodule StackoverflowCloneWeb.PageController do
  use StackoverflowCloneWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
