@admin @big
Feature: Administrative entities outside New York

    Scenario: New York
        When location is -73.8, 40.7
        Then city is New York, Queens County, New York

    Scenario: Inside Islip
        When location is -73.20601, 40.72895
        Then city is Islip, Suffolk County, New York

    Scenario: Nearby, in East Islip
        When location is -73.19935, 40.73190
        Then city is East Islip, Suffolk County, New York

    Scenario: Polygonal city
        When location is -74.03893, 40.75272
        Then city is Union City, Hudson County, New Jersey

    Scenario: Hamlet inside a city
        When location is -74.064, 40.726
        Then city is Jersey City, Hudson County, New Jersey
        And response contains
            | hamlet |
            | Bergen |

    Scenario: North Plainfield
        When location is -74.473, 40.668
        Then city is North Plainfield, Somerset County, New Jersey

    Scenario: NP is cut by county boundary
        When location is -74.478, 40.668
        Then response does not contain
            | key    |
            | city   |
            | hamlet |

    Scenario: A village
        When location is -74.49, 40.69
        Then response contains
            | village   |
            | Long Hill |

    Scenario: A town with no enclosing county
        When location is -72.51, 42.37
        Then response contains
            | town    |
            | Amherst |

    Scenario: City on polygon + town on point = city + town
        When location is -74.4, 40.63
        Then response contains
            | city       | town       |
            | Plainfield | Plainfield |
