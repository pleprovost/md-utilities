#!/bin/bash
#
#SBATCH -J lp_comp
#SBATCH -e run_err%j
#SBATCH -o run_out%j
#SBATCH -N 2
#SBATCH -n 16
#

set -e

module load openmpi-x86_64
module load openmpi-intel

# Local Variable
MPI=/usr/lib64/compat-openmpi/bin
MDRUN=/usr/lib64/openmpi/bin

# Using Custom force field
export GMXLIB=$GMXLIB:~/forcefield/top/

# MDP Location
MDP=~/Scripts/mdp_remd
TEMP=(280.0 290.0 300.0 310.0)
PROD=md_100ps

# Inputs
PDBNAME=${1%.*}

# GENERATE TOPOLOGY
mkdir struct_$PDBNAME
mkdir topol_$PDBNAME
cd struct_$PDBNAME

g_pdb2gmx -f ../$1 -o struct_processed.gro -i ../topol_$PDBNAME/posre.itp -p ../topol_$PDBNAME/topol.top -ff gromos53a6 -water spce -quiet -ignh

# DEFINE BOX AND SOLVATE
g_editconf -f struct_processed.gro -o struct_newbox.gro -d 1.0 -bt dodecahedron -quiet

g_genbox -cp struct_newbox.gro -cs spc216.gro -o struct_solv.gro -p ../topol_$PDBNAME/topol.top -quiet

# ADD IONS TO NEUTRALIZE THE SYSTEM
g_grompp -f $MDP/ions.mdp -c struct_solv.gro -p ../topol_$PDBNAME/topol.top -o ions.tpr

echo SOL | g_genion -s ions.tpr -o struct_solv_ions.gro -p ../topol_$PDBNAME/topol.top -conc 0.15 -neutral

cd ..

# MINIMIZATION
mkdir em_$PDBNAME
cd em_$PDBNAME

g_grompp -f $MDP/em.mdp -c ../struct_$PDBNAME/struct_solv_ions.gro -p ../topol_$PDBNAME/topol.top -o em_$PDBNAME.tpr -quiet

$MPI/mpirun -np 16 $MDRUN/g_mdrun_openmpi -pin auto -deffnm em_$PDBNAME -v

cd ..


# NVT EQUILIBRATION
mkdir nvt_$PDBNAME
cd nvt_$PDBNAME

for (( i = 0; i < 4; i++ )); do
    mkdir nvt_$i
    cd nvt_$i
    # Mdp
    cp $MDP/nvt.mdp .
    sed -i -e "s/XXX/${TEMP[$i]}/g" nvt.mdp
    g_grompp -f nvt.mdp -c ../../em_$PDBNAME/em_$PDBNAME.gro -p ../../topol_$PDBNAME/topol.top -o nvt.tpr

    cd ..
done

$MPI/mpirun -np 16 $MDRUN/g_mdrun_openmpi -pin auto -multidir nvt_0 nvt_1 nvt_2 nvt_3 -deffnm nvt

cd ..

# NPT EQUILIBRATION
mkdir npt_$PDBNAME
cd npt_$PDBNAME

for (( i = 0; i < 4; i++ )); do
    mkdir npt_$i
    cd npt_$i
    # Mdp
    cp $MDP/npt.mdp .
    sed -i -e "s/XXX/${TEMP[$i]}/g" npt.mdp
    g_grompp -f npt.mdp -c ../../nvt_$PDBNAME/nvt_$i/nvt.gro -p ../../topol_$PDBNAME/topol.top -o npt.tpr

    cd ..
done

$MPI/mpirun -np 16 $MDRUN/g_mdrun_openmpi -pin auto -multidir npt_0 npt_1 npt_2 npt_3 -deffnm npt

cd ..

# PRODUCTION
mkdir md_$PDBNAME
cd md_$PDBNAME

for (( i = 0; i < 4; i++ )); do
    mkdir md_$i
    cd md_$i
    # Mdp
    cp $MDP/md.mdp .
    sed -i -e "s/XXX/${TEMP[$i]}/g" md.mdp
    g_grompp -f md.mdp -c ../../npt_$PDBNAME/npt_$i/npt.gro -p ../../topol_$PDBNAME/topol.top -o md.tpr

    cd ..
done

$MPI/mpirun -np 16 $MDRUN/g_mdrun_openmpi -pin auto -multidir md_0 md_1 md_2 md_3 -deffnm md -replex 50

cd ..


