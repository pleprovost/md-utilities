#!/bin/bash

set -e

if [ $# -ge 4 ]; then
    echo $0: usage: gmx_do_mdrun_local  structure_file topology_file
    exit 1
fi

GMX=gromacs512

# Structure file
STRUCTURE_FILE=`readlink -m $1`
if [ ! -f $STRUCTURE_FILE ]; then
    echo $3" structure file not found!"
    exit 1
fi

# Topology file
TOPOLOGY_FILE=`readlink -m $2`
if [ ! -f $TOPOLOGY_FILE ]; then
    
    echo $4" topology file not found!"
    exit 1
fi

# Launch am mdrun for every lambda folder
for LAMBDA in `find . -maxdepth 1 -type d -name 'lambda_*'`
do
    cd $LAMBDA
    
done

