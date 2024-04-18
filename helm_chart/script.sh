#!/bin/bash

for dir in */; do
    dir=${dir%*/} # Remove trailing slash
    echo "Processing directory: $dir"

    if [ -f "$dir/values.yaml" ]; then
        echo "values.yaml found in $dir. Renaming to values-dev.yaml"
        mv "$dir/values.yaml" "$dir/values.dev.east1.yaml"
    else
        echo "values.yaml not found in $dir"
    fi
done