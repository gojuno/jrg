@type @unit
Feature: Types

    Scenario: Inside a building with no points, close to other building
        When point is types01
        Then address is 93 Division Place
        And type is building

    Scenario: Address point inside a building
        When point is types02
        Then address is 481 Vandervoort Avenue
        And type is address

    Scenario: Addressed POI inside a building keeps type
        When point is types03
        Then address is 496 Morgan Avenue
        And type is poi

    Scenario: No points inside — we get a building
        When point is types04
        Then address is 492 Morgan Avenue
        And type is building

    Scenario: Nothing around sans a road
        When point is types05
        Then type is road

    Scenario: Empty, and a road is too far — still a road
        When point is types06
        Then road is Varick Avenue
        And type is road

    Scenario: Nothing for miles and miles, only admin border
        When point is types07
        Then type is admin

