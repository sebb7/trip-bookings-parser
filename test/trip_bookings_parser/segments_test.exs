defmodule TripBookingsParser.SegmentsTest do
  use ExUnit.Case

  alias TripBookingsParser.Segments
  alias TripBookingsParser.Segments.Hotel
  alias TripBookingsParser.Segments.Travel

  describe "from_raw_segment/1" do
    test "returnes travel segment given valid attributes" do
      flight_segment_attributes = ["Flight", "SVQ", "2023-01-01", "20:40", "BCN", "23:30"]
      train_segment_attributes = ["Train", "SVQ", "2023-04-15", "09:30", "MAD", "11:00"]

      assert Segments.from_raw_segment(
               {:ok, [travel: flight_segment_attributes], nil, nil, nil, nil}
             ) ==
               %Travel{
                 type: "Flight",
                 from: "SVQ",
                 to: "BCN",
                 start: ~N[2023-01-01 20:40:00],
                 stop: ~N[2023-01-01 23:30:00]
               }

      assert Segments.from_raw_segment(
               {:ok, [travel: train_segment_attributes], nil, nil, nil, nil}
             ) ==
               %Travel{
                 type: "Train",
                 from: "SVQ",
                 to: "MAD",
                 start: ~N[2023-04-15 09:30:00],
                 stop: ~N[2023-04-15 11:00:00]
               }
    end

    test "returnes hotel segment given valid attributes" do
      hotel_segment_attributes = ["Hotel", "MAD", "2023-01-05", "2023-01-10"]

      assert Segments.from_raw_segment(
               {:ok, [hotel: hotel_segment_attributes], nil, nil, nil, nil}
             ) ==
               %Hotel{
                 location: "MAD",
                 start: ~D[2023-01-05],
                 stop: ~D[2023-01-10]
               }
    end
  end

  describe "compare/2" do
    setup do
      earlier_travel = %Travel{
        type: "Train",
        from: "SVQ",
        to: "MAD",
        start: ~N[2023-04-15 09:30:00],
        stop: ~N[2023-04-15 11:00:00]
      }

      later_travel = %Travel{
        type: "Train",
        from: "MAD",
        to: "WAW",
        start: ~N[2023-04-16 09:30:00],
        stop: ~N[2023-04-16 11:00:00]
      }

      earlier_hotel = %Hotel{
        location: "WAW",
        start: ~D[2023-04-15],
        stop: ~D[2023-04-15]
      }

      later_hotel = %Hotel{
        location: "WAW",
        start: ~D[2023-04-16],
        stop: ~D[2023-04-16]
      }

      [
        earlier_travel: earlier_travel,
        later_travel: later_travel,
        earlier_hotel: earlier_hotel,
        later_hotel: later_hotel
      ]
    end

    test "returns true when first argument has later date in `start` field" <>
           " comparing to the second argument and the arguments are structs of the same type",
         %{
           earlier_travel: earlier_travel,
           later_travel: later_travel,
           earlier_hotel: earlier_hotel,
           later_hotel: later_hotel
         } do
      assert Segments.compare(later_travel, earlier_travel) == true
      assert Segments.compare(later_hotel, earlier_hotel) == true
    end

    test "returns true when both arguments have the same date in `start` field" <>
           "and the arguments are structs of the same type",
         %{earlier_travel: earlier_travel, earlier_hotel: earlier_hotel} do
      assert Segments.compare(earlier_travel, earlier_travel) == true
      assert Segments.compare(earlier_hotel, earlier_hotel) == true
    end

    test "returns false when first argument has earlier date in `start` field" <>
           " comparing to the second argument and the arguments are structs of the same type",
         %{
           earlier_travel: earlier_travel,
           later_travel: later_travel,
           earlier_hotel: earlier_hotel,
           later_hotel: later_hotel
         } do
      assert Segments.compare(earlier_travel, later_travel) == false
      assert Segments.compare(earlier_hotel, later_hotel) == false
    end

    test "properly compares hotel and travel segments passed as arguments",
         %{
           earlier_travel: earlier_travel,
           later_travel: later_travel,
           earlier_hotel: earlier_hotel,
           later_hotel: later_hotel
         } do
      assert Segments.compare(earlier_travel, earlier_hotel) == false
      assert Segments.compare(earlier_hotel, earlier_travel) == true

      assert Segments.compare(later_travel, earlier_hotel) == true
      assert Segments.compare(earlier_travel, later_hotel) == false

      assert Segments.compare(later_hotel, earlier_travel) == true
      assert Segments.compare(earlier_hotel, later_travel) == false
    end
  end
end
