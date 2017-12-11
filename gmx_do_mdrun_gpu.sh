#!/bin/bash -l
#SBATCH -p gpu
#SBATCH -J GMX
#SBATCH -o ogmx.%j
#SBATCH -e egmx.%j
#SBATCH --constraint=[k40|k80]
#SBATCH -N 2
#SBATCH --ntasks-per-node=2
#SBATCH --exclusive
#SBATCH --gres=gpu:2
#SBATCH --mem-per-cpu=128
#SBATCH --mail-type=ALL
#SBATCH --mail-user=pierre.leprovost@oulu.fi

# This script run GROMACS mdrun for any given sytem and simulation inputs.
# The results are placein a directory which name is specified by the user.
# It is meant to be run on CSC Taito cluster using the GPU based nodes.
# By default the scripts uses 2 nodes and the parameters for the memory
# and CPU usage are set in the script (change at your own risk).
# This is scripts i run with sbatch as:
# sbatch -t xx:xx:xx gmx_do_mdrun_gpu dir mdp gro top ndx
# -t set the time allocated to the simulation

set -e

# Throw help if incorrect number of arguments
if [ $# -gt 5]; then
    echo "Too many arguments !"
    echo $0: usage: gmx_do_mdrun_gpu dir_name mdp_file structure_file\
	 topology_file index_file[optional]
    exit 1
elif [ $# -lt 4]; then
    echo "Not enough arguments !"
    echo $0: usage: gmx_do_mdrun_gpu dir_name mdp_file structure_file\
	 topology_file index_file[optional]
    exit 1
fi

# Load the GROMACS environment (default version in use on Taito)
module load gromacs-env

# this script runs a 24 core (2 full nodes) + 2 GPGPU:s per node gromacs job
# each node will run 2 mpitasks, $tasks in total, each spawning 6 threads
export OMP_NUM_THREADS=6
((tasks=2*SLURM_NNODES))

# Export specific force field location (Modify of you use a different location)
export GMXLIB=~/gmx_files/forcefield/top

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

gmx grompp -f $MDP_FILE -c $STRUCTURE_FILE -p $TOPOLOGY_FILE $INDEX_FLAG -o $MDRUN_NAME.tpr

srun --gres=gpu:2 -n $tasks gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -pin on -deffnm $MDRUN_NAME -dlb auto

cd ..


# This script will print some usage statistics to the
# end of the standard out file
# Use that to improve your resource request estimate
# on later jobs.
used_slurm_resources.bash
