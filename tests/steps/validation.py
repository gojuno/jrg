import json
import re
import math
from behave import then


def fail_message(data, expected=None, coords=None, osm=None):
    assert 'address' in data, 'Response does not contain address: {}'.format(json.dumps(data))

    lines = []
    if expected:
        if not isinstance(expected, dict):
            expected = expected.as_dict()
        lines.append('Expected: {}'.format(json.dumps(expected)))

    # Making a copy of the response dict
    response = {'address': data['address'].copy()}
    for k in list(data.keys()):
        if k in ('type', 'name', 'osm_type', 'osm_id'):
            response[k] = data[k]
    if expected:
        # Delete osm object if we didn't expect anything
        if 'osm_id' not in expected and 'osm_id' in response:
            for k in ('osm_type', 'osm_id'):
                del response[k]
        # Delete address keys that we don't expect
        for k in list(response['address'].keys()):
            if k in ('country', 'state', 'county', 'city', 'municipality', 'suburb',
                     'township', 'neighbourhood') and k not in expected:
                del response['address'][k]
    # If we expected only address details, unnest the dict
    if len(response) == 1:
        response = response['address']
    lines.append('Response: {}'.format(json.dumps(response)))

    # Finally add an SQL query and an OSM link to reproduce the error
    OSM_BASE = 'https://www.openstreetmap.org'
    OSM_TYPES = {'n': 'node', 'w': 'way', 'r': 'relation'}
    if coords:
        sql_query = 'select * from geocode_poi({}, {})'.format(coords[0], coords[1])
        osm_url = '{}/search?query={lat}%20{lon}#map=19/{lat}/{lon}&layers=D'.format(
            OSM_BASE, lon=coords[0], lat=coords[1])
    elif osm:
        sql_query = "select * from osm_lookup('{}', {})".format(osm[0], osm[1])
        osm_url = '{}/{}/{}'.format(OSM_BASE, OSM_TYPES[osm[0]], osm[1])
    else:
        sql_query = None
        osm_url = None

    if sql_query:
        lines.append('Object SQL query to reproduce: {}'.format(sql_query))
    if osm_url:
        lines.append('See this on the OSM website: {}'.format(osm_url))
    return '\n'.join(lines)


def response_has_tag(response, k, v, all_places=True):
        if k in ('type', 'name', 'osm_id', 'osm_type'):
            ctx = response
        else:
            ctx = response['address']
        if k == 'house':
            ctx_k = 'house_number'
        elif k == 'city' and 'city' not in ctx and all_places:
            ctx_k = k
            for place in ('town', 'village', 'locality'):
                if place in ctx:
                    ctx_k = place
                    break
        else:
            ctx_k = k

        if not v:
            return ctx_k not in ctx
        elif v is True:
            return ctx_k in ctx
        else:
            return str(ctx.get(ctx_k)) == str(v)


def check_for_error(context):
    resp = context.response
    if isinstance(resp, dict) and len(resp) == 1:
        rtype = list(resp.keys())[0]
        msg = json.dumps(list(resp.values())[0])
    else:
        rtype = 'error'
        msg = json.dumps(resp)
    assert context.response_code == 200, \
        'Got unexpected {} {}: {}'.format(
            rtype, context.response_code, msg)


def validate_row_impl(response, row, coords=None, osm=None):
    for k, v in row.items():
        msg = fail_message(response, row, coords, osm)
        assert response_has_tag(response, k, v), msg


def validate_row(context, row):
    check_for_error(context)
    validate_row_impl(context.response, row, coords=context.coord)


def validate_row_backwards(context, row):
    check_for_error(context)
    if 'osm_id' in context.response:
        osm = (context.response['osm_type'][0], context.response['osm_id'])
        response = context.geocoder.get_info(*osm)
        assert context.geocoder.last_code == 200, \
            'Got error {} while looking up {} {}: {}'.format(
                context.geocoder.last_code, *osm, response)
        validate_row_impl(response, row, osm=osm)
    else:
        raise AssertionError('No osm_id in response to validate the row backwards')


def validate_row_2way(context, row):
    check_for_error(context)
    validate_row_impl(context.response, row, coords=context.coord)
    if 'osm_id' in context.response:
        validate_row_backwards(context, row)


@then('response contains')
def validate_response(context):
    for row in context.table:
        validate_row_2way(context, row)


@then('response contains keys')
def validate_response_should_have(context):
    check_for_error(context)
    response = context.response
    msg = fail_message(response)
    for row in context.table:
        assert response_has_tag(response, row[0], True), msg


@then('response does not contain')
def validate_response_missing(context):
    check_for_error(context)
    response = context.response
    msg = fail_message(response)
    for row in context.table:
        assert response_has_tag(response, row[0], None), msg


@then('neighbourhood is {nei}, {suburb}')
def validate_neighbourhood_suburb(context, nei, suburb):
    validate_row_2way(context, {'neighbourhood': nei, 'suburb': suburb})


@then('neighbourhood is {nei}')
def validate_neighbourhood(context, nei):
    validate_row_2way(context, {'neighbourhood': nei})


@then('road is {road}')
def validate_road(context, road):
    validate_row(context, {'road': road})


@then('address is {address}')
def validate_address(context, address):
    if ',' in address:
        parts = address.split(',', 1)
        house, road = parts[0], parts[1]
    else:
        parts = address.split(None, 1)
        if len(parts) > 1 and re.match(r'[0-9-]+', parts[0]):
            house, road = parts[0], parts[1]
        else:
            house = None
            road = address
    validate_row_2way(context, {'house': house, 'road': road})


@then('postcode is {postcode}')
def validate_postcode(context, postcode):
    validate_row_2way(context, {'postcode': postcode})


@then('type is {typ:w}')
def validate_type(context, typ):
    validate_row_2way(context, {'type': typ})


@then('object is {osm_type:w} {osm_id:d}')
def validate_object(context, osm_type, osm_id):
    validate_row(context, {'osm_type': osm_type, 'osm_id': osm_id})


@then('object is not {osm_type:w} {osm_id:d}')
def validate_not_object(context, osm_type, osm_id):
    row = {'osm_type': osm_type, 'osm_id': osm_id}
    try:
        validate_row(context, row)
    except AssertionError:
        return
    raise AssertionError(fail_message(context.response, row, coords=context.coord))


@then('object is present')
def validate_object_present(context):
    check_for_error(context)
    response = context.response
    msg = fail_message(response)
    for k in ['osm_type', 'osm_id']:
        assert response_has_tag(response, k, True), msg


@then('city is {name}, {county}, {state}')
def validate_city(context, name, county, state):
    validate_row_2way(context, {
        'city': name,
        'county': county,
        'state': state
    })


@then('distance to the result is {dist} m')
@then('result is {dist} m away')
def validate_distance(context, dist):
    EARTH_MEAN_RADIUS = 6371008.8
    lon1 = float(context.coord[0]) / 57.2957795
    lat1 = float(context.coord[1]) / 57.2957795
    lon2 = float(context.response['lon']) / 57.2957795
    lat2 = float(context.response['lat']) / 57.2957795
    adist = EARTH_MEAN_RADIUS * math.sqrt(
        (lat2 - lat1)**2 + ((lon2 - lon1)*math.cos((lat1 + lat2) / 2.0))**2)
    assert round(adist) == int(dist), \
        'Expected {}, measured {} meters'.format(dist, round(adist))
