#!/bin/bash

# Stop script if error
set -e

MDP=~/Scripts/mdp_remd

TEMP=(280.0 290.0 300.0 310.0)

PDBNAME=TEST

# Peparation of nvt equilibration files
mkdir nvt_$PDBNAME
cd nvt_$PDBNAME

for (( i = 0; i < 4; i++ )); do
    mkdir nvt_$i
    cd nvt_$i
    # Mdp
    cp $MDP/nvt.mdp .
    sed -i -e "s/XXX/${TEMP[$i]}/g" nvt.mdp

    cd ..
done

cd ..

# Peparation of npt equilibration files
mkdir npt_$PDBNAME
cd npt_$PDBNAME

for (( i = 0; i < 4; i++ )); do
    mkdir npt_$i
    cd npt_$i
    # Mdp
    cp $MDP/npt.mdp .
    sed -i -e "s/XXX/${TEMP[$i]}/g" npt.mdp

    cd ..
done

cd ..

# Peparation of md files
mkdir md_$PDBNAME
cd md_$PDBNAME

for (( i = 0; i < 4; i++ )); do
    mkdir md_$i
    cd md_$i
    # Mdp
    cp $MDP/md.mdp .
    sed -i -e "s/XXX/${TEMP[$i]}/g" md.mdp

    cd ..
done

cd ..
