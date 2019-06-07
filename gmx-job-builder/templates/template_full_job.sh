#!/bin/bash -l
#SBATCH -p gpu
#SBATCH -J full-job
#SBATCH -t 48:00:00
#SBATCH -o ogmx.%j
#SBATCH -e egmx.%j
#SBATCH -N 1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=7
#SBATCH --gres=gpu:p100:4
#SBATCH --mem-per-cpu=128M
#SBATCH --mail-type=ALL
#SBATCH --mail-user=pierre.leprovost@oulu.fi

set -e
    
module load gromacs-env

export OMP_NUM_THREADS=7

mkdir nvt_full npt_full npt_full_backbone prod_full

# Fully restrained NVT
cd nvt 

gmx grompp -f ../simple/nvt_full.mdp -c ../em/em.gro -p ../preparation/*.top -o nvt_full.tpr ../preparation/index.ndx

srun gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -pin on -deffnm nvt_full -dlb auto

cd ..

# Fully restrained NPT
cd npt_full

gmx grompp -f ../simple/npt_full.mdp -c ../nvt_full/nvt_full.gro -p ../preparation/*.top -o npt_full.tpr ../preparation/index.ndx -t ../nvt_full/*.cpt

srun gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -pin on -deffnm npt_full -dlb auto

cd ..

# Backbone and Ligand restrained NPT
cd npt_full_backbone

gmx grompp -f ../simple/npt_full.mdp -c ../nvt_full/nvt_full.gro -p ../preparation/*.top -o npt_full_backbone.tpr ../preparation/index.ndx -t ../npt_full/*.cpt

srun gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -pin on -deffnm npt_full_backbone -dlb auto

cd ..

# Unrestrained NPT
cd prod_full

gmx grompp -f ../simple/prod_full.mdp -c ../npt_full/npt_full.gro -p ../preparation/*.top -o prod_full.tpr ../preparation/index.ndx -t ../npt_full_backbone/*.cpt
t
srun gmx_mpi mdrun -ntomp $OMP_NUM_THREADS -pin on -deffnm prod_full -dlb auto



# This script will print some usage statistics to the
# end of the standard out file
# Use that to improve your resource request estimate
# on later jobs.
seff $SLURM_JOBID
