#!/bin/bash -l
#SBATCH --constraint=snb
#SBATCH --ntasks-per-node=16
#SBATCH -J GMX_EXTD
#SBATCH -o ogmx.%j
#SBATCH -e egmx.%j
#SBATCH --mem-per-cpu=150
#SBATCH --mail-type=ALL
#SBATCH --mail-user=pierre.leprovost@oulu.fi

set -e

if [ $# -ne 2 ]; then
    echo $0: usage: gmx_extd_taito topology.tpr extensiontime
    exit 1
fi

module load gromacs-env

export OMP_NUM_THREADS=1
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

srun gmx_mpi mdrun -deffnm $NEW -cpi $OLD.cpt -dlb yes -maxh 71.99

# This script will print some usage statistics to the
# end of the standard out file
# Use that to improve your resource request estimate
# on later jobs.
used_slurm_resources.bash
