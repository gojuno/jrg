@complex @unit
Feature: Address Points

    Scenario: Prefer address point with the same street as nearby
        When point is address_points01
        Then address is 128 Lake Avenue
        And object is node 6337003669

    Scenario: But when we're too close to a POI, use it
        When point is address_points02
        Then address is 25 Main Street
        And object is node 1705829296

    Scenario: Central Park South
        When point is address_points03
        Then address is 2 Central Park South
        And object is node 2708081461

    Scenario: Building takes address from a polygon and is closed than building w/address point
        Possible good answer is 695 Park Avenue, but there is an address point in 39 m

        When point is address_points04
        Then address is 681 Park Avenue

    Scenario: Address point instead of closer building with address from a polygon
        When point is address_points05
        Then address is 701 Park Avenue
        And object is node 2723866680

    Scenario: Address point with matching road further than the other
        When point is address_points05a
        Then address is 101 East 69th Street

    Scenario: Address points inside a building count as the building addresses
        Close to wrong building with address, even closer to building with no address, but with address points

        When point is address_points06
        Then address is 956 Lincoln Place

    Scenario: Another similar example: address point is far, but the building is closer than 48
        When point is address_points07
        Then address is 45 Hoyt Street

    Scenario: Again, building with an addressed pub is closer
        Pub is in 9 meters, but a nearby building is in 8, but the pub is in the closest building.

        When point is address_points08
        Then address is 243 West 54th Street

    Scenario: Inside a building, but address points are 44+ meters away and on a wrong street
        I know it's inside a building, but it'd be great to make an exception in this case, since Building 49 is right here and on a correct street. Maybe we need to prioritize a correct street more.

        When point is address_points09
        Then address is 49 South 2nd Street

    Scenario: Same, with a point very close to proper building but not in it
        The distance is literally 15 cm to a proper building on a proper closes street.

        When point is address_points10
        Then address is 159 West 25th Street

    Scenario: The ultimate geocoder: closest buliding + relevant address point
        Currently we take a closest building with address (429). Better option would be a closest building with an address point inside (428). The best option would be using the closest address point inside that building that has "addr:street" equal to the name of the closest road.

        When point is address_points11
        Then address is 1175 York Avenue

    Scenario: Use address point corresponding to nearest street
        When point is address_points12
        Then address is 100 East 70th Street

    Scenario: Use address point closer to the street even outside a building
        When point is address_points13
        Then address is 106 Prince Street

