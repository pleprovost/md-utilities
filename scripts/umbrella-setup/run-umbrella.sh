#!/bin/bash

# Short equilibration
grompp -f npt_umbrella.mdp -c confXXX.gro -p topol.top -n index.ndx -o nptXXX.tpr
mdrun -deffnm nptXXX

# Umbrella run
grompp -f md_umbrella.mdp -c nptXXX.gro -t nptXXX.cpt -p topol.top -n index.ndx -o umbrellaXXX.tpr
mdrun -deffnm umbrellaXXX -pf pullf-umbrellaXXX.xvg -px pullx-umbrellaXXX.xvg


