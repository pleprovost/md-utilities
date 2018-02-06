#!/bin/bash

set -e

if [ $# -ne 2 ]; then
    echo $0: usage: gmx_fe_setup mdp_dir number_lambda
    exit 1
fi

# Mdp File
MDP_DIR=`readlink -m $1`
if [ ! -d $MDP_DIR ]; then
    echo $2" mdp file not found!"
    exit 1
fi

# Mdp File
NUMBER_LAMBDA=$2


for i in $(seq 1 $NUMBER_LAMBDA); do
    echo make directory for lambda state $i
    mkdir lambda_$i
    cp -r $MDP_DIR lambda_$i
    for file in lambda_$i/$1*; do
	echo $i $file
	sed -i 's/init_lambda_state.*/init_lambda_state = '"$i"'/g'  $file
    done
done
