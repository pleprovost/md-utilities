#/bin/bash

set -e

if [ $# -ne 2 ]; then
    echo $0: usage: gmx_pbc_fix topology.tpr trajectory.xtc 
    exit 1
fi

GMX=gromacs512

# TPR File
TPR=$1
if [ ! -f $TPR ]; then
    echo $2" file not found!"
    exit 1
fi

# XTC File
XTC=$2
if [ ! -f $XTC ]; then
    echo $2" file not found!"
    exit 1
fi

# Arrange the molecules to avoid jump because of the pbc
#$GMX trjconv -f $XTC -s $TPR -o nojump.xtc -pbc nojump <<EOF
#0
#EOF

# Center make whole the thing
$GMX trjconv -f $XTC -s $TPR -o ${XTC%.*}_noPBC.xtc -ur tric -pbc mol <<EOF
0
EOF
#rm nojump.xtc

# Extract first frame
$GMX trjconv -s $TPR -f ${XTC%.*}_noPBC.xtc -o ${XTC%.*}_noPBC.gro -dump 0 <<EOF
0
EOF






