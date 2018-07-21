#!/bin/bash -l
#SBATCH --ntasks-per-node=24
#SBATCH -J NAME
#SBATCH -p normal
#SBATCH -N NODE
#SBACTH -t TIMELIMIT
#SBATCH -o ogmx.%j
#SBATCH -e egmx.%j
#SBATCH --mem-per-cpu=150
#SBATCH --mail-type=ALL
#SBATCH --mail-user=EMAIL

set -e
    
module load GROMACS/2016.4

export OMP_NUM_THREADS=1

srun gmx_mpi mdrun -deffnm NAME CPTOPTION -dlb yes -maxh 71.99  

cd ..

