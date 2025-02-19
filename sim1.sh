#!/bin/bash

export LD_LIBRARY_PATH=/afsuser/praveen/silo2/simulation/ImpCRESST/install/lib/:$LD_LIBRARY_PATH

# Define the values for each parameter
energies=("1 MeV")
bias_layers=(0 5)
primaries=(1 10 100 1000)

# Define the path to the macro file, ImpCRESST command, and main directory for macro.C
macro_file="/afsuser/praveen/silo2/simulation/ImpCRESST/source/ImpCRESST/mac/shieldedCrystal.mac"
impCRESST_command="/afsuser/praveen/silo2/simulation/ImpCRESST/build/ImpCRESST --macroFile=$macro_file"
main_dir=$(pwd)

# Loop over each energy value
for E in "${energies[@]}"; do
  # Create a directory for the current energy
  mkdir -p "$E"
  
  # Modify the energy in the macro file
  sed -i "s|/gps/energy .*|/gps/energy $E|" "$macro_file"

  # Loop over each bias layer value
  for B in "${bias_layers[@]}"; do
    # Create a subdirectory for the current bias layer
    mkdir -p "$E/with_bias${B}"
    cd "$E/with_bias${B}"
    
    # Modify the bias layers in the macro file
    sed -i "s|/geometry/numBiasLayers [0-9]*|/geometry/numBiasLayers $B|" "$macro_file"

    # Loop over each primary value
    for P in "${primaries[@]}"; do
      # Modify the primaries in the macro file
      sed -i "s|/run/beamOn [0-9]*|/run/beamOn $P|" "$macro_file"

      sed -i "s|/data/setPrefix .*|/data/setPrefix ./${P}_|" "$macro_file"
      
      # Run the simulation and capture timing data
      $impCRESST_command

      mv "log" "log_${P}"

    done

    cd "$main_dir"

  done
done

echo "All simulations completed!"
