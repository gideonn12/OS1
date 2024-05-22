#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]
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

awk '/\[Event/ {filename = "'$2'/'$1'_" ++counter ".pgn"} {print > filename}' $1