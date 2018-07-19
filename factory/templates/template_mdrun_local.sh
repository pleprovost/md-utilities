#!/bin/bash -l

# This script run GROMACS mdrun for any given sytem and simulation inputs.
# The results are placein a directory which name is specified by the user.

set -e

gmx mdrun -pin auto -deffnm MDRUN_NAME CPT_OPTION -dlb yes -v

