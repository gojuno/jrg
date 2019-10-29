@simple @unit
Feature: Simple addressing

    Scenario: Inside a simple building with address and no POIs
        When location is -73.97022, 40.76620
        Then address is 16 East 63rd Street
        And object is way 265345736

    Scenario: Near a building with address
        When location is -73.81818, 40.93842
        Then address is 12 Dusenberry Road
        And object is way 544773479

    Scenario: 40m to a node of a shop with address
        When location is -73.80401, 40.97230
        Then address is 750 White Plains Road
        And object is node 3111837409

    Scenario: Building with an address node
        When location is -73.84275, 40.88615
        Then address is 1965 Schieffelin Avenue
        And object is node 2823056985

    Scenario: Same building, different node
        When location is -73.84250, 40.88593
        Then address is 1961 Schieffelin Avenue
        And object is node 2823056984

    Scenario: Near a building with address node
        When location is -73.84210, 40.88632
        Then address is 1981 Schieffelin Avenue
        And object is node 2823056986

    Scenario: Near same building, different address
        When location is -73.84159, 40.88636
        Then address is 1985 Schieffelin Avenue
        And object is node 2823056987

    Scenario: Far from buildings, but there is a road in 150m
        When location is -73.9377, 40.8616
        Then address is Henry Hudson Parkway

    Scenario: Center of an addressed building near another one
        For some reason, the nearby building comes first

        When location is -73.989762, 40.678613
        Then address is 383 Carroll Street
        And object is way 248157168

    Scenario: Inside a building, very close to another
        When location is -73.93768, 40.72155
        Then address is 80 Beadel Street

    Scenario: Address points are very far, preferring building address
        When location is -73.97206, 40.75928
        Then address is 399 Park Avenue
