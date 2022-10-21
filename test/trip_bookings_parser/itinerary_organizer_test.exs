defmodule TripBookingsParser.ItineraryOrganizerTest do
  use ExUnit.Case

  alias TripBookingsParser.ItineraryOrganizer
  alias TripBookingsParser.Segments.Hotel
  alias TripBookingsParser.Segments.Travel

  describe "add_trip_labels/2" do
    test "returns empty list for empty list of segments" do
      assert ItineraryOrganizer.add_trip_labels([], "NYC") == []
    end

    test "properly adds label to simple trip without hotel segment" do
      segments = [
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "MAD",
          start: ~N[2023-05-20 18:00:00],
          stop: ~N[2023-05-20 20:00:00]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "SVQ",
          start: ~N[2023-05-22 10:00:00],
          stop: ~N[2023-05-22 12:00:00]
        }
      ]

      assert ItineraryOrganizer.add_trip_labels(segments, "SVQ") ==
               ["TRIP to MAD" | segments]
    end

    test "properly adds label to simple trip with hotel segment" do
      segments = [
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "MAD",
          start: ~N[2023-05-20 18:00:00],
          stop: ~N[2023-05-20 20:00:00]
        },
        %Hotel{
          location: "MAD",
          start: ~D[2023-05-20],
          stop: ~D[2023-05-22]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "SVQ",
          start: ~N[2023-05-22 10:00:00],
          stop: ~N[2023-05-22 12:00:00]
        }
      ]

      assert ItineraryOrganizer.add_trip_labels(segments, "SVQ") ==
               ["TRIP to MAD" | segments]
    end

    test "properly adds labels to many trips with hotel segments" do
      segments = [
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "MAD",
          start: ~N[2023-05-20 18:00:00],
          stop: ~N[2023-05-20 20:00:00]
        },
        %Hotel{
          location: "MAD",
          start: ~D[2023-05-20],
          stop: ~D[2023-05-22]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "SVQ",
          start: ~N[2023-05-22 10:00:00],
          stop: ~N[2023-05-22 12:00:00]
        },
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "BCN",
          start: ~N[2023-06-20 18:00:00],
          stop: ~N[2023-06-20 20:00:00]
        },
        %Hotel{
          location: "BCN",
          start: ~D[2023-06-20],
          stop: ~D[2023-06-22]
        },
        %Travel{
          type: "Flight",
          from: "BCN",
          to: "SVQ",
          start: ~N[2023-06-22 10:00:00],
          stop: ~N[2023-06-22 12:00:00]
        }
      ]

      expected_labeled_segments = [
        "TRIP to MAD",
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "MAD",
          start: ~N[2023-05-20 18:00:00],
          stop: ~N[2023-05-20 20:00:00]
        },
        %Hotel{
          location: "MAD",
          start: ~D[2023-05-20],
          stop: ~D[2023-05-22]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "SVQ",
          start: ~N[2023-05-22 10:00:00],
          stop: ~N[2023-05-22 12:00:00]
        },
        "TRIP to BCN",
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "BCN",
          start: ~N[2023-06-20 18:00:00],
          stop: ~N[2023-06-20 20:00:00]
        },
        %Hotel{
          location: "BCN",
          start: ~D[2023-06-20],
          stop: ~D[2023-06-22]
        },
        %Travel{
          type: "Flight",
          from: "BCN",
          to: "SVQ",
          start: ~N[2023-06-22 10:00:00],
          stop: ~N[2023-06-22 12:00:00]
        }
      ]

      assert ItineraryOrganizer.add_trip_labels(segments, "SVQ") ==
               expected_labeled_segments
    end

    test "properly adds label to a trip without hotel segment and with" <>
           " many travel segments treated as a connection" do
      segments = [
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "MAD",
          start: ~N[2023-05-20 08:00:00],
          stop: ~N[2023-05-20 10:00:00]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "NYC",
          start: ~N[2023-05-20 12:00:00],
          stop: ~N[2023-05-20 23:00:00]
        },
        %Travel{
          type: "Flight",
          from: "NYC",
          to: "MAD",
          start: ~N[2023-05-22 10:00:00],
          stop: ~N[2023-05-22 20:00:00]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "SVQ",
          start: ~N[2023-05-22 22:00:00],
          stop: ~N[2023-05-22 23:30:00]
        }
      ]

      assert ItineraryOrganizer.add_trip_labels(segments, "SVQ") ==
               ["TRIP to NYC" | segments]
    end

    test "properly adds label to a trip with hotel segment and" <>
           " many travel segments treated as a connection" do
      segments = [
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "MAD",
          start: ~N[2023-05-20 08:00:00],
          stop: ~N[2023-05-20 10:00:00]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "NYC",
          start: ~N[2023-05-20 12:00:00],
          stop: ~N[2023-05-20 23:00:00]
        },
        %Hotel{
          location: "NYC",
          start: ~D[2023-05-20],
          stop: ~D[2023-05-22]
        },
        %Travel{
          type: "Flight",
          from: "NYC",
          to: "MAD",
          start: ~N[2023-05-22 10:00:00],
          stop: ~N[2023-05-22 20:00:00]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "SVQ",
          start: ~N[2023-05-22 22:00:00],
          stop: ~N[2023-05-22 23:30:00]
        }
      ]

      assert ItineraryOrganizer.add_trip_labels(segments, "SVQ") ==
               ["TRIP to NYC" | segments]
    end

    test "properly adds label to a last trip without return travel segments" do
      segments = [
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "MAD",
          start: ~N[2023-05-20 08:00:00],
          stop: ~N[2023-05-20 10:00:00]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "NYC",
          start: ~N[2023-05-20 12:00:00],
          stop: ~N[2023-05-20 23:00:00]
        }
      ]

      assert ItineraryOrganizer.add_trip_labels(segments, "SVQ") ==
               ["TRIP to NYC" | segments]
    end

    test "adds separate label to a trip which starts after 24 hours in a location" <>
           " different than the base location" do
      segments = [
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "MAD",
          start: ~N[2023-05-20 08:00:00],
          stop: ~N[2023-05-20 10:00:00]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "NYC",
          start: ~N[2023-05-22 12:00:00],
          stop: ~N[2023-05-22 23:00:00]
        },
        %Hotel{
          location: "NYC",
          start: ~D[2023-05-22],
          stop: ~D[2023-05-24]
        },
        %Travel{
          type: "Flight",
          from: "NYC",
          to: "MAD",
          start: ~N[2023-05-24 10:00:00],
          stop: ~N[2023-05-24 20:00:00]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "SVQ",
          start: ~N[2023-05-24 22:00:00],
          stop: ~N[2023-05-24 23:30:00]
        }
      ]

      expected_labeled_segments = [
        "TRIP to MAD",
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "MAD",
          start: ~N[2023-05-20 08:00:00],
          stop: ~N[2023-05-20 10:00:00]
        },
        "TRIP to NYC",
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "NYC",
          start: ~N[2023-05-22 12:00:00],
          stop: ~N[2023-05-22 23:00:00]
        },
        %Hotel{
          location: "NYC",
          start: ~D[2023-05-22],
          stop: ~D[2023-05-24]
        },
        %Travel{
          type: "Flight",
          from: "NYC",
          to: "MAD",
          start: ~N[2023-05-24 10:00:00],
          stop: ~N[2023-05-24 20:00:00]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "SVQ",
          start: ~N[2023-05-24 22:00:00],
          stop: ~N[2023-05-24 23:30:00]
        }
      ]

      assert ItineraryOrganizer.add_trip_labels(segments, "SVQ") ==
               expected_labeled_segments
    end

    test "adds separate label to a trip which destination and return travel" <>
           " segments don't differ by 24 hours" do
      segments = [
        %Travel{
          type: "Flight",
          from: "SVQ",
          to: "MAD",
          start: ~N[2023-05-20 16:00:00],
          stop: ~N[2023-05-20 18:00:00]
        },
        %Travel{
          type: "Flight",
          from: "MAD",
          to: "SVQ",
          start: ~N[2023-05-20 10:00:00],
          stop: ~N[2023-05-20 12:00:00]
        }
      ]

      assert ItineraryOrganizer.add_trip_labels(segments, "SVQ") ==
               ["TRIP to MAD" | segments]
    end
  end
end
