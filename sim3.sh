#!/bin/bash

export LD_LIBRARY_PATH=/afsuser/praveen/silo2/simulation/ImpCRESST/install/lib/:$LD_LIBRARY_PATH

# Simulation settings
energy="1 MeV"                       # Fixed energy
bias_layers=(0 5 10)                   # Bias cases
repetitions=20                       # Number of times to repeat each simulation
macro_file="/afsuser/praveen/silo2/simulation/ImpCRESST/source/ImpCRESST/mac/shieldedCrystal.mac"
#impCRESST_command="/afsuser/praveen/silo2/simulation/ImpCRESST/build/ImpCRESST --macroFile=$macro_file"
simulation_cmd="/afsuser/praveen/silo2/simulation/ImpCRESST/build/ImpCRESST --macroFile=$macro_file"
main_dir=$(pwd)

# Loop over each bias layer
for B in "${bias_layers[@]}"; do
  # Create a directory for this bias layer
  bias_dir="with_bias${B}"
  mkdir -p "$bias_dir"
  cd "$bias_dir"

  # Update bias layers in the macro file
  sed -i "s|^/geometry/numBiasLayers .*|/geometry/numBiasLayers $B|" "$macro_file"

  # Run the simulation multiple times
  for ((i = 1; i <= repetitions; i++)); do
    sed -i "s|/data/setPrefix .*|/data/setPrefix ./${i}_|" "$macro_file"
    echo "Running simulation: Energy=$energy, Bias=$B, Primaries=500, Repetition=$i"
    
    # Run the simulation
    $simulation_cmd

  done

  cd "$main_dir" 

done

echo "All simulations completed."
