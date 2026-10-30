#!/bin/bash

# Store the current working directory.
current_dir=$(pwd)

# Iterate over all subdirectories in the current directory.
for dir in */; do
    dir=${dir%/}  # Remove the trailing slash.
    echo "Processing directory: $dir"

    # Iterate over replica subdirectories 0, 1, and 2.
    for sub_dir in 0 1 2; do
        full_sub_dir="${dir}/${sub_dir}"
        if [ -d "$full_sub_dir" ]; then
            cd "$full_sub_dir"

            # Run the gmx rmsf command.
#            echo "11" | gmx rmsf -s md.tpr -f "${dir}_${sub_dir}.xtc" -n chain_index.ndx -o "${dir}_${sub_dir}_pep_rmsf.xvg" -res -b 40000 -e 50000

            # Run the gmx sasa command.
            echo "11" | gmx sasa -s md.tpr -f "${dir}_${sub_dir}.xtc" -n chain_index.ndx -o "${dir}_${sub_dir}_pep_sasa.xvg"  -b 40000 -e 50000
            # Return to the original working directory.
            cd "$current_dir"
        fi
    done
done
