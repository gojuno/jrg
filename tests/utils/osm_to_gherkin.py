#!/usr/bin/env python3
import os
import sys
import xml.etree.ElementTree as etree
from collections import defaultdict


if len(sys.argv) < 2:
    print('Usage: {} [<osm>] <dest_path>'.format(sys.argv[0]))
    sys.exit(1)

filename = sys.argv[1] if len(sys.argv) > 2 else os.path.join(
    os.path.dirname(__file__), '..', 'unit_data.osm')
osm = etree.parse(filename).getroot()
features = defaultdict(list)
for node in osm.findall('node'):
    tags = {t.get('k'): t.get('v') for t in node.findall('tag')}
    if 'feature' in tags and 'name' in tags and 'skip' not in tags:
        scen = {'name': tags['name']}
        scen['when'] = 'location is {}, {}'.format(node.get('lon'), node.get('lat'))
        for k in ('then', 'and', 'and1', 'note', 'sid'):
            if k in tags:
                scen[k] = tags[k]
        scen['tags'] = set(['@{}'.format(t) for t, v in tags.items() if v == 'yes'])
        features[tags['feature']].append(scen)

basepath = sys.argv[-1]
if not os.path.exists(basepath):
    os.makedirs(basepath)
for feat, scenarios in features.items():
    filename = os.path.join(basepath, feat + '.feature')
    ftags = scenarios[0].get('tags', set())
    for scen in scenarios:
        ftags = ftags.intersection(scen['tags'] or set())
    ftags.add('@unit')
    with open(filename, 'w') as f:
        if ftags:
            print(' '.join(ftags), file=f)
        print(f'Feature: {feat.replace("_", " ").title()}', file=f)
        print(file=f)
        for scen in sorted(scenarios, key=lambda s: s.get('sid', 'zzz')):
            if 'tags' in scen and scen['tags'] - ftags:
                print('    ' + ' '.join(scen['tags'] - ftags), file=f)
            print(f'    Scenario: {scen["name"]}', file=f)
            if 'note' in scen:
                print('        ' + scen['note'], file=f)
                print(file=f)
            print(f'        When {scen["when"]}', file=f)
            for k in (('then', 'Then'), ('and', 'And'), ('and1', 'And')):
                if k[0] in scen:
                    check = scen[k[0]]
                    if 'response' in check and ':' in check:
                        values = ['key'] + [v.strip() for v in
                                            check[check.index(':')+1:].split(',')]
                        check = check[:check.index(':')]
                    else:
                        values = []
                    print(f'        {k[1]} {check}', file=f)
                    for v in values:
                        print(f'            | {v} |', file=f)
            print(file=f)
