#!/usr/bin/env python3
from flask import Flask
from flask_cors import CORS
from flask_restful import Api, Resource, reqparse
from psycopg2.pool import ThreadedConnectionPool
from contextlib import contextmanager


app = Flask(__name__)
app.config.from_object('config')

CORS(app)
api = Api(app)

parser = reqparse.RequestParser()
parser.add_argument('osm_type', choices=('n', 'w', 'r'), case_sensitive=False,
                    help='Missing osm_type', location='args')
parser.add_argument('osm_id', type=int, help='Missing osm_id', location='args')
parser.add_argument('lat', type=float, help='Missing lat', location='args')
parser.add_argument('lon', type=float, help='Missing lon', location='args')
parser.add_argument('lang', type=str, help='Missing lang', default='', location='args')
parser.add_argument('admin', type=int, choices=(0, 1), default=1,
                    help='Use admin=0 to disable admin query', location='args')

pool = ThreadedConnectionPool(
    minconn=1, maxconn=12,
    host=app.config['PG_HOST'],
    port=app.config['PG_PORT'],
    dbname=app.config['PG_DATABASE'],
    user=app.config['PG_USER']
)


@contextmanager
def get_db_connection():
    try:
        connection = pool.getconn()
        yield connection
    finally:
        pool.putconn(connection)


@contextmanager
def get_cursor():
    with get_db_connection() as conn:
        cursor = conn.cursor()
        try:
            yield cursor
        finally:
            cursor.close()


class ReverseGeocoder(Resource):
    def pack_response(self, result):
        if not result:
            return None
        data = {
            'type': result[0],
            'osm_type': result[1],
            'osm_id': result[2],
            'address': {
                'road': result[3],
                'house_number': result[4],
                'postcode': result[5],
            },
            'lon': None if result[6] is None else str(result[6]),
            'lat': None if result[7] is None else str(result[7]),
            'name': result[8],
        }
        for k, v in data['address'].items():
            if v and ';' in v:
                data['address'][k] = v.split(';', 1)[0]
        return data

    def closest_object(self, lon, lat, lang):
        with get_cursor() as cur:
            if lang:
                cur.execute("select * from geocode_poi(%s, %s, %s)", (lon, lat, lang))
            else:
                cur.execute("select * from geocode_poi_ml(%s, %s)", (lon, lat))
            return self.pack_response(cur.fetchone())

    def object_info(self, osm_type, osm_id):
        with get_cursor() as cur:
            cur.execute("select * from osm_lookup(%s, %s)", (osm_type, osm_id))
            return self.pack_response(cur.fetchone())

    def address(self, lon, lat, lang):
        result = {}
        obj = None
        with get_cursor() as cur:
            if lang:
                cur.execute("select * from geocode_admin(%s, %s, %s)", (lon, lat, lang))
            else:
                cur.execute("select * from geocode_admin_ml(%s, %s)", (lon, lat))
            for row in cur:
                result[row[0]] = row[1]
                obj = {
                    'osm_type': row[2],
                    'osm_id': row[3],
                    'lon': str(row[4]),
                    'lat': str(row[5]),
                }
        if obj and obj['osm_id'] == 0:
            obj = None
        return result, obj

    def make_display_name(self, obj, lang):
        if obj['address'].get('road') is not None:
            if lang:
                road = obj['address']['road']
            else:
                road = obj['address']['road']['def']
            if obj['address'].get('house_number') is not None:
                return '{} {}'.format(obj['address']['house_number'], road)
            return road
        return obj.get('name')

    def prune_dict(self, obj):
        for k in list(obj.keys()):
            if obj[k] is None:
                del obj[k]
            elif isinstance(obj[k], dict):
                self.prune_dict(obj[k])

    def get(self):
        args = parser.parse_args()
        if (args.lon is not None or args.lat is not None) and (args.osm_id or args.osm_type):
            return {'error': 'Please use either coordinates or osm id'}, 400
        if args.lon is not None and args.lat is not None:
            obj = self.closest_object(args.lon, args.lat, args.lang) or {}
        elif args.osm_id and args.osm_type:
            obj = self.object_info(args.osm_type, args.osm_id) or {}
            if not obj or not obj.get('osm_id'):
                return {'error': 'Unable to geocode'}, 404
        else:
            return {'error': 'Missing request arguments'}, 400

        if 'address' not in obj:
            obj['address'] = {}
        if args.admin != 0:
            if args.lon is not None:
                address, backup_osm = self.address(args.lon, args.lat, args.lang)
                if backup_osm and obj.get('osm_type') is None:
                    obj.update(backup_osm)
            elif obj.get('lon') is not None:
                address, _ = self.address(float(obj['lon']), float(obj['lat']))
            else:
                address = None
            obj['address'].update(address or {})
            if 'type' not in obj:
                obj['type'] = 'admin'

        if obj.get('osm_type') is None:
            return {'error': 'Unable to geocode'}, 404

        obj['display_name'] = self.make_display_name(obj, args.lang)
        self.prune_dict(obj)
        return obj


api.add_resource(ReverseGeocoder, '/reverse')
