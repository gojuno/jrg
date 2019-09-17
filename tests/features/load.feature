@load
Feature: Load testing

    Scenario: by coordinate
        Given bounding box -74.41, 40.48, -73.52, 41.06
        When testing load by coordinate requests
        Then RPS is greater than 30

    Scenario: by objects
        Given list of OSM objects
            | object |
            | way 265345736 |
            | node 1705829296 |
        When testing load by object requests
        Then RPS is greater than 45

    Scenario: by coordinate without admin
        Given bounding box -74.41, 40.48, -73.52, 41.06
        And admin areas disabled
        When testing load by coordinate requests
        Then RPS is greater than 32

    Scenario: by objects without admin
        Given list of OSM objects
            | object |
            | way 265345736 |
            | node 1705829296 |
        And admin areas disabled
        When testing load by object requests
        Then RPS is greater than 48
