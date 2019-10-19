defmodule Doorman do

  def nodes() do
    Doorman.Server.nodes()
  end

  def subscribe() do
    Doorman.PubSub.subscribe()
  end


end
