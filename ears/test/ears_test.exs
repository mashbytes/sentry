defmodule EarsTest do
  use ExUnit.Case
  doctest Ears

  test "greets the world" do
    assert Ears.hello() == :world
  end
end
