#!/bin/bash

set -e

GMX=gromacs512

# Create index file for buried water analysis

if [ $# -ne 2 ]; then
    echo $0: usage: gmx_setup_ndx topology.tpr input.txt
    exit 1
fi

# Topology file
if [ ! -f $1 ]; then
    echo $1" file not found!"
    exit 1
fi

# Input prompt File
if [ ! -f $2 ]; then
    echo $2" file not found!"
    exit 1
fi

$GMX make_ndx -f $1 -o analysis.ndx < $2

# Change & to and and remove - in C-alpha for later auto prompting
sed -i 's/&/and/g' analysis.ndx
sed -i 's/_C-alpha/_CAlpha/g' analysis.ndx
