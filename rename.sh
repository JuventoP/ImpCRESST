#!/bin/bash

# Loop over P values (10, 20, ..., 100)
for P in {10..100..10}; do
    # Loop over i values (1 to 20)
    for i in {1..20}; do
        # Find files matching P_i_x.root pattern
        for file in "$P"_"$i"_*.root; do
            # Check if file exists to avoid errors
            if [[ -e "$file" ]]; then
                # Define the new name
                new_name="${P}_${i}.root"

                # Rename the file
                mv "$file" "$new_name"
                echo "Renamed: $file -> $new_name"
            fi
        done
    done
done
