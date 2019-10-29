defmodule Doorman do

  def subscribe() do
    Doorman.PubSub.subscribe()
    Doorman.Server.broadcast_snapshot()
  end

end

