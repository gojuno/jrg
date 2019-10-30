from behave import when


@when('location is {lon}, {lat}')
def reverse_geocode(context, lon, lat):
    context.coord = (lon, lat)
    context.response = context.geocoder.reverse(lon, lat)
    context.response_code = context.geocoder.last_code


@when('object is {osm_type} {osm_id}')
def get_info(context, osm_type, osm_id):
    context.osm = (osm_type, osm_id)
    context.response = context.geocoder.get_info(osm_type[0], osm_id)
    context.response_code = context.geocoder.last_code


@when('point is {point}')
def find_point(context, point):
    lonlat = context.points[point]
    reverse_geocode(context, lonlat[0], lonlat[1])
