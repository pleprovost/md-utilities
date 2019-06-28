# md-utilities

Utilities for setting up Molecular Dynamics Simulations with GROMACS

## gmx-job-builder

Gmx Job builder exist to make to automate the process of building scripts to be subbmitted on [CSC](https://csc.fi) super cluster taito or on University of Oulu cluster [Carpo](https://wiki.oulu.fi/display/fgci/Carpo). Gmx Job builder is written in python (2x).

## scripts
A collection of - *more or less* - usefull scripts

## mdps
A collection of .mdp input files for Molecular Dynamics simulation with GROMACS adapted for different force fields:
  * GROMOS 
  * AMBER
  * CHARMM

Cutoffs and constraints were found from original publications of the force fields. Dispersion correction were disabled for CHARMM force field.

## tleap
Contains a python script for converting AMBER file to GROMACS, a template input for tleap and workflow example for preparing MD files with AMBER force field 
