@distance @unit
Feature: Distance

    Scenario: Inside a building, return same point
        When point is distance01
        Then result is 0 m away

    Scenario: Near a building, distance to the closest
        When point is distance02
        Then result is 5 m away

    Scenario: Outside a building, distance to the polygon
        When point is distance03
        Then result is 15 m away

    Scenario: Address point, distance to it
        When point is distance04
        Then result is 23 m away

    Scenario: Address node within a building, distance to it
        When point is distance05
        Then result is 9 m away

    Scenario: Address within a building, we're outside: distance to building
        When point is distance06
        Then result is 20 m away

    Scenario: Only a road nearby, distance to the closest point
        When point is distance07
        Then distance to the result is 165 m

    @admin
    Scenario: Only administrative border, distance to the center
        When point is distance08
        Then distance to the result is 12197 m

