#!/bin/bash

# This script run GROMACS mdrun for any given sytem and simulation inputs.
# The results are placein a directory which name is specified by the user.

set -e

if [ $# -gt 5 ]; then
    echo "Too many arguments!"
    echo $0: usage: gmx_do_mdrun_local dir_name mdp_file structure_file\
	 topology_file index_file_optional
    exit 1
elif [ $# -lt 4 ]; then
    echo "Not enough arguments!"
    echo $0: usage: gmx_do_mdrun_local dir_name mdp_file structure_file\
	 topology_file index_file_optional
fi

# Set GROMACS prefix variable, you must change this to your prefix in use 
GMX=gromacs512

# Set the name of the directory for the simulation
MDRUN_NAME=$1

# Check the presence of the MDP file
MDP_FILE=`readlink -m $2`
if [ ! -f $MDP_FILE ]; then
    echo $2" mdp file not found!"
    exit 1
fi

# Check the presence of the structure (PDB or GRO) file 
STRUCTURE_FILE=`readlink -m $3`
if [ ! -f $STRUCTURE_FILE ]; then
    echo $3" structure file not found!"
    exit 1
fi

# Check the presence of the topology (TOP) file 
TOPOLOGY_FILE=`readlink -m $4`
if [ ! -f $TOPOLOGY_FILE ]; then
    echo $4" topology file not found!"
    exit 1
fi

# If additionnal input check the presence of index (NDX) file, else send an empty string
if [ ! -z $5 ]; then 
    INDEX_FILE=`readlink -m $5`
    if [ ! -f $INDEX_FILE ]; then
	echo $5" index file not found!"
	exit 1
    fi
    INDEX_FLAG="-n "$INDEX_FILE
else
    INDEX_FLAG=""
fi

# Make a new directory, and run grompp and mdrun 
mkdir $MDRUN_NAME
cd $MDRUN_NAME

$GMX grompp -f $MDP_FILE -c $STRUCTURE_FILE -p $TOPOLOGY_FILE $INDEX_FLAG -o $MDRUN_NAME.tpr -maxwarn 2

$GMX mdrun -pin auto -deffnm $MDRUN_NAME -dlb yes -v 

cd ..
