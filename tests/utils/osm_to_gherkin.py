#!/usr/bin/env python3
import os
import xml.etree.ElementTree as etree
from collections import defaultdict

osm = etree.parse(os.path.join(os.path.dirname(__file__), '..', 'unit_data.osm')).getroot()
features = defaultdict(list)
for node in osm.findall('node'):
    tags = {t.get('k'): t.get('v') for t in node.findall('tag')}
    if 'feature' in tags and 'name' in tags and 'skip' not in tags:
        scen = {'name': tags['name']}
        scen['when'] = 'location is {}, {}'.format(node.get('lon'), node.get('lat'))
        for k in ('then', 'and', 'note'):
            if k in tags:
                scen[k] = tags[k]
        scen['tags'] = set(['@{}'.format(t) for t, v in tags.items() if v == 'yes'])
        features[tags['feature']].append(scen)

for feat, scenarios in features.items():
    filename = os.path.join(os.path.dirname(__file__), '..', 'features', feat + '.feature')
    if os.path.exists(filename):
        filename = filename.replace('.feat', '2.feat')
    ftags = scenarios[0].get('tags', set())
    for scen in scenarios:
        ftags = ftags.intersection(scen['tags'] or set())
    with open(filename, 'w') as f:
        if ftags:
            print(' '.join(ftags), file=f)
        print(f'Feature: {feat.replace("_", " ").title()}', file=f)
        print(file=f)
        for scen in scenarios:
            if 'tags' in scen and scen['tags'] != ftags:
                print('    ' + ' '.join(scen['tags'] - ftags), file=f)
            print(f'    Scenario: {scen["name"]}', file=f)
            if 'note' in scen:
                print('        ' + scen['note'], file=f)
                print(file=f)
            print(f'        When {scen["when"]}', file=f)
            print(f'        Then {scen["then"]}', file=f)
            if 'and' in scen:
                print(f'        And {scen["and"]}', file=f)
            print(file=f)
