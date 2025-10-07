# lib/stackoverflow_clone_web/router.ex
defmodule StackoverflowCloneWeb.Router do
  use StackoverflowCloneWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {StackoverflowCloneWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_user_fingerprint
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Public routes
  scope "/", StackoverflowCloneWeb do
    pipe_through :browser

    # Main search page
    live "/", SearchLive, :index
    live "/search", SearchLive, :search
  end

  # Development routes
  if Application.compile_env(:stackoverflow_clone, :dev_routes) do
    # Enable LiveDashboard in development
    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard",
        metrics: StackoverflowCloneWeb.Telemetry,
        ecto_repos: [StackoverflowClone.Repo]

      # # Mailbox for viewing emails in development
      # forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # Custom plug to add user fingerprint to session
  defp put_user_fingerprint(conn, _opts) do
    if get_session(conn, :user_fingerprint) do
      conn
    else
      fingerprint = generate_fingerprint(conn)
      put_session(conn, :user_fingerprint, fingerprint)
    end
  end

  defp generate_fingerprint(conn) do
    user_agent = get_req_header(conn, "user-agent") |> Enum.at(0, "")
    remote_ip = conn.remote_ip |> :inet.ntoa() |> to_string()

    :crypto.hash(:sha256, "#{user_agent}_#{remote_ip}")
    |> Base.encode16(case: :lower)
    |> String.slice(0..31)
  end
end
