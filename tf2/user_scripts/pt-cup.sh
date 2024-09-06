#!/bin/bash

# Define the source and destination directories
PLUGIN_DIR="/home/container/tf/addons/sourcemod/plugins"
DISABLED_DIR="/home/container/tf/addons/sourcemod/plugins/disabled"

# Move the files back to the plugins directory
mv "$DISABLED_DIR/rglupdater.smx" "$PLUGIN_DIR/"
mv "$DISABLED_DIR/rglqol.smx" "$PLUGIN_DIR/"

# Check if the move was successful
if [[ $? -eq 0 ]]; then
    echo "Files moved back to the plugins directory."
else
    echo "An error occurred while moving the files."
fi
