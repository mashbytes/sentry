defmodule EyesTest do
  use ExUnit.Case
  doctest Eyes

  test "greets the world" do
    assert Eyes.hello() == :world
  end
end
