#!/bin/bash
#
# this hack replaces the default /wp-includes/theme-compat/comments.php
# with my own edited version (clobbered after every WP update)
#

if [ $# -ne 2 ]; then
    echo "Usage: $0 <source_file> <replacement_file>"
    exit 1
fi

source_file="$1"
replacement_file="$2"

if [ ! -e "$source_file" ]; then
    echo "Source file $source_file does not exist."
    exit 1
fi

if find "$source_file" -mmin -60 | grep -q .; then
    mv "$replacement_file" "$source_file"
fi
