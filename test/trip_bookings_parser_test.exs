defmodule TripBookingsParserTest do
  use ExUnit.Case

  alias TripBookingsParser

  @fixtures_path "test/fixtures"

  test "to_trip_plan_format/1 returns proper itinerary for bookings list no. 1" do
    result = TripBookingsParser.to_trip_plan_format("#{@fixtures_path}/trip_bookings_1.txt")
    expected = File.read!("#{@fixtures_path}/itinerary_1.txt")

    assert Enum.join(result) == expected
  end

  test "to_trip_plan_format/1 returns proper itinerary for bookings list no. 2" do
    result = TripBookingsParser.to_trip_plan_format("#{@fixtures_path}/trip_bookings_2.txt")
    expected = File.read!("#{@fixtures_path}/itinerary_2.txt")

    assert Enum.join(result) == expected
  end
end
