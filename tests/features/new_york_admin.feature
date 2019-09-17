@admin
Feature: New York admin boundaries
    Scenario: Brooklyn Borough
        When location is -73.9432, 40.6504
        Then response contains
            | city     | county       | suburb |
            | New York | Kings County | Brooklyn |

    Scenario: Staten Island borough
        When location is -74.0801, 40.5966
        Then response contains
            | city     | county          | suburb      |
            | New York | Richmond County | Staten Island |

    Scenario: Manhattan South
        When location is -74.00987, 40.70626
        Then response contains
            | city     | county          | suburb  |
            | New York | New York County | Manhattan |

    Scenario: Manhattan North
        When location is -73.92821, 40.85967
        Then response contains
            | city     | county          | suburb  |
            | New York | New York County | Manhattan |

    Scenario: Bronx South
        When location is -73.92414, 40.81179
        Then response contains
            | city     | county       | suburb  |
            | New York | Bronx County | The Bronx |

    Scenario: Bronx East
        When location is -73.81068, 40.81553
        Then response contains
            | city     | county       | suburb  |
            | New York | Bronx County | The Bronx |

    Scenario: Queens West
        When location is -73.95289, 40.74277
        Then response contains
            | city     | county        | suburb |
            | New York | Queens County | Queens   |

    Scenario: Queens JFK
        When location is -73.78429, 40.64511
        Then response contains
            | city     | county        | suburb |
            | New York | Queens County | Queens   |

    Scenario: Queens LGA
        When location is -73.87201, 40.77393
        Then response contains
            | city     | county        | suburb |
            | New York | Queens County | Queens   |
