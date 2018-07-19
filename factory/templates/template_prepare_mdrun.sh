#!/bin/bash -l

set -e

LOAD_MODULE

gmx grompp -f MDP -c STRUCT -p TOPOL -o OUPUTNAME CPT_OPTION
