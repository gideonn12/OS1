#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ $# -ne 2 ]
then
    echo "Usage: $0 <source_pgn_file> <destination_directory>"
    exit 1
fi

if [ ! -f "$1" ]
then
    echo "Error: File '$1' does not exist."
    exit 1
fi

if [ ! -d "$2" ]
then
    mkdir "$2"
    echo "Created directory '$2'."
fi


filename_prefix=$(basename "$1" .pgn)
awk '/^\[Event / {filename = "'"$2"'/'"$filename_prefix"'_" ++counter ".pgn"; printf("Saved to %s/%s_%d.pgn\n", "'"$2"'", "'"$filename_prefix"'", counter); print > filename}' "$1"

echo "All games have been split and saved to '$2'."