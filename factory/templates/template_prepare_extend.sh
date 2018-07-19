#!/bin/bash -l

set -e

LOAD_MODULE

gmx convert-tpr -s TOPOL -f CPT -until TIMETOEXTEND -o OUTPUT
