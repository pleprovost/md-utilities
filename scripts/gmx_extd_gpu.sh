#!/bin/bash -l
#SBATCH -p gpu
#SBATCH -J GMX
#SBATCH -o ogmx.%j
#SBATCH -e egmx.%j
#SBATCH -N 2
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=6
#SBATCH --gres=gpu:k80:4
#SBATCH --mem-per-cpu=128
#SBATCH --mail-type=ALL
#SBATCH --mail-user=pierre.leprovost@oulu.fi
 
set -e

if [ $# -gt 2]; then
    echo "Too many arguments !"
    echo $0: usage: gmx_extd_taito topology.tpr extensiontime
    exit 1
elif [ $# -lt 4]; then
    echo "Not enough arguments !"
    echo $0: usage: gmx_extd_taito topology.tpr extensiontime
    exit 1
fi

module load gromacs-env

export OMP_NUM_THREADS=6
((tasks=2*SLURM_NNODES))
# this script runs a 24 core (2 full nodes) + 2 GPGPU:s per node gromacs job
# each node will run 2 mpitasks, $tasks in total, each spawning 6 threads
export GMXLIB=forcefield_link

# Topology file
if [ ! -f $1 ]; then
    echo $1" file not found!"
    exit 1
fi

# Time to extend in ns
EXTEND=$(expr ${2} \* 1000)

# Input : Format md_PDBID_TIME.tpr
OLD=${1%.*}

oIFS="$IFS"
IFS=_ arr=( $OLD )
IFS="$oIFS"

NEW=md_${arr[1]}_${2}ns

# PRODUCTION

gmx convert-tpr -s $OLD.tpr -until ${EXTEND} -o $NEW.tpr

srun gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -pin on -deffnm $NEW -cpi $OLD.cpt -dlb auto -maxh 71.99

# This script will print some usage statistics to the
# end of the standard out file
# Use that to improve your resource request estimate
# on later jobs.
used_slurm_resources.bash
