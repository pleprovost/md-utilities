#!/bin/bash -l
#SBATCH -p gpu
#SBATCH -J NAME
#SBATCH -t TIMELIMIT
#SBATCH -o ogmx.%j
#SBATCH -e egmx.%j
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=7
#SBATCH --gres=gpu:p100:4
#SBATCH --mem-per-cpu=128M
#SBATCH --mail-type=ALL
#SBATCH --mail-user=EMAIL

# This script run GROMACS mdrun for any given sytem and simulation inputs.
# The results are placein a directory which name is specified by the user.
# It is meant to be run on CSC Taito cluster using the GPU based nodes.
# By default the scripts uses 2 nodes and the parameters for the memory
# and CPU usage are set in the script (change at your own risk).
# This is scripts i run with sbatch as:
# sbatch -t xx:xx:xx gmx_do_mdrun_gpu dir mdp gro top ndx
# -t set the time allocated to the simulation

set -e

# Load the GROMACS environment (default version in use on Taito)
module load gromacs-env

# this script runs a 24 core (2 full nodes) + 2 GPGPU:s per node gromacs job
# each node will run 2 mpitasks, $tasks in total, each spawning 6 threads
export OMP_NUM_THREADS=7

srun gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -pin on -deffnm NAME -dlb auto -maxh 71.99

# This script will print some usage statistics to the
# end of the standard out file
# Use that to improve your resource request estimate
# on later jobs.
seff $SLURM_JOBID
