#!/bin/bash

export LD_LIBRARY_PATH=/afsuser/praveen/silo2/simulation/ImpCRESST/install/lib/:$LD_LIBRARY_PATH

# Define the values for each parameter
primaries=(10 20 30 40 50 60 70 80 90 100)

# Define the path to the macro file, ImpCRESST command, and main directory for macro.C
macro_file="/afsuser/praveen/silo2/simulation/ImpCRESST/source/ImpCRESST/mac/shieldedCrystal.mac"
impCRESST_command="/afsuser/praveen/silo2/simulation/ImpCRESST/build/ImpCRESST --macroFile=$macro_file"
main_dir=$(pwd)
repetitions=100 

for B in "${primaries[@]}"; do
    sed -i "s|/run/beamOn [0-9]*|/run/beamOn $B|" "$macro_file"
    for ((i = 1; i <= repetitions; i++)); do
        sed -i "s|/data/setPrefix .*|/data/setPrefix ./${B}_${i}_|" "$macro_file"
        echo "Running simulation: Energy=1 MeV, Primaries=$B, Repetition=$i"
        
        # Run the simulation
        $impCRESST_command

        mv "log" "log_${B}_${i}"

    done
        
done

echo "All simulations completed!"
