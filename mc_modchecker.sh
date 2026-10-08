#!/bin/bash

set -Eeuo pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODS_DIR="/home/whats1ttoya/tests/mod_auto_update/mods"

source "$SCRIPT_DIR/config.sh"

check_mod() {
    local mod_name="$1"
    local project="${MOD_PROJECTS[$mod_name]}"
        local mod_files=("$MODS_DIR"/"$project"-*.jar)

    echo "Checking $mod_name..."

    local latest_version
    latest_version=$(
        curl -sS \
                -A "$USER_AGENT" \
                --connect-timeout 10 \
                --max-time 30 \
                "https://api.modrinth.com/v2/project/$project/version?game_versions=%5B%22$MC_VERSION%22%5D&loaders=%5B%22$LOADER%22%5D" |
        jq -r '
            map(select(.version_type == "release"))
            | sort_by(.date_published)
            | last
            | .version_number
        '
    )
        latest_version=$(echo "$latest_version" | sed -E 's/^mc[0-9.]+-([0-9.]+)-fabric$/\1/')

    echo "Latest: $latest_version"
        if (( ${#mod_files[@]} > 0 )); then
                local current_version
                current_version=$(basename "${mod_files[0]}")
                current_version=$(echo "$current_version" | sed -E "s/^${project}-${LOADER}-([0-9.]+)\+.*\.jar$/\1/")
                echo "Current: $current_version"
                local status
                status=false
                if echo -e "$current_version\n$latest_version" | sort -V -C; then
                        if ["$current_version" != "$latest_version"]; then
                                status=true
                        else
                                status=false
                        fi
                else
                        status=false
                fi
                if [ "$status" = true ]; then
                        echo "$project Has updates available, version: $current_version, is less than $latest_version"
                fi
        else
                echo "Mod is not installed."
        fi 
}

for mod in "${!MOD_PROJECTS[@]}"; do
        check_mod "$mod"
done
