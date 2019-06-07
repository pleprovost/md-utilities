#!/bin/bash -l

# This script can be submitted on carpo using :
# $ sbatch job.sh
# You can follow you jobs using :
# $ squeue -u username

# WARNING : the files necessary must be present (or with relative/absolute path) where the
# scripts was submitted

# NOTE : The name of the job can be replace by changing the -J option

#SBATCH -p normal
#SBATCH -J xxx
#SBATCH -o ogmx.%j
#SBATCH -e egmx.%j
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=24
#SBATCH --mem-per-cpu=256
#SBATCH --mail-type=ALL
#SBATCH --mail-user=your@addressemail.fr

set -e

#Load gromacs and all the dependencies
module load GROMACS/2016.4

# Run gmx grompp to produce the .TPR file. This line can be run outside the script and
# then commented to prevent any error at this stage to occur after the job submission.
# The name and the path of the files are important here is just a proposed example.
gmx grompp -f mdp.mdp -c struct.gro -p topol.top -n index.ndx -o prod.tpr 

# Run the mdrun job. srun and gmx_mpi are called to take advantage of the parallelisation.
# Options -dlb an -pin are accessory since GROMACS can decide it self to activate or desactivate
# them. But I leave them here just in case. They may improve the performance. 
srun gmx_mpi mdrun -deffnm prod -dlb auto -pin on -v 

seff $SLURM_JOBID
