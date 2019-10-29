Feature: Postal Codes

    Scenario: addr:postcode works
        When location is -73.96810, 40.75695
        Then address is 238 East 53rd Street
        And postcode is 10022

    Scenario: postal_code works
        When location is -73.97852, 40.75176
        Then postcode is 10016

    Scenario: postal_code from a POI
        When location is -73.95054, 40.77923
        Then address is 1700 2nd Avenue
        And postcode is 10128

    Scenario: Postal code is passed from enclosing buildings
        When location is -73.96880, 40.75715
        Then address is 216 East 53rd Street
        And postcode is 10022
