import asyncio
from . import config
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from psycopg_pool import AsyncConnectionPool


app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
)
pool = AsyncConnectionPool(
    kwargs={
        'host': config.PG_HOST,
        'port': config.PG_PORT,
        'dbname': config.PG_DATABASE,
        'user': config.PG_USER,
    },
    open=False,
)


async def check_connections():
    while True:
        await asyncio.sleep(600)
        await pool.check()


@asynccontextmanager
async def get_cursor():
    async with pool.connection() as conn:
        cursor = conn.cursor()
        try:
            yield cursor
        finally:
            await cursor.close()


@app.on_event('startup')
async def startup():
    await pool.open()
    asyncio.create_task(check_connections())


@app.get('/')
async def root():
    return {'name': 'JRG', 'version': '1.1.0'}


def pack_response(result):
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


async def closest_object(lon, lat):
    async with get_cursor() as cur:
        await cur.execute("select * from geocode_poi(%s::numeric, %s::numeric)", (lon, lat))
        return pack_response(await cur.fetchone())


async def object_info(osm_type, osm_id):
    async with get_cursor() as cur:
        await cur.execute(
            "select * from osm_lookup(%s, %s)", (osm_type, osm_id))
        return pack_response(await cur.fetchone())


async def q_address(lon, lat):
    result = {}
    obj = None
    async with get_cursor() as cur:
        await cur.execute("select * from geocode_admin(%s::numeric, %s::numeric)", (lon, lat))
        async for row in cur:
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


def make_display_name(obj):
    if obj['address'].get('road') is not None:
        if obj['address'].get('house_number') is not None:
            return '{} {}'.format(
                obj['address']['house_number'],
                obj['address']['road'])
        return obj['address']['road']
    return obj.get('name')


def prune_dict(obj):
    for k in list(obj.keys()):
        if obj[k] is None:
            del obj[k]
        elif isinstance(obj[k], dict):
            prune_dict(obj[k])


@app.get('/reverse')
async def get(lon: float | None = None, lat: float | None = None,
              osm_id: int | None = None, osm_type: str | None = None,
              admin: bool = True):
    if (lon is not None or lat is not None) and (osm_id or osm_type):
        return {'error': 'Please use either coordinates or osm id'}, 400
    if lon is not None and lat is not None:
        obj = await closest_object(lon, lat) or {}
    elif osm_id and osm_type:
        obj = await object_info(osm_type, osm_id) or {}
        if not obj or not obj.get('osm_id'):
            return {'error': 'Unable to geocode'}, 404
    else:
        return {'error': 'Missing request arguments'}, 400

    if 'address' not in obj:
        obj['address'] = {}
    if admin != 0:
        if lon is not None:
            address, backup_osm = await q_address(lon, lat)
            if backup_osm and obj.get('osm_type') is None:
                obj.update(backup_osm)
        elif obj.get('lon') is not None:
            address, _ = await q_address(float(obj['lon']), float(obj['lat']))
        else:
            address = None
        obj['address'].update(address or {})
        if 'type' not in obj:
            obj['type'] = 'admin'

    if obj.get('osm_type') is None:
        return {'error': 'Unable to geocode'}, 404

    obj['display_name'] = make_display_name(obj)
    prune_dict(obj)
    return obj
