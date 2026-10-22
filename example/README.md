# TCR–pHLA Complex: From Crystal Structure to MD Simulation and Analysis 

This repository provides an example workflow for running a complete complex molecular dynamics (MD) simulation with **GROMACS**. The pipeline takes you from raw PDB preparation and topology generation all the way through equilibration, production runs, and post-simulation analysis.

- **Software**: GROMACS **2023.5**
- **Force Field**: CHARMM36 (`-ff charmm36`)
- **Water Model**: TIP3P (`-water tip3p`)
- **Production Runs**: 3 × 50 ns NPT ensemble

## Workflow Diagram

```
System Setup ──▶ Equilibration (EM → NVT → NPT) ──▶ Production (3×50 ns NPT) ──▶ Analysis
```


| Stage                     | Description                                       |
| ------------------------- | ------------------------------------------------- |
| **System Setup**          | Solvated system built from a clean PDB            |
| **Equilibration**         | Energy Minimisation (EM), NVT, then NPT           |
| **Production Simulation** | 3 independent 50 ns runs in the NPT ensemble      |
| **Analysis**              | Extracting trajectories, structures, and analysis |




## Prerequisites

- **GROMACS 2023.5** – the only tested version; newer or older releases may behave differently with `-maxwarn` and checkpoint handling.
- A **Bash** shell to drive the workflow and execute the analysis scripts.
- The `.mdp` parameter files (`em.mdp`, `nvt.mdp`, `npt.mdp`, `md.mdp`, `ions.mdp`) and the analysis scripts (`extract_traj_frames.sh`, `rmsf_sasa.sh`, `hbond.sh`).



## Repository Structure

```
.
├── Static_Data/            # Input structure (e.g. 1ao7.pdb)
├── mdp_files/             # Simulation parameter files
├── extract_traj_frames.sh # Extract trajectory frames
├── rmsf_sasa.sh           # RMSF and SASA analysis
├── hbond.sh               # Hydrogen-bond analysis
└── README.md
```



## Usage



### 1. System Setup

**Example Protein.** This example uses a **pMHC–TCR ternary complex** (PDB `1ao7`) composed of five polypeptide chains:


| Chain | Component              |
| ----- | ---------------------- |
| **A** | MHC                    |
| **B** | β2-microglobulin (β2m) |
| **C** | Antigenic peptide      |
| **D** | TCR α chain            |
| **E** | TCR β chain            |


Start from the crystal structure of the complex, strip away crystallographic waters and any bound ligands, perform structural preprossing, and add missing heavy atoms with MODELLER. From that prepared structure, generate a CHARMM36 topology, centre the complex in a cubic box, fill it with TIP3P water, and add counter-ions plus NaCl to reach an ionic strength of 0.15 M.

```bash
# Generate topology and process the structure
gmx pdb2gmx -f Static_Data/1ao7.pdb -ignh -ff charmm36 -water tip3p -o conf.pdb
echo System | gmx editconf -f conf.pdb -o box_x.gro -c -princ
gmx editconf -f box_x.gro -o box.gro -rotate 0 90 0 -c -d 1.5 -bt cubic

# Solvate the system
gmx solvate -cp box.gro -cs spc216.gro -p topol.top -o solv.gro

# Neutralise and set ionic strength to 0.15 M NaCl
gmx grompp -f ions.mdp -c solv.gro -p topol.top -o ions.tpr -maxwarn 1
echo SOL | gmx genion -s ions.tpr -p topol.top -o ions.gro \
    -pname NA -nname CL -conc 0.15 -neutral
echo q | gmx make_ndx -f ions.gro
```



### 2. Equilibration

Run Energy Minimisation (EM), followed by NVT and NPT equilibration:

```bash
# Energy Minimisation
gmx grompp -f em.mdp -c solv_ions.gro -p topol.top -o em.tpr -maxwarn 2
nohup gmx mdrun -deffnm em &

# NVT equilibration
gmx grompp -f nvt.mdp -c em.gro -r em.gro -p topol.top -o nvt.tpr -maxwarn 2
nohup gmx mdrun -deffnm nvt &

# NPT equilibration
gmx grompp -f npt.mdp -c nvt.gro -r nvt.gro -t nvt.cpt -p topol.top -o npt.tpr -maxwarn 2
nohup gmx mdrun -deffnm npt &
```



### 3. Production Simulation

Launch the production MD run (3 × 50 ns, NPT ensemble):

```bash
gmx grompp -f md.mdp -c npt.gro -r npt.gro -p topol.top -o md.tpr -maxwarn 2
nohup gmx mdrun -deffnm md &
```



### 4. Analysis

Extract trajectories and run the structural and physicochemical analyses:

```bash
bash extract_traj_frames.sh
bash rmsf_sasa.sh
bash hbond.sh
```



