
import re
import os
import sys
import argparse
import subprocess

# Description
description = """ """

# Config parameters
email = 'pierre.leprovost@oulu.fi'

template_path= '{0}/templates'.format(os.path.dirname(os.path.realpath(__file__)))

machines = ('taito', 'gpu', 'carpo', 'sisu', 'local')
modules = {'taito': 'module load gromacs-env',
           'gpu' : 'module load gromacs-env',
           'sisu' : 'module load gromacs-env',
           'carpo' : 'module load GROMACS/2016.4',
           'local' : ''}

def NewParser():
    parser = argparse.ArgumentParser(description='Gromacs MD Job Factory',
                                     usage='''gmx_job_factory <job> <machine> [<args>]
                                     
                                         The job offered:
                                     mdrun     Create a new MD job 
                                     extend    Extend an existing MD job
                                     
                                         The machine offered:
                                     taito     CSC
                                     sisu      CSC
                                     carpo     University of Oulu
                                     local
                                     ''')
    
    subparsers = parser.add_subparsers(dest='job')
    mdrun_parser = subparsers.add_parser('mdrun', description='Plop1')
    mdrun_parser.add_argument('-n', '--name', dest='name', type=str,
                              help='store the name of the name of the job required '\
                              '(if not the name is set to the job type)',
                              default='md')
    mdrun_parser.add_argument('-s', '--struct', dest='struct', type=str,
                                  help='store the structure file of the system, '\
                              'the file must be of type .GRO of .PDB',
                              required=True)
    mdrun_parser.add_argument('-f', '--mpd', dest='mdp', type=str,
                              help='store the mdp file for the job, the file must be of type .MDP',
                              required=True)
    mdrun_parser.add_argument('-t', '--topol', type=str, help='store the topology file',
                              required=True)
    mdrun_parser.add_argument('-c', '--cpt', dest='cpt', type=str,
                              help='store the time to extend the simulation for extend jobs')
    mdrun_parser.add_argument('-i', '--index', dest='index', type=str,
                              help='store the index file')
    mdrun_parser.add_argument('-m', '--machine', type=str, help='machine selection', default='local')
    mdrun_parser.add_argument('-N', '--nodes', type=str, help='nodes selection')
    mdrun_parser.add_argument('-l', '--limit', type=str, help='time limit selection')
    
    
    extend_parser = subparsers.add_parser('extend', description='Plop2')
    extend_parser.add_argument('-c', '--cpt', dest='cpt', type=str,
                               help='store the time to extend the simulation for extend '\
                               'jobs',
                               required=True)
    extend_parser.add_argument('-e', '--extend', dest='extend', type=str,
                               help='store the time to extend the simulation for extend '\
                               'jobs',
                               required=True)
    extend_parser.add_argument('-m', '--machine', type=str, help='machine selection', default='local')
    extend_parser.add_argument('-N', '--nodes', type=str, help='nodes selection')
    extend_parser.add_argument('-l', '--limit', type=str, help='time limit selection')
    
    args, job_type = parser.parse_known_args(sys.argv[1:])
    
    if args.machine != 'local' and (args.nodes == None or args.limit == None):
        parser.error("{0} machine require to provide --nodes and --limit".format(args.machine))
        
    return args, job_type


class GmxJobFactory:
    def __init__(self, args):
        self.args = args           
        self.replacement = {'NAME': '',
                            'EMAIL': email,
                            'TIMELIMIT': '',
                            'NODE': '',
                            'CPTOPTION': '',
                            'CPTFILE': '',
                            'STRUCT': '',
                            'TOPOL': '',
                            'MDP': '',
                            'MODULE': modules[self.args.machine],
                            'TIMETOEXTEND': '',
                            'INDEXOPTION': ''}
        if (self.args.machine == None):
            self.args.machine = 'local'
        getattr(self, self.args.job)()
        
    def write_template(self, filename, outname):
        print 'writing {0}'.format(outname)
        with open(filename, 'r') as template_file:
            template_text = template_file.read()
            for key, value in self.replacement.iteritems():
                template_text = template_text.replace(key, value)
        with open(outname, 'w') as outfile:
             outfile.write(template_text)
            
    def mdrun(self):
        print 'Setting mdrun script'
        if self.args.name:
            self.replacement['NAME'] = self.args.name
        if self.args.struct:
            self.replacement['STRUCT'] = self.args.struct
        if self.args.topol:
            self.replacement['TOPOL'] = self.args.topol
        if self.args.mdp:
            self.replacement['MDP'] = self.args.mdp
        if self.args.cpt:
            self.replacement['CPTOPTION'] = '-cpi {0} '.format(self.args.cpt)
        if self.args.index:
            self.replacement['INDEXOPTION'] = '-n {0} '.format(self.args.index)
            
        self.write_template('{0}/template_prepare_mdrun.sh'.format(template_path),
                            'prepare_{0}.sh'.format(self.args.name))
        self.write_template('{0}/template_mdrun_{1}.sh'.format(template_path,
                                                               self.args.machine),
                            'job_{0}.sh'.format(self.args.name))
        
    def extend(self):
        print 'Setting extend script'
        self.replacement['NAME'] = 'extd-{0}ns'.format(int(float(self.args.extend)/1000))
        self.replacement['CPTOPTION'] = '-cpi {0} -noappend'.format(self.args.cpt)
        self.write_template('{0}/template_prepare_extend.sh'.format(template_path),
                            'prepare_{0}.sh'.format(self.replacement['NAME']))
        self.write_template('{0}/template_mdrun_{1}.sh'.format(template_path,
                                                               self.args.machine),
                            'job_{0}.sh'.format(self.replacement['NAME']))
            
if __name__ == "__main__":
    # # Input parameters handling
    #job_args = JobParser()   
    #print job_args
    job, job_type = NewParser()
    GmxJobFactory(job)

    

    
    
    
    
