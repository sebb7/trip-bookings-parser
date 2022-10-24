## TripBookingsParser
Project is responsible for parsing a list of bookings in order to present them
in readable format.

List of bookings is represented by a file in which every booking is a trip segment
with datetimes, segment type and IATAs location identifier (e.g. SVQ, MAD, BCN, NYC).

```
BASED: SVQ

RESERVATION
SEGMENT: Flight SVQ 2023-03-02 06:40 -> BCN 09:10

RESERVATION
SEGMENT: Hotel BCN 2023-01-05 -> 2023-01-10

RESERVATION
SEGMENT: Flight SVQ 2023-01-05 20:40 -> BCN 22:10
SEGMENT: Flight BCN 2023-01-10 10:30 -> SVQ 11:50

RESERVATION
SEGMENT: Train SVQ 2023-02-15 09:30 -> MAD 11:00
SEGMENT: Train MAD 2023-02-17 17:00 -> SVQ 19:30

RESERVATION
SEGMENT: Hotel MAD 2023-02-15 -> 2023-02-17

RESERVATION
SEGMENT: Flight BCN 2023-03-02 15:00 -> NYC 22:45
```

Above list should be presented as:
```
TRIP to BCN
Flight from SVQ to BCN at 2023-01-05 20:40 to 22:10
Hotel at BCN on 2023-01-05 to 2023-01-10
Flight from BCN to SVQ at 2023-01-10 10:30 to 11:50

TRIP to MAD
Train from SVQ to MAD at 2023-02-15 09:30 to 11:00
Hotel at MAD on 2023-02-15 to 2023-02-17
Train from MAD to SVQ at 2023-02-17 17:00 to 19:30

TRIP to NYC
Flight from SVQ to BCN at 2023-03-02 06:40 to 09:10
Flight from BCN to NYC at 2023-03-02 15:00 to 22:45
```

## Assumptions
- there is no error handling implemented, valid input is expected
- trip segments cannot overlap
- two travel segments (train/flight) are treated as connection
when there is less than 24 hours difference between their stop time and start time
(also connection can consist of more than two travel segments)
- trip can finish and start in the location different than the base location
- return connections to base location are not consider as separate trips
- travel segments (train/flight) start and stop times are always in one day boundaries
- trip to another location in one day boundaries will be recorded properly
