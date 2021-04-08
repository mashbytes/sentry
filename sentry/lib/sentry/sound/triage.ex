defmodule Sentry.Interval do
  defstruct [:unit, :period]
end


defmodule Sentry.Sound.Triage do

  @interval %Sentry.Interval{unit: :seconds, period: 10}

  def status(alerts) do
    alerts
      |> with_signal(:noisy)
      |> in_interval(@interval)
      |> status_for
  end

  defp status_for(alerts) do

    case Enum.count(alerts) do
      x when x > 5 -> :red
      x when x > 2 -> :amber
      _ -> :green
    end
  end

  defp status_for(alerts) do
    :green
  end

  defp in_interval(alerts, interval) do
    cutoff = DateTime.add(DateTime.utc_now(), -interval.period, interval.unit)
    alerts
      |> Enum.filter(fn a -> a.date > cutoff end)
  end

  defp with_signal(alerts, signal) do
    alerts
      |> Enum.filter(fn a -> a.signal == signal end)
  end

end

