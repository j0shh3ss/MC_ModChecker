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

    local url="https://api.modrinth.com/v2/project/$project/version?game_versions=%5B%22$MC_VERSION%22%5D"

    if [[ "${MOD_USE_LOADER[$mod_name]}" == "true" ]]; then
        url+="&loaders=%5B%22$LOADER%22%5D"
    fi

    local response
    if ! response=$(curl -fsS \
        -A "$USER_AGENT" \
        --connect-timeout 10 \
        --max-time 30 \
        "$url"); then
        echo "ERROR: Modrinth request failed for $project; skipping."
        return 0
    fi

    local latest_version
    latest_version=$(jq -r '
        map(select(.version_type == "release"))
        | sort_by(.date_published)
        | last
        | .version_number // empty
    ' <<< "$response")

    if [[ -z "$latest_version" ]]; then
        echo "ERROR: No compatible release found for $project; skipping."
        return 0
    fi

    latest_version=$(sed -E \
        's/^mc[0-9.]+-([0-9.]+)-fabric$/\1/' <<< "$latest_version")

    echo "Latest: $latest_version"

    if (( ${#mod_files[@]} == 0 )); then
        echo "Mod is not installed."
        return 0
    fi

    local mod_file="${mod_files[0]}"
    local filename
    filename=$(basename "$mod_file")

    local current_version
    current_version=$(sed -E \
        "s/^${project}-${LOADER}-([0-9.]+)\+.*\.jar$/\1/" \
        <<< "$filename")

    if [[ "$current_version" == "$filename" ]]; then
        echo "ERROR: Could not parse installed version from $filename"
        return 0
    fi

    echo "Current: $current_version"

    local highest_version
    highest_version=$(printf '%s\n' "$current_version" "$latest_version" |
        sort -V | tail -n1)

    if [[ "$current_version" == "$latest_version" ]]; then
        echo "$mod_name is up to date."
    elif [[ "$highest_version" == "$latest_version" ]]; then
        echo "$mod_name has an update available: $current_version -> $latest_version"
    else
        echo "$mod_name is newer than the latest Modrinth release."
    fi
}


for mod in "${!MOD_PROJECTS[@]}"; do
        check_mod "$mod"
done
