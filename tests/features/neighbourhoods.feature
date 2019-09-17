@admin
Feature: New York neighbourhoods

    Scenario: East Harlem
        When location is -73.93538, 40.79348
        Then neighbourhood is East Harlem, Manhattan

    Scenario: Harlem far from the place point
        When location is -73.93962, 40.8218
        Then neighbourhood is Harlem, Manhattan

    @big
    Scenario: A neighbourhood on Staten Island
        When location is -74.24964, 40.50706
        Then neighbourhood is Tottenville, Staten Island

    Scenario: More than 1 km from any neighbourhood
        When location is -73.8906, 40.82186
        Then response does not contain
            | key |
            | neighbourhood |

    Scenario: Suburbs are not mixed with neighbourhoods
        When location is -73.87859, 40.84563
        Then neighbourhood is Lambert Houses, The Bronx

    Scenario: NYC boundary cuts neighbourhoods
        When location is -73.86495, 40.90294
        Then response does not contain
            | key |
            | neighbourhood |
        
    Scenario: Polygonal neighbourhood
        When location is -73.86722, 40.71584
        Then neighbourhood is Middle Village, Queens

    Scenario: Polygonal neighbourhood cuts point neighbourhoods
        When location is -73.78645, 40.72768
        Then neighbourhood is Fresh Meadows, Queens

    Scenario: Point neighbourhood inside a polygonal neighbourhood is deleted
        Could be Fresh Pond, but nope

        When location is -73.90308, 40.70779
        Then neighbourhood is Ridgewood, Queens

    Scenario: Same polygon but far from points
        When location is -73.90166, 40.69187
        Then neighbourhood is Ridgewood, Queens

    Scenario: Bay does not cut a neighbourhood
        Though do we want it?

        When location is -73.83259, 40.65154
        Then neighbourhood is Hamilton Beach, Queens

    Scenario: Neighbourhoods with centre outisde a city are removed
        When location is -74.02947, 40.75716
        Then response does not contain
            | key |
            | neighbourhood |

    Scenario: No neighbourhoods outside a city
        When location is -73.7407, 40.5917
        Then response does not contain
            | key |
            | neighbourhood |

    Scenario: But there are in a city
        When location is -73.7422, 40.5956
        Then neighbourhood is Roy Reuther Houses
