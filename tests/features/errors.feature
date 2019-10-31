@unit @errors
Feature: Error codes and edge cases

    Scenario: Non-numeric coordinates
        When location is Lon, Lat
        Then message has "lat: Missing lat"
        And status code is 400

    Scenario: Non-numeric longitude
        When location is Lon, 0
        Then message has "lon: Missing lon"
        And status code is 400

    Scenario: Wrong OSM type
        When object is abc 123
        Then message has "osm_type: Missing osm_type"
        And status code is 400

    Scenario: Non-numeric object id
        When object is node one
        Then message has "osm_id: Missing osm_id"
        And status code is 400

    Scenario: Missing OSM object
        When object is node 1
        Then error is "Unable to geocode"
        And status code is 404

    Scenario: 0, 0
        When location is 0, 0
        Then error is "Unable to geocode"
        And status code is 404

    Scenario: Atlantic ocean
        When location is -67.7, 38.8
        Then error is "Unable to geocode"
        And status code is 404

    @admin @big
    Scenario: State but no object should return state OSM id
        When point is error_state_only
        Then response contains
            | county | state | country |
            | Westchester County | New York | United States |
        And response does not contain
            | key |
            | house |
            | road |
            | city |
        And object is present

    @admin
    Scenario: Object type should be way/relation (not w/r) for admin queries
        When point is error_admin
        Then object is relation 12
