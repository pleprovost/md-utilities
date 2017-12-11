#!/bin/bash -l

set -e

if [ $# -ne 3 ]; then
    echo $0: usage: gmx_do_mdrun_local mdp_file structure_file topology_file
    exit 1
fi

GMX=gromacs512

# Mdp File
MDP_FILE=`readlink -m $1`
if [ ! -f $MDP_FILE ]; then
    echo $1" mdp file not found!"
    exit 1
fi

# Structure file
STRUCTURE_FILE=`readlink -m $2`
if [ ! -f $STRUCTURE_FILE ]; then
    echo $2" structure file not found!"
    exit 1
fi

# Topology file
TOPOLOGY_FILE=`readlink -m $3`
if [ ! -f $TOPOLOGY_FILE ]; then
    echo $3" topology file not found!"
    exit 1
fi

# Input PDB
PDBNAME=${1%.*}

# DEFINE BOX AND SOLVATE

$GMX editconf -f $STRUCTURE_FILE -o struct_newbox.gro -d 1.2 -bt triclinic -quiet -c

$GMX solvate -cp struct_newbox.gro -cs spc216.gro -o struct_solv.gro -p $TOPOLOGY_FILE -quiet

# ADD IONS TO NEUTRALIZE THE SYSTEM
$GMX grompp -f $MDP_FILE -c struct_solv.gro -p $TOPOLOGY_FILE -o ions.tpr

echo SOL | $GMX genion -s ions.tpr -o struct_solv_ions.gro -p $TOPOLOGY_FILE -conc 0.1 -neutral -quiet

