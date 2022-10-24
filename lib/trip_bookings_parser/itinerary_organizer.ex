defmodule TripBookingsParser.ItineraryOrganizer do
  @moduledoc false

  alias TripBookingsParser.Segments.Hotel
  alias TripBookingsParser.Segments.Travel

  @day_in_seconds 86_400

  @type segment :: Hotel.t() | Travel.t()

  @doc """
  Traverse a list of segments and adds labels when a new trip is detected.

  Expects list of segments in ascending date order.

  Returns list of segments with labels in ascending date order.
  """
  @spec add_trip_labels([segment], String.t()) :: [segment | String.t()]
  def add_trip_labels(segments, base_location) do
    base_location
    |> add_trip_labels([], segments)
    |> Enum.reverse()
  end

  defp add_trip_labels(_base_location, processed_segments, []) do
    processed_segments
  end

  defp add_trip_labels(base_location, processed_segments, [
         %Hotel{} = current_hotel_segment | next_segments
       ]) do
    new_processed_segments = [current_hotel_segment | processed_segments]

    add_trip_labels(base_location, new_processed_segments, next_segments)
  end

  defp add_trip_labels(base_location, processed_segments, segments_to_process) do
    {travel_destination, travel_connection_segments, next_segments} =
      process_travel_connection(base_location, segments_to_process)

    new_processed_segments =
      case travel_destination == base_location do
        true ->
          travel_connection_segments ++ processed_segments

        false ->
          travel_connection_segments ++ ["TRIP to #{travel_destination}"] ++ processed_segments
      end

    add_trip_labels(base_location, new_processed_segments, next_segments)
  end

  defp process_travel_connection(base_location, [current_travel_segment | next_segments]) do
    process_travel_connection(
      base_location,
      current_travel_segment.from,
      current_travel_segment.to,
      [current_travel_segment],
      next_segments
    )
  end

  defp process_travel_connection(
         _base_location,
         _connection_start_location,
         connection_destination,
         connection_segments,
         []
       ) do
    {connection_destination, connection_segments, []}
  end

  defp process_travel_connection(
         _base_location,
         _connection_start_location,
         connection_destination,
         connection_segments,
         [%Hotel{} | _] = segments_to_process
       ) do
    {connection_destination, connection_segments, segments_to_process}
  end

  defp process_travel_connection(
         base_location,
         connection_start_location,
         connection_destination,
         [previous_travel | _] = connection_segments,
         [%Travel{} = current_travel | next_segments] = segments_to_process
       ) do
    case current_travel_is_part_of_connection?(
           base_location,
           connection_start_location,
           current_travel,
           previous_travel
         ) do
      true ->
        new_connection_segments = [current_travel | connection_segments]

        process_travel_connection(
          base_location,
          connection_start_location,
          current_travel.to,
          new_connection_segments,
          next_segments
        )

      false ->
        {connection_destination, connection_segments, segments_to_process}
    end
  end

  defp current_travel_is_part_of_connection?(
         base_location,
         base_location,
         %Travel{to: base_location},
         _
       ) do
    false
  end

  defp current_travel_is_part_of_connection?(
         _base_location,
         _connection_start_location,
         %Travel{start: current_travel_start},
         %Travel{stop: previous_travel_stop}
       ) do
    NaiveDateTime.diff(current_travel_start, previous_travel_stop) < @day_in_seconds
  end
end
