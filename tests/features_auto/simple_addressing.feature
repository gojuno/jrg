@simple @unit
Feature: Simple Addressing

    Scenario: Inside a simple building with address and no POIs
        When point is simple_addressing01
        Then address is 16 East 63rd Street
        And object is way 265345736

    Scenario: Near a building with address
        When point is simple_addressing02
        Then address is 12 Dusenberry Road
        And object is way 544773479

    Scenario: 40m to a node of a shop with address
        When point is simple_addressing03
        Then address is 750 White Plains Road
        And object is node 3111837409

    Scenario: Building with an address node
        When point is simple_addressing04
        Then address is 1965 Schieffelin Avenue
        And object is node 2823056985

    Scenario: Same building, different node
        When point is simple_addressing05
        Then address is 1961 Schieffelin Avenue
        And object is node 2823056984

    Scenario: Near a building with address node
        When point is simple_addressing06
        Then address is 1981 Schieffelin Avenue
        And object is node 2823056986

    Scenario: Near same building, different address
        When point is simple_addressing07
        Then address is 1985 Schieffelin Avenue
        And object is node 2823056987

    Scenario: Far from buildings, but there is a road in 150m
        When point is simple_addressing08
        Then address is Henry Hudson Parkway

    Scenario: Center of an addressed building near another one
        For some reason, the nearby building comes first

        When point is simple_addressing09
        Then address is 383 Carroll Street
        And object is way 248157168

    Scenario: Inside a building, very close to another
        When point is simple_addressing10
        Then address is 80 Beadel Street

    Scenario: Address points are very far, preferring building address
        When point is simple_addressing11
        Then address is 399 Park Avenue

