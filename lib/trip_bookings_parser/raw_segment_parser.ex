defmodule TripBookingsParser.RawSegmentParser do
  import NimbleParsec

  location = ascii_string([?A..?Z], 3)

  date = ascii_string([?0..?9, ?-], 10)

  time = ascii_string([?0..?9, ?:], 5)

  hotel_booking =
    string("Hotel")
    |> ignore(string(" "))
    |> concat(location)
    |> ignore(string(" "))
    |> concat(date)
    |> ignore(string(" -> "))
    |> concat(date)
    |> tag(:hotel)

  travel_booking =
    choice([string("Flight"), string("Train")])
    |> ignore(string(" "))
    |> concat(location)
    |> ignore(string(" "))
    |> concat(date)
    |> ignore(string(" "))
    |> concat(time)
    |> ignore(string(" -> "))
    |> concat(location)
    |> ignore(string(" "))
    |> concat(time)
    |> tag(:travel)

  booking =
    ignore(string("SEGMENT: "))
    |> choice([travel_booking, hotel_booking])

  empty_line = string("\n")

  reservation_line = string("RESERVATION\n")

  defparsec(:parse_segment, choice([ignore(empty_line), ignore(reservation_line), booking]))

  defparsec(:parse_base_location, concat(string("BASED: "), location))
end
