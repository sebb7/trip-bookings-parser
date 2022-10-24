defmodule TripBookingsParser do
  @moduledoc false

  alias TripBookingsParser.Segments
  alias TripBookingsParser.Segments.Hotel
  alias TripBookingsParser.Segments.Travel
  alias TripBookingsParser.RawSegmentParser
  alias TripBookingsParser.ItineraryOrganizer

  @spec to_trip_plan_format(Path.t()) :: [String.t()]
  def to_trip_plan_format(path) do
    base_location = get_base_location(path)

    path
    |> File.stream!()
    |> Stream.drop(1)
    |> Stream.map(&RawSegmentParser.parse_segment/1)
    |> Stream.filter(&not_empty?/1)
    |> Stream.map(&Segments.from_raw_segment/1)
    |> Enum.sort(&Segments.compare/2)
    |> Enum.reverse()
    |> ItineraryOrganizer.add_trip_labels(base_location)
    |> to_list_of_strings()
    |> adjust_beginning()
  end

  defp get_base_location(path) do
    [{:ok, ["BASED: ", base_location], _, _, _, _}] =
      path
      |> File.stream!()
      |> Stream.take(1)
      |> Enum.map(&RawSegmentParser.parse_base_location/1)

    base_location
  end

  defp not_empty?({:ok, [], "", _, _, _}), do: false

  defp not_empty?(_), do: true

  defp to_list_of_strings(labeled_segments) do
    Enum.map(labeled_segments, &to_pretty/1)
  end

  defp to_pretty(%Travel{} = travel) do
    start_time = to_date_with_time(travel.start)
    stop_time = to_time(travel.stop)
    "#{travel.type} from #{travel.from} to #{travel.to} at #{start_time} to #{stop_time}\n"
  end

  defp to_pretty(%Hotel{} = hotel) do
    "Hotel at #{hotel.location} on #{hotel.start} to #{hotel.stop}\n"
  end

  defp to_pretty(string) do
    "\n#{string}\n"
  end

  defp to_date_with_time(datetime) do
    datetime
    |> NaiveDateTime.to_string()
    |> String.slice(0..15)
  end

  defp to_time(datetime) do
    datetime
    |> NaiveDateTime.to_time()
    |> Time.to_string()
    |> String.slice(0..4)
  end

  defp adjust_beginning([h | t]) do
    new_h = String.replace_leading(h, "\n", "")
    [new_h | t]
  end
end
