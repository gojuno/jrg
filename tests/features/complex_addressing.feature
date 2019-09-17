@complex
Feature: Complex addressing

    @wip
    Scenario: Broadway vs Columbus Ave
        When location is -73.98261, 40.77216
        Then road is Broadway

    Scenario: Hyatt building, should return Fourth Avenue
        Initially this should have returned 134 Fourth Avenue, but
        the address point is in 30.8 m, which is less than 50, so that's okay.

        When location is -73.990355, 40.733313
        Then address is 76 East 13th Street

    @wip
    Scenario: Armoury, should return 68 Lexington
        It's inside a building 68 Lexington
        OK: 103 E 25th or 106 E 26th
        Not OK: another address on Lexington
        Distances???

        When location is -73.984137, 40.741313
        Then address is 68 Lexington Avenue
        And object is way 264768938

    @wip
    Scenario: Definitely 68 Lexington
        When location is -73.98428, 40.74139
        Then address is 68 Lexington Avenue
        And object is way 264768938

    Scenario: Goodwill store: disregard Livingston Street address point
        When location is -73.98402, 40.68835
        Then address is 42 Bond Street

    Scenario: Near Goodwill store, but Livingston Street is closer
        When location is -73.98404, 40.68867
        Then address is 258 Livingston Street

    Scenario: Near Goodwill store, Livingston Street is closer, but more than 30 m
        When location is -73.984129, 40.688663
        Then address is 42 Bond Street

    Scenario: Inside house w/o address, close to building with address
        When location is -73.944431, 40.670369
        Then address is 968 Lincoln Place

    Scenario: POI node in 49.9 meters should be disregarded towards a building w/address
        Inside a building w/o address and a single POI (233 Spring St); building with address is in 10 meters.

        When location is -74.004684, 40.726123
        Then address is 26 Vandam Street

    Scenario: Inside multiple objects with addresses - matters only the smallest one
        Wrong: 140 W 65th St (parking) and 10 Lincoln Plz (arts_centre)

        When location is -73.983855, 40.772738
        Then address is 30 Lincoln Center Plaza

    Scenario: When addr:street is missing, we take it from the closest road
        When location is -73.76961, 40.91676
        Then address is 159 East Main Street

    Scenario: Road should be closest to the POI, not to us
        When location is -73.76978, 40.91684
        Then address is 159 East Main Street

    Scenario: In semicolon-delimited values, taking the first one
        When location is -73.951051, 40.777983
        Then address is 305 East 86th Street
        And object is node 6545815158

    Scenario: Do not use center points from polygonal features that fall into buildings
        When location is -73.961887, 40.796993
        Then address is 12 West 104th Street

    Scenario: Park Avenue building with address, but with address points
        When location is -73.97221, 40.75927
        Then address is 399 Park Avenue
        And object is way 118116810

    @wip
    Scenario: Near building with address that has address points nearby
        When location is -73.96750, 40.75534
        Then address is 305 East 51st Street
        And object is way 265459554
