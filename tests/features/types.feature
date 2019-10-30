@unit @type
Feature: Response has an appropriate type

    Scenario: Inside a building with no points, close to other building
        When location is -73.93738, 40.72140
        Then address is 93 Division Place
        And type is building

    Scenario: Address point inside a building
        When location is -73.93698, 40.7216
        Then address is 481 Vandervoort Avenue
        And type is address

    Scenario: Addressed POI inside a building keeps type
        When location is -73.93820, 40.72112
        Then address is 496 Morgan Avenue
        And type is poi

    Scenario: No points inside — we get a building
        When location is -73.93815, 40.72099
        Then address is 492 Morgan Avenue
        And type is building

    Scenario: Nothing around sans a road
        When location is -73.93513, 40.72103
        Then type is road

    Scenario: Empty, and a road is too far — still a road
        When location is -73.93176, 40.72200
        Then road is Varick Avenue
        And type is road

    Scenario: Nothing for miles and miles, only admin border
        When location is -73.75065, 40.87051
        Then type is admin
