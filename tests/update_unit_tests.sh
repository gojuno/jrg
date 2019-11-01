#!/bin/bash
HERE="$(dirname "$0")"
"$HERE/utils/renumber_negative_ids.py" "$HERE/unit_data.osm" -
[ -d "$HERE/features_auto" ] && rm -f "$HERE/features_auto"/*.feature
"$HERE/utils/osm_to_gherkin.py" -i "$HERE/unit_data.osm" "$HERE/features_auto"
