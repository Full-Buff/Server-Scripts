#!/bin/bash

# Define the directory and file name
DIRECTORY="/home/container"
FILENAME="test"

touch "$DIRECTORY/$FILENAME"
echo "File '$FILENAME' created in '$DIRECTORY'."

exit 0