#!/bin/bash

# Define the source and destination directories
PLUGIN_DIR="/home/container/tf/addons/sourcemod/plugins"
DISABLED_DIR="/home/container/tf/addons/sourcemod/plugins/disabled"

# Move the files to the disabled directory
mv "$PLUGIN_DIR/rglupdater.smx" "$DISABLED_DIR/"
mv "$PLUGIN_DIR/rglqol.smx" "$DISABLED_DIR/"

# Check if the move was successful
if [[ $? -eq 0 ]]; then
    echo "Files moved to the disabled directory."
else
    echo "An error occurred while moving the files."
fi
