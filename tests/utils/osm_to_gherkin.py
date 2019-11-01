#!/usr/bin/env python3
import os
import sys
import argparse
import xml.etree.ElementTree as etree
from collections import defaultdict


def parse_osm(filename):
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
    return features


def print_then(typ, check, indent, f):
    if 'response' in check and ':' in check:
        # Produce a 2d table out of a list of values, either plain or k=v.
        parts = [v.strip() for v in check[check.index(':')+1:].split(',')]
        if '=' in parts[0]:
            values = [[], []]
            for part in parts:
                s = [p.strip() for p in part.split('=')]
                values[0].append(s[0])
                values[1].append(s[1])
        else:
            values = [['key']] + [[p] for p in parts]
        check = check[:check.index(':')]
    else:
        values = []
    print(f'{indent}{typ} {check}', file=f)
    for v in values:
        print('{}    | {} |'.format(indent, ' | '.join(v)), file=f)


def print_scenario(scen, f):
    indent = '    '
    print(f'{indent}Scenario: {scen["name"]}', file=f)
    indent = indent + indent
    if 'note' in scen:
        print(indent + scen['note'], file=f)
        print(file=f)
    print(f'{indent}When {scen["when"]}', file=f)
    for k in (('then', 'Then'), ('and', 'And'), ('and1', 'And')):
        if k[0] in scen:
            print_then(k[1], scen[k[0]], indent, f)
    print(file=f)


def write_feature(name, scenarios, f):
    ftags = scenarios[0].get('tags', set())
    for scen in scenarios:
        ftags = ftags.intersection(scen['tags'] or set())
    ftags.add('@unit')
    if ftags:
        print(' '.join(ftags), file=f)
    name = name.replace('_', ' ').title()
    print('Feature: '+name, file=f)
    print(file=f)
    for scen in sorted(scenarios, key=lambda s: s.get('sid', 'zzz')):
        if 'tags' in scen and scen['tags'] - ftags:
            print('    ' + ' '.join(scen['tags'] - ftags), file=f)
        print_scenario(scen, f)


if __name__ == '__main__':
    default_osm = os.path.join(os.path.dirname(__file__), '..', 'unit_data.osm')

    parser = argparse.ArgumentParser(
        description='Takes an OSM file and produces Gherkin feature files from it')
    parser.add_argument('dest', help='Target path for feature files')
    parser.add_argument('-i', '--input', default=default_osm, help='OSM file to parse')
    options = parser.parse_args()

    features = parse_osm(options.input)

    if not os.path.exists(options.dest):
        os.makedirs(options.dest)

    for feat, scenarios in features.items():
        filename = os.path.join(options.dest, feat + '.feature')
        with open(filename, 'w') as f:
            write_feature(feat, scenarios, f)
