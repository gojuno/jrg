@unit @distance
Feature: Distances

    Scenario: Inside a building, return same point
        When location is -73.97022, 40.76620
        Then result is 0 m away

    Scenario: Near a building, distance to the closest
        When location is -73.987004, 40.729323
        Then result is 5 m away

    Scenario: Outside a building, distance to the polygon
        When location is -73.81818, 40.93842
        Then result is 15 m away

    Scenario: Address point, distance to it
        When location is -73.80401, 40.97230
        Then result is 23 m away

    Scenario: Address node within a building, distance to it
        When location is -73.84275, 40.88615
        Then result is 9 m away

    Scenario: Address within a building, we're outside: distance to building
        When location is -73.84210, 40.88632
        Then result is 20 m away

    Scenario: Only a road nearby, distance to the closest point
        When location is -73.9377, 40.8616
        Then distance to the result is 165 m

    @admin
    Scenario: Only administrative border, distance to the center
        When location is -73.7357, 40.8989
        Then distance to the result is 3296 m
