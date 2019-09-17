import random
import time
from behave import given, when, then


def load_test(context, objects=None, duration=2.0):
    admin = not hasattr(context, 'disable_admin') or not context.disable_admin
    random.seed()
    count = 0
    end = time.perf_counter() + duration
    while time.perf_counter() < end:
        if objects is None:
            context.geocoder.reverse(
                random.uniform(context.minlon, context.maxlon),
                random.uniform(context.minlat, context.maxlat),
                admin=admin)
        else:
            obj = random.choice(objects)
            context.geocoder.get_info(*obj, admin=admin)
        count += 1
    return round(count / duration, 1)


@given('bounding box {minlon}, {minlat}, {maxlon}, {maxlat}')
def set_bounding_box(context, minlon, minlat, maxlon, maxlat):
    context.minlon = float(minlon)
    context.minlat = float(minlat)
    context.maxlon = float(maxlon)
    context.maxlat = float(maxlat)


@given('list of OSM objects')
def set_objects(context):
    objects = []
    for row in context.table:
        parts = row[0].split()
        assert len(parts) == 2
        assert parts[0] in ('node', 'way', 'relation')
        assert parts[1].isdigit()
        objects.append((parts[0][0], int(parts[1])))
    context.objects = objects


@given('admin areas disabled')
def disable_admin(context):
    context.disable_admin = True


@when('testing load by coordinate requests')
def load_test_by_coord(context):
    context.rps = load_test(context)


@when('testing load by coordinate requests for {sec} seconds')
def load_test_by_coord_sec(context, sec):
    context.rps = load_test(context, duration=float(sec))


@when('testing load by object requests')
def load_test_by_objects(context):
    context.rps = load_test(context, context.objects)


@when('testing load by object requests for {sec} seconds')
def load_test_by_objects_sec(context, sec):
    context.rps = load_test(context, context.objects, duration=float(sec))


@then('RPS is greater than {rps}')
def validate_rps(context, rps):
    assert context.rps > float(rps), 'RPS is {}'.format(context.rps)
