defmodule Plejady.Datetime do
  def format_datetime(nil), do: nil

  def format_datetime(datetime) do
    formatted(datetime, "d. MMMM yyyy") <> " v " <> formatted(datetime, "HH:mm")
  end

  defp formatted(datetime, format_string) do
    Plejady.Cldr.DateTime.to_string!(
      datetime |> DateTime.shift_zone!("Europe/Prague", Tz.TimeZoneDatabase),
      format: format_string
    )
  end
end
