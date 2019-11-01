@unit @complex
Feature: Complex Addressing

    @wip
    Scenario: Broadway vs Columbus Ave
        When point is complex_addressing01
        Then road is Broadway

    Scenario: Hyatt building, should return Fourth Avenue
        Initially this should have returned 134 Fourth Avenue, but the address point is in 30.8 m, which is less than 50, so that's okay.

        When point is complex_addressing02
        Then address is 76 East 13th Street

    @wip
    Scenario: Armoury, should return 68 Lexington
        It's inside a building 68 Lexington OK: 103 E 25th or 106 E 26th Not OK: another address on Lexington Distances???

        When point is complex_addressing03
        Then address is 68 Lexington Avenue
        And object is way 264768938

    @wip
    Scenario: Definitely 68 Lexington
        When point is complex_addressing04
        Then address is 68 Lexington Avenue
        And object is way 264768938

    Scenario: Goodwill store: disregard Livingston Street address point
        When point is complex_addressing05
        Then address is 42 Bond Street

    Scenario: Near Goodwill store, but Livingston Street is closer
        When point is complex_addressing06
        Then address is 258 Livingston Street

    Scenario: Near Goodwill store, Livingston Street is closer, but more than 30 m
        When point is complex_addressing07
        Then address is 42 Bond Street

    Scenario: Inside house w/o address, close to building with address
        When point is complex_addressing08
        Then address is 968 Lincoln Place

    Scenario: POI node in 49.9 meters should be disregarded towards a building w/address
        Inside a building w/o address and a single POI (233 Spring St); building with address is in 10 meters.

        When point is complex_addressing09
        Then address is 26 Vandam Street

    Scenario: Inside multiple objects with addresses - matters only the smallest one
        Wrong: 140 W 65th St (parking) and 10 Lincoln Plz (arts_centre)

        When point is complex_addressing10
        Then address is 30 Lincoln Center Plaza

    Scenario: When addr:street is missing, we take it from the closest road
        When point is complex_addressing11
        Then address is 159 East Main Street

    Scenario: Road should be closest to the POI, not to us
        When point is complex_addressing12
        Then address is 159 East Main Street

    Scenario: In semicolon-delimited values, taking the first one
        When point is complex_addressing13
        Then address is 305 East 86th Street
        And object is node 6545815158

    Scenario: Do not use center points from polygonal features that fall into buildings
        When point is complex_addressing14
        Then address is 12 West 104th Street

    Scenario: Park Avenue building with address, but with address points
        When point is complex_addressing15
        Then address is 399 Park Avenue
        And object is way 118116810

    @wip
    Scenario: Near building with address that has address points nearby
        When point is complex_addressing16
        Then address is 305 East 51st Street
        And object is way 265459554

