import parmed as pmd 
import argparse

"""
Python scripts using Parmed to convert Amber coordinates
and topology files to GROMACS coordinates and topology.

Usage:

python parmed_convert.py amber.prmtop amber.prmcrd outputname

will return two files outputname.gro and outputname.top 

"""


parser = argparse.ArgumentParser(description='Convert AMBER topology to GROMACS topology')
parser.add_argument('amber_top', help='Input AMBER topology')
parser.add_argument('amber_crd', help='Input AMBER coordinates')
parser.add_argument('output_name', help='Ouput file name for .top and .gro')
args = parser.parse_args()

amb_top = pmd.load_file(args.amber_top, xyz=args.amber_crd)
amb_top.save(args.output_name+'.top', format='gromacs')
amb_top.save(args.output_name+'.gro', format='gro')

