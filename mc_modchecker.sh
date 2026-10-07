#!/bin/bash
set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "0")" && pwd)"

source "$SCRIPT_DIR/config.sh"

echo "Minecraft Version: $MC_VERSION"
echo "Loader: $LOADER"
echo "Mods Directory: $MODS_DIR"

echo

for mod in "${!MOD_PROJECTS[@]}"; do
        project="${MOD_PROJECTS[$mod]}"

        echo "Checking: $mod"
        echo "Modrinth Project: $project"
        echo
done


SCRIPT_DIR="$(cd "$(dirname "0")" && pwd)"
MODS_DIR="/home/whats1ttoya/tests/mod_auto_update/mods"


CURRENT_VERSION=$(basename $MODS_DIR/lithium-*.jar)
CURRENT_VERSION=$(echo "$CURRENT_VERSION" | sed -E 's/^lithium-fabric-([0-9.]+)\+.*\.jar$/\1/')
echo "Installed: $CURRENT_VERSION"



OLD_VERSION=$(
  curl -s "https://api.modrinth.com/v2/project/lithium/version?game_versions=%5B%2226.3%22%5D&loaders=%5B%22fabric%22%5D" |
  jq -r 'sort_by(.date_published) | last | .version_number'
)
LATEST_VERSION=$(
        curl -s "https://api.modrinth.com/v2/project/lithium/version?game_versions=%5B%2226.3%22%5D&loaders=%5B%22fabric%22%5D" |
        jq -r '
                map(select(.version_type == "release"))
                | sort_by(.date_published)
                | last
                | .version_number
        '
)
LATEST_VERSION=$(echo "$LATEST_VERSION" | sed -E 's/^mc[0-9.]+-([0-9.]+)-fabric$/\1/')
echo "Available: $LATEST_VERSION"
