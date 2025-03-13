#!/bin/bash

# Default values
BASE_PATH="/fastdl-vol1/files/tf"
MAPS_DIR="$BASE_PATH/maps"

# Function to display usage information
show_usage() {
    echo "Usage: $0 QUERY_URL POOL_DIR"
    echo ""
    echo "Arguments:"
    echo "  QUERY_URL  The full API query URL (in quotes)"
    echo "  POOL_DIR   The directory name for the map pool (e.g., tf2-rgl-6s-pool, tf2-rgl-hl-pool)"
    echo ""
    echo "Examples:"
    echo "  $0 \"https://www.dolthub.com/api/v1alpha1/fullbuff/fb-atlas/main?q=SELECT+*%0AFROM+%60tf2_rgl_seasons%60%0AWhere+%60name%60+LIKE+%27%256s+Season%25%27%0AORDER+BY+%60seasonId%60+DESC%0ALIMIT+1%3B%0A\" tf2-rgl-6s-pool"
    echo "  $0 \"https://www.dolthub.com/api/v1alpha1/fullbuff/fb-atlas/main?q=SELECT+*%0AFROM+%60tf2_rgl_seasons%60%0AWhere+%60name%60+LIKE+%27%25HL+Season%25%27%0AORDER+BY+%60seasonId%60+DESC%0ALIMIT+1%3B%0A\" tf2-rgl-hl-pool"
}

# Check for correct number of arguments
if [ $# -ne 2 ]; then
    echo "Error: Exactly two arguments are required."
    show_usage
    exit 1
fi

API_QUERY="$1"
POOL_DIR="$2"
POOL_PATH="$BASE_PATH/$POOL_DIR"

echo "Using maps directory: $MAPS_DIR"
echo "Using pool directory: $POOL_PATH"
echo "Using API query: $API_QUERY"

# Create directories if they don't exist
mkdir -p "$MAPS_DIR"
mkdir -p "$POOL_PATH"

# Fetch data from API endpoint
echo "Fetching map data from API..."
response=$(curl -s "$API_QUERY")

# Extract the maps string using jq
if ! command -v jq &> /dev/null; then
    echo "jq not found. Please install jq to parse JSON."
    exit 1
fi

maps_string=$(echo "$response" | jq -r '.rows[0].maps')

if [ -z "$maps_string" ]; then
    echo "Error: Could not extract maps from API response."
    echo "API Response: $response"
    exit 1
fi

echo "Found maps: $maps_string"

# Convert the comma-separated string to an array
IFS=',' read -ra maps <<< "$maps_string"

# Create an array of valid map filenames for later comparison
valid_map_files=()
for map in "${maps[@]}"; do
    valid_map_files+=("${map}.bsp")
done

# Process each map from the API
for map in "${maps[@]}"; do
    map_file="${map}.bsp"
    source_path="$MAPS_DIR/${map_file}"
    target_path="$POOL_PATH/${map_file}"
    download_url="https://fastdl.serveme.tf/maps/${map_file}"
    
    echo "Processing map: $map"
    
    # Remove existing symlink if it exists
    if [ -L "$target_path" ]; then
        rm "$target_path"
    fi
    
    # Check if map file exists
    if [ ! -f "$source_path" ]; then
        echo "Map file $map_file not found. Downloading..."
        curl -s -o "$source_path" "$download_url"
        
        # Verify download was successful
        if [ ! -f "$source_path" ]; then
            echo "Error: Failed to download $map_file"
            continue
        fi
        echo "Download complete: $map_file"
    else
        echo "Map file $map_file already exists."
    fi
    
    # Create symlink using RELATIVE path
    # Navigate to the target directory to create relative symlinks
    (
        cd "$POOL_PATH" || exit 1
        ln -sf "../maps/${map_file}" "${map_file}"
        echo "Created relative symlink for $map_file"
    )
done

# Remove any symlinks in the target directory that aren't in the current map pool
echo "Checking for outdated symlinks..."
for existing_link in "$POOL_PATH"/*.bsp; do
    # Skip if no files match pattern (when directory is empty)
    [ -e "$existing_link" ] || continue
    
    # Get the base filename
    base_filename=$(basename "$existing_link")
    
    # Check if this file is in our valid_map_files array
    if ! printf '%s\n' "${valid_map_files[@]}" | grep -q "^$base_filename$"; then
        echo "Removing outdated symlink: $existing_link"
        rm "$existing_link"
    fi
done

echo "Map pool update completed successfully!"