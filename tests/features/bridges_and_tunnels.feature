@unit
Feature: Bridges and Tunnels
    We actually test that despite them being in the roads database,
    they do not affect geocoding inside a city. Other tests certainly didn't broke
    when we changed that.

    Scenario: Tunnels are good
        When location is -73.96618, 40.74658
        Then address is Queens-Midtown Tunnel

    Scenario: Bridges are also good
        When location is -73.99565, 40.70522
        Then address is Brooklyn Bridge

    Scenario: Test from PR 419 #1
        When location is -73.997426, 40.757892
        Then address is 516 West 39th Street

    Scenario: Test from PR 419 #2
        When location is -73.9979034, 40.75738789
        Then address is 505 West 38th Street

    Scenario: Test from PR 419 #3
        When location is -73.9366203, 40.84837917
        Then address is 4200 Broadway

    Scenario: Addressing near Brooklyn Bridge
        When location is -73.99247, 40.70269
        Then address is 9 Dock Street

    Scenario: Addressing near Williamsburg Bridge to S 6th
        When location is -73.96665, 40.71181
        Then address is 45 South 6th Street

    Scenario: Addressing near Williamsburg Bridge to Wythe
        When location is -73.96639, 40.71171
        Then address is 424 Wythe Avenue

    Scenario: Holland Tunnel
        When location is -74.01876, 40.72721
        Then address is Holland Tunnel

    Scenario: Lincoln Tunnel
        When location is -74.00941, 40.76221
        Then address is Lincoln Tunnel

    Scenario: Hugh L Carey Tunnel
        When location is -74.01414, 40.69815
        Then address is Hugh L. Carey Tunnel

    Scenario: Brooklyn Bridge South
        When location is -73.99477, 40.70455
        Then address is Brooklyn Bridge

    Scenario: Brooklyn Bridge North
        When location is -73.99894, 40.70786
        Then address is Brooklyn Bridge

    Scenario: Manhattan Bridge
        When location is -73.99012, 40.70612
        Then address is Manhattan Bridge

    Scenario: Williamsburg Bridge
        When location is -73.97231, 40.71377
        Then address is Williamsburg Bridge

    Scenario: Queens-Midtown Tunnel
        When location is -73.96477, 40.74586
        Then address is Queens-Midtown Tunnel

    Scenario: Ed Koch Queensboro Bridge
        When location is -73.95761, 40.75830
        Then address is Ed Koch Queensboro Bridge Lower Level

    Scenario: Ed Koch Bridge, but close to another road
        When location is -73.95925, 40.75902
        Then address is York Avenue
        And distance to the result is 16 m
