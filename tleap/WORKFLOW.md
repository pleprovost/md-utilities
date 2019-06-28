
#Workflow for preparation of thiolases system with ambertools suite

## Preparation:
1. If the structure has a ligand remove it from the pdb 

2. Thiolase pdb do not have the same starting chain remove the extras

3. run ```pdb4amber --nohyd```

4. Change HETATM to ATOM if SCY is present

5. Cat the ligand with the protein

6. Set protonation by changin residue name using sed

7. run tleap with the modified tleap_template

8. Convert the .prmcrd .prmtop to .gro and .top using ```parmed_convert.py``` script

9. Check atoms problem in .top file
**With ligand change the prime phosphate hydrogen values**
```
sigma 0.178179  epsilon 0.03000	
0.178179       0.03000
```
		
10. Add position restraint using gmx genrestr and make_ndx for protein-h and backbone

11 .Create index.ndx with Protein (+ligand) and non protein

**And now you can simulate everything !**

## Simualtion workflow:

### Minimization
Steepest Descent until convergence 100 kj.mol-1 (This is tight convergence criterion up to 1000 kj.mol-1 is acceptable)

### NVT Equilibration
* T : V-rescale
* Constrain : h-bonds/all-bonds
* Restrain : full (Protein + ligand)
	
### NPT Equilibration

#### Full restraint
* T : V-rescale
* P : Berendsen
* Constrain : h-bonds/all-bonds
* Restrain : full
	
#### Partial restraint
* T : V-rescale 
* P : Berendsen
* refcoord scaling com 
* Constrain : h-bonds/all-bonds
* Restrain : partial (backbone + ligand)
	
#### "Weak" restraint
* T : V-rescale 
* P : Berendsen
* refcoord scaling com
* Constrain : h-bonds/all-bonds
* Restrain : partial (backbone only)

### NPT Production
* T : V-rescale
* P : Parinello-Rahman
* Constrain : h-bonds/all-bonds


	

