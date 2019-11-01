@unit
Feature: Bridges And Tunnels

    Scenario: Tunnels are good
        When point is bridges_and_tunnels01
        Then address is Queens-Midtown Tunnel

    Scenario: Bridges are also good
        When point is bridges_and_tunnels02
        Then address is Brooklyn Bridge

    Scenario: Test from PR 419 #1
        When point is bridges_and_tunnels03
        Then address is 516 West 39th Street

    Scenario: Test from PR 419 #2
        When point is bridges_and_tunnels04
        Then address is 505 West 38th Street

    Scenario: Test from PR 419 #3
        When point is bridges_and_tunnels05
        Then address is 4200 Broadway

    Scenario: Addressing near Brooklyn Bridge
        When point is bridges_and_tunnels06
        Then address is 9 Dock Street

    Scenario: Addressing near Williamsburg Bridge to S 6th
        When point is bridges_and_tunnels07
        Then address is 45 South 6th Street

    Scenario: Addressing near Williamsburg Bridge to Wythe
        When point is bridges_and_tunnels08
        Then address is 424 Wythe Avenue

    Scenario: Holland Tunnel
        When point is bridges_and_tunnels09
        Then address is Holland Tunnel

    Scenario: Lincoln Tunnel
        When point is bridges_and_tunnels10
        Then address is Lincoln Tunnel

    Scenario: Hugh L Carey Tunnel
        When point is bridges_and_tunnels11
        Then address is Hugh L. Carey Tunnel

    Scenario: Brooklyn Bridge South
        When point is bridges_and_tunnels12
        Then address is Brooklyn Bridge

    Scenario: Brooklyn Bridge North
        When point is bridges_and_tunnels13
        Then address is Brooklyn Bridge

    Scenario: Manhattan Bridge
        When point is bridges_and_tunnels14
        Then address is Manhattan Bridge

    Scenario: Williamsburg Bridge
        When point is bridges_and_tunnels15
        Then address is Williamsburg Bridge

    Scenario: Queens-Midtown Tunnel
        When point is bridges_and_tunnels16
        Then address is Queens-Midtown Tunnel

    Scenario: Ed Koch Queensboro Bridge
        When point is bridges_and_tunnels17
        Then address is Ed Koch Queensboro Bridge Lower Level

    Scenario: Ed Koch Bridge, but close to another road
        When point is bridges_and_tunnels18
        Then address is York Avenue
        And distance to the result is 16 m

