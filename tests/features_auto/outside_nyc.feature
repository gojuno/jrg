@unit @big @admin
Feature: Outside Nyc

    Scenario: New York
        When point is outside_nyc01
        Then city is New York, Queens County, New York

    Scenario: Inside Islip
        When point is outside_nyc02
        Then city is Islip, Suffolk County, New York

    Scenario: Nearby, in East Islip
        When point is outside_nyc03
        Then city is East Islip, Suffolk County, New York

    Scenario: Polygonal city
        When point is outside_nyc04
        Then city is Union City, Hudson County, New Jersey

    Scenario: Hamlet inside a city
        When point is outside_nyc05
        Then city is Jersey City, Hudson County, New Jersey
        And response contains
            | hamlet |
            | Bergen |

    Scenario: North Plainfield
        When point is outside_nyc06
        Then city is North Plainfield, Somerset County, New Jersey

    Scenario: NP is cut by county boundary
        When point is outside_nyc07
        Then response does not contain
            | key |
            | city |
            | hamlet |

    Scenario: A village
        When point is outside_nyc08
        Then response contains
            | village |
            | Long Hill |

    Scenario: A town with no enclosing county
        When point is outside_nyc09
        Then response contains
            | town |
            | Amherst |

    Scenario: City on polygon + town on point = city + town
        When point is outside_nyc10
        Then response contains
            | city | town |
            | Plainfield | Plainfield |

    Scenario: A hamlet among many
        When location is -74.46988114357, 40.69085645301
        Then response contains
            | hamlet |
            | Meyersville |

