@big @admin
Feature: Cities and counties in NY and neighbouring states
    Taking a city from each of the counties.

    Scenario: Freeport, NY
        When location is -73.59, 40.66
        Then city is Freeport, Nassau County, New York

    Scenario: Riverhead, NY
        When location is -72.66, 40.93
        Then city is Riverhead, Suffolk County, New York

    Scenario: Mount Pleasant, NY
        When location is -73.80, 41.10
        Then city is Mount Pleasant, Westchester County, New York

    Scenario: Spring Valley, NY
        When location is -74.04, 41.11
        Then city is Spring Valley, Rockland County, New York

    Scenario: Newburgh, NY
        When location is -74.03, 41.50
        Then city is Newburgh, Orange County, New York

    Scenario: Carmel, NY
        When location is -73.68, 41.43
        Then city is Carmel, Putnam County, New York

    Scenario: Poughkeepsie, NY
        When location is -73.93, 41.70
        Then city is Poughkeepsie, Dutchess County, New York

    Scenario: Kingston, NY
        When location is -74.00, 41.93
        Then city is Kingston, Ulster County, New York

    Scenario: Fallsburg, NY
        When location is -74.60, 41.73
        Then city is Fallsburg, Sullivan County, New York

    Scenario: Delhi, NY
        When location is -74.92, 42.27
        Then city is Delhi, Delaware County, New York

    Scenario: Catskill, NY
        When location is -73.87, 42.22
        Then city is Catskill, Greene County, New York

    Scenario: Hudson, NY
        When location is -73.78, 42.25
        Then city is Hudson, Columbia County, New York

    Scenario: Albany, NY
        When location is -73.78, 42.68
        Then city is Albany, Albany County, New York

    Scenario: Brunswick, NY
        When location is -73.57, 42.74
        Then city is Brunswick, Rensselaer County, New York

    Scenario: Cobleskill, NY
        When location is -74.49, 42.68
        Then city is Cobleskill, Schoharie County, New York

    Scenario: Schenectady, NY
        When location is -73.94, 42.80
        Then city is Schenectady, Schenectady County, New York


    # New Jersey

    Scenario: Hoboken, NJ
        When location is -74.02, 40.75
        Then city is Hoboken, Hudson County, New Jersey

    Scenario: Ridgewood, NJ
        When location is -74.12, 40.98
        Then city is Ridgewood, Bergen County, New Jersey

    Scenario: Paterson, NJ
        When location is -74.17, 40.92
        Then city is Paterson, Passaic County, New Jersey

    Scenario: Vernon, NJ
        When location is -74.49, 41.20
        Then city is Vernon, Sussex County, New Jersey

    Scenario: Hackettstown, NJ
        When location is -74.83, 40.85
        Then city is Hackettstown, Warren County, New Jersey

    Scenario: Morristown, NJ
        When location is -74.48, 40.80
        Then city is Morristown, Morris County, New Jersey

    Scenario: Newark, NJ
        When location is -74.19, 40.73
        Then city is Newark, Essex County, New Jersey

    Scenario: Elizabeth, NJ
        When location is -74.19, 40.67
        Then city is Elizabeth, Union County, New Jersey

    Scenario: Somerville, NJ
        When location is -74.60, 40.57
        Then city is Somerville, Somerset County, New Jersey

    Scenario: Readington, NJ
        When location is -74.74, 40.57
        Then city is Readington, Hunterdon County, New Jersey

    Scenario: Trenton, NJ
        When location is -74.75, 40.21
        Then city is Trenton, Mercer County, New Jersey

    Scenario: New Brunswick, NJ
        When location is -74.44, 40.48
        Then city is New Brunswick, Middlesex County, New Jersey

    Scenario: Aberdeen, NJ
        When location is -74.22, 40.40
        Then city is Aberdeen, Monmouth County, New Jersey

    Scenario: Toms River, NJ
        When location is -74.20, 39.96
        Then city is Toms River, Ocean County, New Jersey

    Scenario: Burlington, NJ
        When location is -74.85, 40.07
        Then city is Burlington City, Burlington County, New Jersey

    Scenario: Camden, NJ
        When location is -75.12, 39.94
        Then city is Camden, Camden County, New Jersey

    Scenario: Woodbury, NJ
        When location is -75.15, 39.83
        Then city is Woodbury, Gloucester County, New Jersey

    Scenario: Atlantic City, NJ
        When location is -74.44, 39.37
        Then city is Atlantic City, Atlantic County, New Jersey

    Scenario: Cape May, NJ
        When location is -74.91, 38.94
        Then city is Cape May, Cape May County, New Jersey

    Scenario: Millville, NJ
        When location is -75.04, 39.41
        Then city is Millville, Cumberland County, New Jersey

    Scenario: Salem, NJ
        When location is -75.47, 39.57
        Then city is Salem, Salem County, New Jersey


    # Pennsylvania

    Scenario: Philadelphia, PY
        When location is -75.20, 40.00
        Then city is Philadelphia, Philadelphia County, Pennsylvania

    Scenario: Chester, PY
        When location is -75.36, 39.85
        Then city is Chester, Delaware County, Pennsylvania

    Scenario: Phoenixville, PY
        When location is -75.52, 40.13
        Then city is Phoenixville, Chester County, Pennsylvania

    Scenario: King of Prussia, PY
        When location is -75.38, 40.09
        Then city is King of Prussia, Montgomery County, Pennsylvania

    Scenario: Doylestown, PY
        When location is -75.14, 40.31
        Then city is Doylestown, Bucks County, Pennsylvania

    Scenario: Allentown, PY
        When location is -75.48, 40.60
        Then city is Allentown, Lehigh County, Pennsylvania

    Scenario: Easton, PY
        When location is -75.22, 40.69
        Then city is Easton, Northampton County, Pennsylvania

    Scenario: Mount Pocono, PY
        When location is -75.37, 41.12
        Then city is Mount Pocono, Monroe County, Pennsylvania

    Scenario: Milford, PY
        When location is -74.80, 41.32
        Then city is Milford, Pike County, Pennsylvania


    # Delaware

    Scenario: Wilmington, DE
        When location is -75.55, 39.74
        Then city is Wilmington, New Castle County, Delaware

    Scenario: Dover, DE
        When location is -75.52, 39.16
        Then city is Dover, Kent County, Delaware

    Scenario: Georgetown, DE
        When location is -75.38, 38.69
        Then city is Georgetown, Sussex County, Delaware


    # Maryland

    Scenario: Elkton, MD
        When location is -75.83, 39.61
        Then city is Elkton, Cecil County, Maryland

    Scenario: Aberdeen, MD
        When location is -76.16, 39.51
        Then city is Aberdeen, Harford County, Maryland

    Scenario: Towson, MD
        When location is -76.60, 39.40
        Then city is Towson, Baltimore County, Maryland

    Scenario: Baltimore, MD
        When location is -76.60, 39.30
        Then city is Baltimore, Baltimore, Maryland

    Scenario: Ellicott City, MD
        When location is -76.80, 39.27
        Then city is Ellicott City, Howard County, Maryland

    Scenario: Annapolis, MD
        When location is -76.50, 39.00
        Then city is Annapolis, Anne Arundel County, Maryland

    Scenario: Bethesda, MD
        When location is -77.10, 39.00
        Then city is Bethesda, Montgomery County, Maryland

    Scenario: Glenn Dale, MD
        When location is -76.82, 38.98
        Then city is Glenn Dale, Prince George's County, Maryland


    # District of Columbia

    Scenario: Washington, DC
        When location is -77.00, 38.90
        Then city is Washington, Washington, District of Columbia


    # Virginia

    Scenario: Arlington, VA
        When location is -77.10, 38.89
        Then city is Arlington, Arlington County, Virginia

    Scenario: Alexandria, VA
        When location is -77.06, 38.82
        Then city is Alexandria, Alexandria, Virginia

    Scenario: Falls Church, VA
        When location is -77.17, 38.89
        Then city is Falls Church, Falls Church City, Virginia

    Scenario: Annandale, VA
        When location is -77.20, 38.83
        Then city is Annandale, Fairfax County, Virginia

    Scenario: Fairfax, VA
        When location is -77.30, 38.85
        Then city is Fairfax, Fairfax, Virginia

    Scenario: Fairfax County Court House
        When location is -77.31, 38.845
        Then response contains
            | county         | state |
            | Fairfax County | Virginia |
        And response does not contain
            | key  |
            | city |


    # Connecticut

    Scenario: Bridgeport, CT
        When location is -73.20, 41.17
        Then city is Bridgeport, Fairfield, Connecticut

    Scenario: New Haven, CT
        When location is -72.90, 41.30
        Then city is New Haven, New Haven County, Connecticut

    Scenario: Torrington, CT
        When location is -73.12, 41.80
        Then city is Torrington, Litchfield County, Connecticut

    Scenario: Hartford, CT
        When location is -72.70, 41.75
        Then city is Hartford, Hartford County, Connecticut

    Scenario: Middletown, CT
        When location is -72.65, 41.56
        Then city is Middletown, Middlesex County, Connecticut

    Scenario: Mansfield, CT
        When location is -72.20, 41.77
        Then city is Mansfield, Tolland County, Connecticut

    Scenario: Putnam, CT
        When location is -71.90, 41.92
        Then city is Putnam, Windham County, Connecticut

    Scenario: New London, CT
        When location is -72.10, 41.35
        Then city is New London, New London County, Connecticut

    # Rhode Island

    Scenario: Providence, RI
        When location is -71.43, 41.84
        Then city is Providence, Providence County, Rhode Island

    Scenario: Warwick, RI
        When location is -71.40, 41.70
        Then city is Warwick, Kent County, Rhode Island

    Scenario: Briston, RI
        When location is -71.26, 41.69
        Then city is Bristol, Bristol County, Rhode Island

    Scenario: Newport, RI
        When location is -71.30, 41.50
        Then city is Newport, Newport County, Rhode Island

    Scenario: North Kingstown, RI
        When location is -71.47, 41.55
        Then city is North Kingstown, Washington County, Rhode Island

    # Massachusetts

    Scenario: Fall River, MA
        When location is -71.14, 41.70
        Then city is Fall River, Bristol County, Massachusetts

    Scenario: Brockton, MA
        When location is -71.00, 42.10
        Then city is Brockton, Plymouth County, Massachusetts

    Scenario: Quincy, MA
        When location is -71.00, 42.25
        Then city is Quincy, Norfolk County, Massachusetts

    Scenario: Boston, MA
        When location is -71.05, 42.35
        Then city is Boston, Suffolk County, Massachusetts

    Scenario: Beverly, MA
        When location is -70.88, 42.56
        Then city is Beverly, Essex County, Massachusetts

    Scenario: Lowell, MA
        When location is -71.30, 42.63
        Then city is Lowell, Middlesex County, Massachusetts

    Scenario: Worcester, MA
        When location is -71.80, 42.26
        Then city is Worcester, Worcester County, Massachusetts

    Scenario: Springfield, MA
        When location is -72.59, 42.10
        Then city is Springfield, Hampden County, Massachusetts

    Scenario: Northampton, MA
        When location is -72.64, 42.33
        Then city is Northampton, Hampshire County, Massachusetts

    Scenario: Greenfield, MA
        When location is -72.60, 42.60
        Then city is Greenfield, Franklin County, Massachusetts

    Scenario: Pittsfield, MA
        When location is -73.25, 42.45
        Then city is Pittsfield, Berkshire County, Massachusetts
