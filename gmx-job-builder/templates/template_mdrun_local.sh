#!/bin/bash -l

# This script run GROMACS mdrun for any given sytem and simulation inputs.
# The results are placein a directory which name is specified by the user.

set -e

gromacs512 mdrun -pin auto -deffnm NAME -dlb yes -v

