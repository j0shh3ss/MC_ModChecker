#!/bin/bash

set -Eeuo pipefail
shopt -s nullglob

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/config.sh"


check_mod() {
    local mod_name="$1"
    local project="${MOD_PROJECTS[$mod_name]}"

        local mod_files=("$MODS_DIR"/"$project"-*.jar)

    echo "Checking $mod_name..."

    local latest_version
    latest_version=$(
        curl -fsS \
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

    if [[ -z "$latest_version" || "$latest_version" == "null" ]]; then
                echo "ERROR: Could not determine latest version for $project."
                return 1
    fi

    echo "Latest: $latest_version"
        if (( ${#mod_files[@]} > 0 )); then
                local mod_file="${mod_files[0]}"
                local current_version
                current_version=$(basename "$mod_file")
                current_version=$(echo "$current_version" | sed -E "s/^${project}-${LOADER}-([0-9.]+)\+.*\.jar$/\1/")
                echo "Current: $current_version"
                local highest_version
                highest_version=$(printf '%s\n' "$current_version" "$latest_version" | sort -V | tail -n1)

                if [[ "$current_version" != "$latest_version" && "$highest_version" == "$latest_version" ]]; then
                        echo "$project has an update available: $current_version -> $latest_version"
                elif [[ "$current_version" == "$latest_version" ]]; then
                        echo "$project is up to date."
                else
                        echo "$project is newer than the latest version avail. How?"
                fi
        else
                echo "Mod is not installed."
        fi 
}

for mod in "${!MOD_PROJECTS[@]}"; do
        check_mod "$mod"
done
