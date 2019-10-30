@unit @complex
Feature: Address Points

    Scenario: Prefer address point with the same street as nearby
        When location is -73.82756, 40.95173
        Then address is 128 Lake Avenue
        And object is node 6337003669

    Scenario: But when we're too close to a POI, use it
        When location is -73.82772, 40.95157
        Then address is 25 Main Street
        And object is node 1705829296

    Scenario: Central Park South
        When location is -73.97410, 40.76478
        Then address is 2 Central Park South
        And object is node 2708081461

    @wip
    Scenario: Building takes address from a polygon and is closed than building w/address point
        Possible good answer is 695 Park Avenue, but there is an address point in 39 m
        When location is -73.96503, 40.76907
        Then address is 681 Park Avenue

    @wip
    Scenario: Address point instead of closer building with address from a polygon
        When location is -73.96496, 40.76906
        Then address is 701 Park Avenue
        And object is node 2723866680

    Scenario: Address points inside a building count as the building addresses
        Close to wrong building with address, even closer to building with no address, but with address points

        When location is -73.944465, 40.67037
        Then address is 956 Lincoln Place

    Scenario: Another similar example: address point is far, but the building is closer than 48
        When location is -73.985957, 40.689188
        Then address is 45 Hoyt Street

    Scenario: Again, building with an addressed pub is closer
        Pub is in 9 meters, but a nearby building is in 8, but the pub is in the closest building.
        When location is -73.983293, 40.764458
        Then address is 243 West 54th Street

    Scenario: Inside a building, but address points are 44+ meters away and on a wrong street
        I know it's inside a building, but it'd be great to make an exception in this case, since
        Building 49 is right here and on a correct street. Maybe we need to prioritize a correct
        street more.

        When location is -73.966145, 40.714713
        Then address is 49 South 2nd Street

    Scenario: Same, with a point very close to proper building but not in it
        The distance is literally 15 cm to a proper building on a proper closes street.

        When location is -73.993965, 40.745433
        Then address is 159 West 25th Street

    Scenario: The ultimate geocoder: closest buliding + relevant address point
        Currently we take a closest building with address (429). Better option would be a closest building
        with an address point inside (428). The best option would be using the closest address point
        inside that building that has "addr:street" equal to the name of the closest road.

        When location is -73.957488, 40.761728
        Then address is 1175 York Avenue

    Scenario: Use address point corresponding to nearest street
        When location is -73.96457, 40.76966
        Then address is 100 East 70th Street

    Scenario: Use address point closer to the street even outside a building
        When location is -73.99927, 40.7248
        Then address is 106 Prince Street
