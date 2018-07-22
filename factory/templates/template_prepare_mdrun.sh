#!/bin/bash -l

set -e

MODULE

gmx grompp -f MDP -c STRUCT -p TOPOL -o NAME.tpr INDEXOPTION 
