@admin @unit
Feature: Neighbourhoods

    Scenario: East Harlem
        When point is neighbourhoods01
        Then neighbourhood is East Harlem, Manhattan

    Scenario: Harlem far from the place point
        When point is neighbourhoods02
        Then neighbourhood is Harlem, Manhattan

    Scenario: More than 1 km from any neighbourhood
        When point is neighbourhoods04
        Then response does not contain
            | key |
            | neighbourhood |

    Scenario: Suburbs are not mixed with neighbourhoods
        When point is neighbourhoods05
        Then neighbourhood is Lambert Houses, The Bronx

    Scenario: NYC boundary cuts neighbourhoods
        When point is neighbourhoods06
        Then response does not contain
            | key |
            | neighbourhood |

    Scenario: Polygonal neighbourhood
        When point is neighbourhoods07
        Then neighbourhood is Middle Village, Queens

    Scenario: Polygonal neighbourhood cuts point neighbourhoods
        When point is neighbourhoods08
        Then neighbourhood is Fresh Meadows, Queens

    Scenario: Point neighbourhood inside a polygonal neighbourhood is deleted
        Could be Fresh Pond, but nope

        When point is neighbourhoods09
        Then neighbourhood is Ridgewood, Queens

    Scenario: Same polygon but far from points
        When point is neighbourhoods10
        Then neighbourhood is Ridgewood, Queens

    Scenario: Bay does not cut a neighbourhood
        Though do we want it?

        When point is neighbourhoods11
        Then neighbourhood is Hamilton Beach, Queens

    Scenario: Neighbourhoods with centre outisde a city are removed
        When point is neighbourhoods12
        Then response does not contain
            | key |
            | neighbourhood |

    Scenario: Removed completely
        When point is neighbourhoods12a
        Then response does not contain
            | key |
            | neighbourhood |

    Scenario: No neighbourhoods outside a city
        When point is neighbourhoods13
        Then response does not contain
            | key |
            | neighbourhood |

    Scenario: But there are in a city
        When point is neighbourhoods14
        Then neighbourhood is Roy Reuther Houses

