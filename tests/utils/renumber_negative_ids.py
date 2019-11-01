#!/usr/bin/env python3
try:
    from lxml import etree
except ImportError:
    import xml.etree.ElementTree as etree
import sys

if len(sys.argv) < 3:
    print('Takes an OSM file from JOSM and renumbers all negative ids.')
    print('Usage: {} <input.osm> <output.osm>'.format(sys.argv[0]))
    print('If the output file is "-", the input file is overwritten.')
    sys.exit(1)

osm_tree = etree.parse(sys.argv[1])
osm = osm_tree.getroot()

id_map = {}
def_not_exist_neg_id = -10000000
existing_ids = {k: set() for k in ('node', 'way', 'relation')}
for obj in osm:
    oid = int(obj.get('id'))
    if oid > 0:
        if oid in existing_ids[obj.tag]:
            # Found a duplicate id
            id_map[(obj.tag, obj.get('id'))] = def_not_exist_neg_id
            def_not_exist_neg_id -= 1
        existing_ids[obj.tag].add(int(obj.get('id')))

new_id = {'node': 10000, 'way': 1000, 'relation': 1}
for obj in osm:
    if obj.tag in ('node', 'way', 'relation'):
        k = (obj.tag, obj.get('id'))
        if obj.get('id')[0] == '-':
            while new_id[obj.tag] in existing_ids[obj.tag]:
                new_id[obj.tag] += 1
            id_map[k] = new_id[obj.tag]
            new_id[obj.tag] += 1
            obj.set('id', str(id_map[k]))
        else:
            id_map[k] = 0

for obj in osm:
    if obj.tag not in ('node', 'way', 'relation'):
        continue
    if obj.get('action') == 'delete' or obj.get('visible') == 'false':
        osm.remove(obj)
        continue
    if 'action' in obj.attrib:
        del obj.attrib['action']
    if 'version' not in obj.attrib:
        obj.set('version', '1')
    if obj.tag == 'way':
        for nd in obj.findall('nd'):
            new_id = id_map.get(('node', nd.get('ref')))
            if new_id is None:
                raise IndexError('Cannot find node {} referenced by way {}'.format(
                    nd.get('ref'), obj.get('id')))
            elif new_id > 0:
                nd.set('ref', str(new_id))
    elif obj.tag == 'relation':
        for nd in obj.findall('member'):
            k = (nd.get('type'), nd.get('ref'))
            new_id = id_map.get(k)
            if new_id is None:
                print('Removing relation {}, since {} {} was not found.'.format(
                    obj.get('id'), nd.get('type'), nd.get('ref')))
                osm.remove(obj)
                break
            elif new_id > 0:
                nd.set('ref', str(new_id))

out_file = sys.argv[1] if sys.argv[2] == '-' else sys.argv[2]
with open(out_file, 'wb') as f:
    osm_tree.write(f, encoding='utf-8')
