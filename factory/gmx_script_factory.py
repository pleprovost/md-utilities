
import re
import os
import sys
import argparse
import subprocess

# Description
description = """ """

# Config parameters
email = 'pierre.leprovost@oulu.fi'
template_path= '/koti/pleprovo/gmx-utilities/factory'
machines = ('taito', 'carpo', 'sisu', 'local')

class JobParser:
    job = None
    machine = None
    topol = None
    name = None
    struct = None
    mdp = None
    extend = None
    cpt = None
    nodes = None
    timelimit = None
    
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
                            help='store the topology of the system,'\
                            ' the file must be of type .TOP, .TPR or .CPT for continuation job',
                        required=True)
        
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

        self.machine_parser()
            
        self.job = args.job
        self.machine = args.machine
        self.topol = os.path.abspath(args.topol)        
    
    def __str__(self):
        output = '>>>>>>>>>>>>>>>\n'
        output += 'Job type : {0}\n'.format(self.job)
        if self.job == 'mdrun':
            output += 'Job name : {0}\nStructure : {1}\nTopology : {2}\nmdp file : {3}'.format(
                self.name,
                self.struct,
                self.topol,
                self.mdp)
        if self.job == 'extend':
            output += 'Topology : {0}\n>cpt file : {1}\ntime to extend : {2}\n'.format(
                self.topol,
                self.cpt,
                self.extend)

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
        
        args, unknown = parser.parse_known_args(sys.argv[3:])

        self.name = args.name
        self.struct = os.path.abspath(args.struct)
        self.mdp = os.path.abspath(args.mdp)
        
    def extend(self):
        parser = argparse.ArgumentParser(
            description='Extend job arguments')
        # NOT prefixing the argument with -- means it's not optional
        # extend
        parser.add_argument('-c', '--cpt', dest='cpt', type=str,
                            help='store the time to extend the simulation for extend jobs',
                            required=True)
        parser.add_argument('-e', '--extend', dest='extend', type=float,
                            help='store the time to extend the simulation for extend jobs',
                            required=True)
        
        args, unknown = parser.parse_known_args(sys.argv[3:])

        self.cpt = os.path.abspath(args.cpt)
        self.extend = str(args.extend)

    def machine_parser(self):
        if self.machine == 'local':
            pass
        else:
            parser = argparse.ArgumentParser(
                description='')
            # Machine related arguments
            parser.add_argument('-N', '--nodes', dest='nodes', type=int,
                                help='store the number of nodes allocated for this job',
                                required=True)
            parser.add_argument('-tl', '--timelimit', dest='timelimit', type=str,
                                help='store the time limit allocated to this job',
                                required=True)
            
            args, unknown = parser.parse_known_args(sys.argv[3:])

            self.nodes = str(args.nodes)
            self.timelimit = str(args.timelimit)


class GmxPrepare:
    def __init__(self, args):
        self.args = args
        if self.args.job == 'extend':
            cpt_option = '-cpi {0} -noappend'.format(self.args.cpt)
        else:
            cpt_option = ''
            
        self.replacement = {'MDRUN_NAME': self.args.name,
                            'EMAIL': email,
                            'TIME': self.args.timelimit,
                            'NB_NODE': self.args.nodes,
                            'CPT_OPTION':cpt_option}
        
    def mdrun(self):
        # cpt_option = ''
        # if self.args.cpt:
        #     cpt_option = '-t {0}'.format(self.args.cpt)

        # commands = 'set -e; '
        # if self.args.machine in ['taito', 'gpu']:
        #     commands += 'module load gromacs-env; '
        # commands += 'mkdir {0}; '.format(self.args.name)
        # commands += 'gmx grompp -f {0} -c {1} -p {2} -o {3} {4}'.format(
        #     self.args.mdp,
        #     self.args.struct,
        #     self.args.topol,
        #     self.args.name+'/'+self.args.name+'.tpr',
        #     cpt_option)
        # subprocess.check_call(commands, shell=True)
        
    def extend(self):
        # commands = 'set -e; '
        # if self.args.machine in ['taito', 'gpu']:
        #     commands += 'module load gromacs-env; '
        # commands += 'gmx convert-tpr -s {0} -f {1} -until {2} -o {3}'.format(
        #     self.args.topol,
        #     self.args.cpt,
        #     int(self.args.extend*1000),
        #     self.args.name+'.tpr')
        # subprocess.check_call(commands, shell=True)
        
    def write_template(self, template_name):
        # template = ''        
        # with open('{0}/templates/template_mdrun_{1}.sh'.format(template_path, self.args.machine), 'r') as infile:
        #     template = infile.read()
        #     for key, value in self.replacement.iteritems():
        #         template = template.replace(key, value)
 
        # with open('{0}/{1}.sh'.format(filepath, filename), 'w') as outfile:
        #     outfile.write(template)
        with open(filename, 'r') as template_file:
            template_text = template_file.read()
            for key, value in self.replacement.iteritems():
                template_text = template.replace(key, value)
        
        with open('{0}/{1}'.format(outpath, outname), 'w') as outfile:
            outfile.write(template)
        
        
    def run(self):
        # if self.args.job == 'mdrun':
        #     self.mdrun()
        #     self.write_script(self.args.name, self.args.name)
            
        # if self.args.job == 'extend':
        #     self.extend()
        #     self.write_script(self.args.name)


            
if __name__ == "__main__":
    # # Input parameters handling
    job_args = JobParser()   
    print job_args
    wrapper = GmxWrapper(job_args)
    wrapper.run()
    
    

    

    
    
    
    
