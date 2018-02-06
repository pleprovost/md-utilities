#!/bin/bash -l

# This script run GROMACS for extending a simulation for a any given system and
# input time. The results of are stored on the location the command was ran.
# 

set -e

if [ $# -ne 2 ]; then
    echo $0: usage: gmx_extd_local topology.tpr extensiontime
    exit 1
fi

GMX=gromacs512

# Topology file
TOPOLOGY_FILE=$1
if [ ! -f $TOPOLOGY_FILE ]; then
    echo $TOPOLOGY_FILE" file not found!"
    exit 1
fi

# Time to extend in ns
EXTEND=`expr ${2} \* 1000`

# Input : Format md_PDBID_TIME.tpr
OLD=${1%.*}

oIFS="$IFS"
IFS=_ arr=($OLD)
IFS="$oIFS"

NEW=md_${arr[1]}_${2}ns

# PRODUCTION

$GMX  convert-tpr -s $OLD.tpr -until ${EXTEND} -o $NEW.tpr

$GMX mdrun -pin auto -deffnm $NEW -cpi $OLD.cpt -v
 
