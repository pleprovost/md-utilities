#!/bin/bash -l

set -e

MODULE

gmx convert-tpr -s TOPOL -f CPTFILE -until TIMETOEXTEND -o NAME 
