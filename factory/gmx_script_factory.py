
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

class JobParser:
    job = ''
    machine = ''
    topol = ''
    name = ''
    struct = ''
    mdp = ''
    timetoextend = ''
    cpt = ''
    nodes = ''
    timelimit = ''
    
    def __init__(self):
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

        parser.add_argument('job', help='Select a job')
        parser.add_argument('machine', help='Select a machine')
        parser.add_argument('-t', '--topol', dest='topol', type=str,
                            help='store the topology of the system, the file must be of type .TOP, .TPR or .CPT for continuation job', required=True)
        
        args, unknown = parser.parse_known_args(sys.argv[1:])
        
        if not hasattr(self, args.job):
            print 'Unrecognized job'
            parser.print_help()
            exit(1)
            
        getattr(self, args.job)()

        if args.machine not in machines:
            print 'Unrecognized machine'
            parser.print_help()
            exit(1)

        if args.machine != 'local':
            self.machine_parser()
            
        self.job = args.job
        self.machine = args.machine
        self.topol = os.path.abspath(args.topol)        
    
    def __str__(self):
        output = '>>>>>>>>>>>>>>>\n'
        output += 'Job type : {0}\n'.format(self.job)
        if self.job == 'mdrun':
            output += 'Job name : {0}\nStructure : {1}\nTopology : {2}\nmdp file : {3}\n'.format(
                self.name,
                self.struct,
                self.topol,
                self.mdp)
        if self.job == 'extend':
            output += 'Topology : {0}\ncpt file : {1}\ntime to extend : {2}\n'.format(
                self.topol,
                self.cpt,
                int(float(self.timetoextend)/1000))

        if self.machine != 'local':
            output += 'Running on {0} with {1} nodes for {2} hours\n'.format(self.machine,
                                                                             self.nodes,
                                                                             self.timelimit)
        else:
            output += 'Running locally\n'
        output += '<<<<<<<<<<<<<<<\n'  
            
        return output
    
    def mdrun(self):
        parser = argparse.ArgumentParser(
            description='MD job arguments')
        # prefixing the argument with -- means it's optional

        parser.add_argument('-n', '--name', dest='name', type=str,
                            help='store the name of the name of the job required '\
                            '(if not the name is set to the job type)',
                            required=True)
        parser.add_argument('-s', '--struct', dest='struct', type=str,
                            help='store the structure file of the system, '\
                            'the file must be of type .GRO of .PDB',
                            required=True)
        parser.add_argument('-m', '--mpd', dest='mdp', type=str,
                            help='store the mdp file for the job, the file must be of type .MDP',
                            required=True)
        parser.add_argument('-c', '--cpt', dest='cpt', type=str,
                            help='store the time to extend the simulation for extend jobs')
        
        args, unknown = parser.parse_known_args(sys.argv[3:])

        self.name = args.name
        self.struct = os.path.abspath(args.struct)
        self.mdp = os.path.abspath(args.mdp)
        if args.cpt:
            self.cpt = os.path.abspath(args.cpt)
        
    def extend(self):
        parser = argparse.ArgumentParser(
            description='Extend job arguments')
        # NOT prefixing the argument with -- means it's not optional
        # extend
        parser.add_argument('-c', '--cpt', dest='cpt', type=str,
                            help='store the time to extend the simulation for extend jobs', required=True)
        parser.add_argument('-e', '--extend', dest='extend', type=str,
                            help='store the time to extend the simulation for extend jobs', required=True)
        
        args, unknown = parser.parse_known_args(sys.argv[3:])

        self.cpt = os.path.abspath(args.cpt)
        self.timetoextend = args.extend

    def machine_parser(self):
        parser = argparse.ArgumentParser(
            description='')
        # Machine related arguments
        parser.add_argument('-N', '--nodes', dest='nodes', type=int,
                            help='store the number of nodes allocated for this job',
                            required=True)
        parser.add_argument('-l', '--timelimit', dest='timelimit', type=str,
                            help='store the time limit allocated to this job',
                            required=True)
        
        args, unknown = parser.parse_known_args(sys.argv[3:])
        
        self.nodes = str(args.nodes)
        self.timelimit = str(args.timelimit)


class GmxJobFactory:
    def __init__(self, args):
        self.args = args           
        self.replacement = {'NAME': self.args.name,
                            'EMAIL': email,
                            'TIMELIMIT': self.args.timelimit,
                            'NODE': self.args.nodes,
                            'CPTOPTION': '',
                            'CPTFILE': self.args.cpt,
                            'STRUCT': self.args.struct,
                            'TOPOL': self.args.topol,
                            'MDP': self.args.mdp,
                            'MODULE': modules[self.args.machine],
                            'TIMETOEXTEND': self.args.timetoextend}
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
        if self.args.cpt:
            self.replacement['CPTOPTION'] = '-cpi {0} '.format(self.args.cpt)
        self.write_template('{0}/template_prepare_mdrun.sh'.format(template_path),
                            'prepare_{0}.sh'.format(self.args.name))
        self.write_template('{0}/template_mdrun_{1}.sh'.format(template_path,
                                                               self.args.machine),
                            'job_{0}.sh'.format(self.args.name))
        
    def extend(self):
        print 'Setting extend script'
        self.replacement['NAME'] = 'extd-{0}ns'.format(int(float(self.args.timetoextend)/1000))
        self.replacement['CPTOPTION'] = '-cpi {0}'.format(self.args.cpt)
        self.write_template('{0}/template_prepare_extend.sh'.format(template_path),
                            'prepare_{0}.sh'.format(self.replacement['NAME']))
        self.write_template('{0}/template_mdrun_{1}.sh'.format(template_path,
                                                           self.args.machine),
                            'job_{0}.sh'.format(self.replacement['NAME']))
            
if __name__ == "__main__":
    # # Input parameters handling
    job_args = JobParser()   
    print job_args
    GmxJobFactory(job_args)
    
    

    

    
    
    
    
