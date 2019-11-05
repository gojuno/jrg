@poi @unit
Feature: No Poi

    Scenario: Ignore a lone-standing POI
        When point is no_poi01
        Then address is Midland Avenue
        And response does not contain
            | key |
            | name |

    Scenario: Disregard a shop inside a building with address
        When point is no_poi02
        Then address is 38-09 Broadway
        And object is way 280577095
        And response does not contain
            | key |
            | name |

    Scenario: Matching a shop inside a building is a no-go
        When point is no_poi03
        Then object is way 280577095

    Scenario: Middle of addressed amenity area — we don't care about amenities
        When point is no_poi04
        Then object is not way 562564541

    Scenario: Building inside addressed amenity with the same address
        When point is no_poi05
        Then address is 250 Bedford Park Boulevard West
        And object is not way 76090444

    Scenario: And finally, closer POI inside an addressed amenity
        When point is no_poi06
        Then address is 2830 Goulden Avenue

    Scenario: Biggest building inside gets the address
        When point is no_poi08
        Then address is 252 Bedford Park Boulevard West

