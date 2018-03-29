#!/bin/bash -l
#SBATCH --constraint=snb
#SBATCH --ntasks-per-node=16
#SBATCH -J gmx_md
#SBATCH -o ogmx.%j
#SBATCH -e egmx.%j
#SBATCH --mem-per-cpu=128
#SBATCH --mail-type=ALL
#SBATCH --mail-user=pierre.leprovost@oulu.fi

set -e

if [ $# -gt 5]; then
    echo "Too many arguments !"
    echo $0: usage: gmx_do_mdrun_taito mdrun_name mdp_file structure_file topology_file index_file_optional
    exit 1
elif [ $# -lt 4]; then
    echo "Not enough arguments !"
    echo $0: usage: gmx_do_mdrun_taito mdrun_name mdp_file structure_file topology_file index_file_optional
fi
    
module load gromacs-env

export OMP_NUM_THREADS=1
export GMXLIB=forcefield_link

# Input PDB
MDRUN_NAME=$1

# Mdp File
MDP_FILE=`readlink -m $2`
if [ ! -f $MDP_FILE ]; then
    echo $2" mdp file not found!"
    exit 1
fi

# Structure file
STRUCTURE_FILE=`readlink -m $3`
if [ ! -f $STRUCTURE_FILE ]; then
    echo $3" structure file not found!"
    exit 1
fi

# Topology file
TOPOLOGY_FILE=`readlink -m $4`
if [ ! -f $TOPOLOGY_FILE ]; then
    echo $4" topology file not found!"
    exit 1
fi

# Index file
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


# Process
mkdir $MDRUN_NAME
cd $MDRUN_NAME

gmx grompp -f $MDP_FILE -c $STRUCTURE_FILE -p $TOPOLOGY_FILE $INDEX_FLAG -o $MDRUN_NAME.tpr

srun gmx_mpi mdrun -deffnm $MDRUN_NAME -dlb yes

cd ..


# This script will print some usage statistics to the
# end of the standard out file
# Use that to improve your resource request estimate
# on later jobs.
seff $SLURM_JOBID
