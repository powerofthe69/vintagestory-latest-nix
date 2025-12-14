#!/usr/bin/env bash
set -e

# Deps: curl, jq, sort (GNU), nix-prefetch-url

echo "Fetching version list from Vintage Story API..."
# We fetch once and store in a variable to avoid spamming their API
JSON_DATA=$(curl -sLf https://mods.vintagestory.at/api/gameversions)

if [ -z "$JSON_DATA" ]; then
    echo "Failed to fetch version list from Vintage Story API." >&2
    exit 1
fi

LATEST_VER=$(echo "$JSON_DATA" | jq -r '.gameversions[-1].name')
STABLE_VER=$(echo "$JSON_DATA" | jq -r '[.gameversions[].name | select(contains("-") | not)] | last')
UNSTABLE_VER=$(echo "$JSON_DATA" | jq -r '[.gameversions[].name | select(contains("-"))] | last')

echo "Calculated Versions (based on API order):"
echo "  Latest:   $LATEST_VER"
echo "  Stable:   $STABLE_VER"
echo "  Unstable: $UNSTABLE_VER"

# Helper function to generate JSON object for a specific version
generate_source() {
    local ver=$1
    local type=$2 # 'stable' or 'unstable' based on the version string

    # Logic to determine folder path
    if [[ "$ver" == *"-"* ]]; then
        folder="unstable"
    else
        folder="stable"
    fi

    local url="https://cdn.vintagestory.at/gamefiles/$folder/vs_client_linux-x64_$ver.tar.gz"

    echo "  Processing $type ($ver)..." >&2
    local hash=$(nix-prefetch-url "$url")

    # Return JSON object
    jq -n --arg v "$ver" --arg u "$url" --arg h "$hash" \
       '{version: $v, url: $u, hash: $h}'
}

# Generate the JSON blobs
# We use a temporary file or subshells to build the final JSON
jq -n \
   --argjson stable "$(generate_source $STABLE_VER 'stable')" \
   --argjson unstable "$(generate_source $UNSTABLE_VER 'unstable')" \
   --argjson latest "$(generate_source $LATEST_VER 'latest')" \
   '{stable: $stable, unstable: $unstable, latest: $latest}' > sources.json

echo "Done. sources.json updated."
