defmodule Eyes do

  def url() do
    port = Application.get_env(:picam, :http_port, 4001)
    ":#{port}/video.mjpg"
  end
end
