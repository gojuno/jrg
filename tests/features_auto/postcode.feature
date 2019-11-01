@unit
Feature: Postcode

    Scenario: addr:postcode works
        When point is postcode01
        Then address is 238 East 53rd Street
        And postcode is 10022

    Scenario: postal_code works
        When point is postcode02
        Then postcode is 10016

    Scenario: postal_code from a POI
        When point is postcode03
        Then address is 1700 2nd Avenue
        And postcode is 10128

    Scenario: Postal code is passed from enclosing buildings
        When point is postcode04
        Then address is 216 East 53rd Street
        And postcode is 10022

