defmodule TripBookingsParser.Segments do
  @moduledoc false

  alias TripBookingsParser.Segments.Hotel
  alias TripBookingsParser.Segments.Travel

  @type segment :: Hotel.t() | Travel.t()

  @spec from_raw_segment({:ok, [term], binary, map, term, pos_integer}) :: segment
  def from_raw_segment({:ok, [hotel: attributes], _, _, _, _}) do
    [_, location, start, stop] = attributes

    {:ok, hotel_segment} = Hotel.new(%{location: location, start: start, stop: stop})

    hotel_segment
  end

  def from_raw_segment({:ok, [travel: attributes], _, _, _, _}) do
    [type, from, start_date, start_time, to, stop_time] = attributes

    {:ok, start_datetime} = NaiveDateTime.from_iso8601("#{start_date} #{start_time}:00")

    {:ok, stop_datetime} = NaiveDateTime.from_iso8601("#{start_date} #{stop_time}:00")

    schema_attributes = %{
      type: type,
      from: from,
      to: to,
      start: start_datetime,
      stop: stop_datetime
    }

    {:ok, travel_segment} = Travel.new(schema_attributes)

    travel_segment
  end

  @spec compare(segment, segment) :: boolean
  def compare(%Travel{start: a}, %Travel{start: b}) do
    case NaiveDateTime.compare(a, b) do
      :gt -> true
      :eq -> true
      :lt -> false
    end
  end

  def compare(%Travel{start: a}, %Hotel{start: b}) do
    a = NaiveDateTime.to_date(a)

    case Date.compare(a, b) do
      :gt -> true
      :lt -> false
      :eq -> false
    end
  end

  def compare(%Hotel{start: a}, %Travel{start: b}) do
    b = NaiveDateTime.to_date(b)

    case Date.compare(a, b) do
      :eq -> true
      :gt -> true
      :lt -> false
    end
  end

  def compare(%Hotel{start: a}, %Hotel{start: b}) do
    case Date.compare(a, b) do
      :gt -> true
      :eq -> true
      :lt -> false
    end
  end
end
