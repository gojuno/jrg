#!/usr/bin/env python3
import os
import re


def parse_feature_file(filename):
    RE_LINE = re.compile(r'^\s*(Feature:|Scenario:|When|Then|And)\s+(.+)$', re.I)
    RE_COORD = re.compile(r'location is (-?[\d.]+), (-?[\d.]+)')
    scenarios = []
    scen = {}
    tags = set()
    ftags = set()
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            m = RE_LINE.match(line)
            if m:
                typ = m.group(1).lower()[:2]
                if typ == 'sc':
                    if scen:
                        scenarios.append(scen)
                    scen = {'name': m.group(2)}
                    for t in tags | ftags:
                        scen[t] = 'yes'
                    tags.clear()
                elif typ == 'fe':
                    if tags:
                        ftags = tags
                        tags = set()
                elif typ == 'wh':
                    if scen:
                        m2 = RE_COORD.match(m.group(2))
                        if not m2:
                            print('<!-- unknown query: {} -->'.format(m.group(2)))
                            scen = {}
                        else:
                            scen['lon'] = m2.group(1)
                            scen['lat'] = m2.group(2)
                elif typ == 'th' or typ == 'an':
                    if scen:
                        if 'response' in m.group(2):
                            scen['skip'] = 'yes'
                        if typ == 'th':
                            k = 'then'
                        elif typ == 'an':
                            if 'and' not in scen:
                                k = 'and'
                            else:
                                i = 1
                                while f'and{i}' in scen:
                                    i += 1
                                k = f'and{i}'
                        scen[k] = m.group(2)
                else:
                    raise ValueError('Unknown scenario clause: ' + m.group(1))
            elif len(line) > 1 and line[0] == '@':
                tags.update([t[1:] for t in line.split() if t[0] == '@'])
            elif len(line) > 0 and scen and line[0] != '|':
                scen['note'] = (scen.get('note', '') + ' ' + line).strip()
    if scen:
        scenarios.append(scen)
    return scenarios


if __name__ == '__main__':
    nid = 1
    print('<?xml version="1.0" encoding="utf-8"?><osm version="0.6">')
    for feature in os.listdir('features'):
        if feature.endswith('.feature'):
            name = feature[:feature.index('.')]
            if name in ('errors', 'load'):
                continue
            for i, scen in enumerate(parse_feature_file(os.path.join('features', feature))):
                tags = {
                    'feature': name,
                    'sid': '{}{}'.format(name, i+1),
                }
                for k, v in scen.items():
                    if k not in ('lat', 'lon'):
                        tags[k] = v
                print('  <node id="{}" version="1" lon="{}" lat="{}">'.format(
                    nid, scen['lon'], scen['lat']))
                for k, v in tags.items():
                    print('    <tag k="{}" v="{}" />'.format(
                        k, v.replace('&', '&amp;').replace('<', '&lt;').replace('"', '&quot;')))
                print('  </node>')
                nid += 1
    print('</osm>')
