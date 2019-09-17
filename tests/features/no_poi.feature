@poi
Feature: We don't need no points of interest
    Scenario: Ignore a lone-standing POI
        When location is -73.87102, 40.93029
        Then address is Midland Avenue
        And response does not contain
            | key  |
            | name |

    Scenario: Disregard a shop inside a building with address
        When location is -73.91930, 40.75928
        Then address is 38-09 Broadway
        And object is way 280577095
        And response does not contain
            | key  |
            | name |

    Scenario: Matching a shop inside a building is a no-go
        When location is -73.91933, 40.75922
        Then object is way 280577095

    Scenario: Middle of addressed amenity area — we don't care about amenities
        When location is -73.90516, 40.86719
        Then object is not way 562564541

    Scenario: Building inside addressed amenity with the same address
        When location is -73.89284, 40.87435
        Then address is 250 Bedford Park Boulevard West
        And object is not way 76090444

    Scenario: And finally, closer POI inside an addressed amenity
        When location is -73.89549, 40.87176
        Then address is 2830 Goulden Avenue
