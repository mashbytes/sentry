defmodule Ears.Sensor.Model.Test do
  use ExUnit.Case
  doctest Ears.Sensor.Model

  alias Ears.Sensor.Model

  test "new should default to offline state" do
    assert Model.new().state == :offline
  end

  test "new should default to nil gpio" do
    assert Model.new().gpio == nil
  end

  test "new should set timestamp to something (non nil)" do
    assert Model.new().since != nil
  end

  test "merge gpio should update gpio" do
    model = Model.new()
      |> Model.merge_gpio(:foo)
    assert model.gpio == :foo
  end

  test "merge state should not update state or timestamp when state is same" do
    {:ok, since, 0} = DateTime.from_iso8601("2015-01-23T23:50:07Z")
    model = Model.new(nil, :offline, since)
      |> Model.merge_state(:offline, DateTime.utc_now())
    assert model.since == since
    assert model.state == :offline
  end

  test "merge state should update state and timestamp when state is different" do
    {:ok, since, 0} = DateTime.from_iso8601("2015-01-23T23:50:07Z")
    now = DateTime.utc_now()
    model = Model.new(nil, :offline, since)
      |> Model.merge_state(:noisy, now)
    assert model.since == now
    assert model.state == :noisy
  end

end
