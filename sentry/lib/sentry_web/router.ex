defmodule SentryWeb.Router do
  use SentryWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SentryWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/camera", SentryWeb do
    get "/", CameraController, :index

    forward "/video.mjpg", Camera.Streamer

  end


  # Other scopes may use custom stacks.
  # scope "/api", SentryWeb do
  #   pipe_through :api
  # end
end
