import os
import json
from urllib.error import HTTPError
from urllib.request import urlopen
from urllib.parse import urlencode
import xml.etree.ElementTree as etree


class SimpleGeocoder:
    def __init__(self, host=None, port=None):
        if host is None:
            host = os.getenv('GEOCODER_HOST', 'localhost')
        if port is None:
            port = int(os.getenv('GEOCODER_PORT', 5000))
        self.endpoint = 'http://{}:{}/reverse'.format(host, port)

    def _request(self, **kwargs):
        url = '{}?{}'.format(self.endpoint, urlencode(kwargs))
        try:
            with urlopen(url) as resp:
                self.last_code = resp.getcode()
                return json.load(resp)
        except HTTPError as e:
            self.last_code = e.code
            resp = e.read()
            if resp:
                return json.loads(resp)

    def reverse(self, lon, lat, admin=True):
        if admin:
            return self._request(lon=lon, lat=lat)
        return self._request(lon=lon, lat=lat, admin=0)

    def get_info(self, osm_type, osm_id, admin=True):
        if admin:
            return self._request(osm_type=osm_type, osm_id=osm_id)
        return self._request(osm_type=osm_type, osm_id=osm_id, admin=0)


def load_coords():
    coords = {}
    osm = etree.parse(os.path.join(os.path.dirname(__file__), 'unit_data.osm')).getroot()
    for node in osm.findall('node'):
        tags = {t.get('k'): t.get('v') for t in node.findall('tag')}
        if 'sid' in tags:
            coords['sid'] = (node.get('lon'), node.get('lat'))
    return coords


def before_all(context):
    context.geocoder = SimpleGeocoder()
    context.points = load_coords()
