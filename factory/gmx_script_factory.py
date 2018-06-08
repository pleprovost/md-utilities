
import re
import os
import sys
import argparse
import subprocess

# Description
description = """ """

# Config parameters
email = 'EMAIL'
template_path= '/koti/pleprovo/gmx-utilities/scripts/factory/templates/'    
    
class GmxWrapper:
    def __init__(self, args):
        self.args = args
        self.replacement = {'MDRUN_NAME': str(self.args.name),
                            '$email': str(email),
                            'TIME': str(self.args.timelimit)}
    def mdrun(self):
        cpt_option = ''
        if self.args.cpt:
            cpt_option = '-t {0}'.format(os.path.abspath(self.args.cpt))

        commands = 'set -e; '
        if self.args.machine in ['taito', 'gpu']:
            commands += 'module load gromacs-env; '
        commands += 'mkdir {0}; '.format(self.args.name)
        commands += 'gmx grompp -f {0} -c {1} -p {2} -o {3} {4}'.format(
            os.path.abspath(self.args.mdp),
            os.path.abspath(self.args.struct),
            os.path.abspath(self.args.topol),
            self.args.name+'/'+self.args.name+'.tpr',
            cpt_option)
        subprocess.check_output(commands, shell=True)
        
    def extend(self):
        commands = 'set -e; '
        if self.args.machine in ['taito', 'gpu']:
            commands += 'module load gromacs-env; '
        commands += 'gmx convert-tpr -s {0} -f {1} -until {2} -o {3}'.format(
            os.path.abspath(self.args.topol),
            os.path.abspath(self.args.cpt),
            str(int(self.args.extend*1000)),
            self.args.name+'.tpr')
        subprocess.check_output(commands, shell=True)
        
    def write_script(self, filename, filepath='.'):
        template = ''        
        with open(template_path+'template_mdrun_'+self.args.machine+'.sh', 'r') as infile:
            template = infile.read()
            for key, value in self.replacement.iteritems():
                template = template.replace(key, value)
 
        with open('{0}/{1}.sh'.format(filepath, filename), 'w') as outfile:
            outfile.write(template)
        
    def run(self):
        if self.args.job == 'mdrun':
            self.mdrun()
            self.write_script(self.args.name, self.args.name)
            
        if self.args.job == 'extend':
            self.extend()
            self.write_script(self.args.name)
    
if __name__ == "__main__":
    # Input parameters handling
    # Job type: mdrun, extend
    parser = argparse.ArgumentParser(prog='gmx_script_factory', description=description)
    
    parser.add_argument('-j', '--job', dest='job', type=str, 
                        help='select the type of job required (REQUIRED)',
                        required=True)
    parser.add_argument('-t', '--topol', dest='topol', type=str,
                        help='store the topology of the system,'\
                        ' the file must be of type .TOP, .TPR or .CPT for continuation job',
                        required=True)
    
    # Job specific arguments
    # mdrun
    parser.add_argument('-n', '--name', dest='name', type=str,
                        help='store the name of the name of the job required '\
                        '(if not the name is set to the job type)',
                        required='mdrun' in sys.argv)
    parser.add_argument('-s', '--struct', dest='struct', type=str,
                        help='store the structure file of the system, '\
                        'the file must be of type .GRO of .PDB',
                        required='mdrun' in sys.argv)
    parser.add_argument('-m', '--mpd', dest='mdp', type=str,
                        help='store the mdp file for the job, the file must be of type .MDP',
                        required='mdrun' in sys.argv)
    
    # extend
    parser.add_argument('-c', '--cpt', dest='cpt', type=str,
                        help='store the time to extend the simulation for extend jobs',
                        required='extend' in sys.argv)
    parser.add_argument('-e', '--extend', dest='extend', type=float,
                        help='store the time to extend the simulation for extend jobs',
                        required='extend' in sys.argv)
    
    
    # Machine related arguments
    parser.add_argument('-ma', '--machine', dest='machine', type=str,
                        help='select the machine on which we run the job', default='local')
    parser.add_argument('-N', '--nodes', dest='nodes', type=int,
                        help='store the number of nodes allocated for this job',
                        required='--machine' in sys.argv)
    parser.add_argument('-tl', '--timelimit', dest='timelimit', type=str,
                        help='store the time limit allocated to this job',
                        required='--machine' in sys.argv)

    args = parser.parse_args()    
    
    wrapper = GmxWrapper(args)
    wrapper.run()
    

    

    
    
    
    
