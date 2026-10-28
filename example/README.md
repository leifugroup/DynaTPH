# TCR–pHLA: From Crystal Structure to MD Simulation and Analysis

This repository provides an example workflow for running a complete complex molecular dynamics (MD) simulation with **GROMACS**. The pipeline takes you from raw PDB preparation and topology generation all the way through equilibration, production runs, and post-simulation analysis.

- **Software**: GROMACS **2023.5**
- **Force Field**: CHARMM36 (`-ff charmm36`)
- **Water Model**: TIP3P (`-water tip3p`)
- **Production Runs**: 3 × 50 ns NPT ensemble

## Workflow Diagram

```
Phase 0: System Setup ──▶ Phase 1: Equilibration (EM → NVT → NPT) ──▶ Phase 2: Production (3×50 ns NPT) ──▶ Phase 3: Analysis & Feature Extraction
```


| Phase | Stage                     | In → Out                                                  |
| ----- | ------------------------- | --------------------------------------------------------- |
| **0** | **System Setup**          | `1ao7.pdb` → `solv_ions.gro` + `topol.top`                |
| **1** | **Equilibration**         | `solv_ions.gro` → `em.gro` → `nvt.gro` → `npt.gro`        |
| **2** | **Production Simulation** | `npt.gro` → `md.xtc` + `md.gro` (3 × 50 ns)              |
| **3** | **Analysis**              | `md.xtc` → RMSD/RMSF/SASA/H-bond features + trajectory frames |

## Prerequisites

- **GROMACS 2023.5** – the only tested version; newer or older releases may behave differently with `-maxwarn` and checkpoint handling.
- A **Bash** shell to drive the workflow and execute the analysis scripts.
- The `.mdp` parameter files (`em.mdp`, `nvt.mdp`, `npt.mdp`, `md.mdp`, `ions.mdp`) and the analysis scripts (`extract_traj_frames.sh`, `rmsf_sasa.sh`, `hbond.sh`).


## Usage

### Phase 0 · Build the system

**In:** RCSB crystal structure (e.g. `1ao7.pdb`) &nbsp; **→** &nbsp; **Out:** `solv_ions.gro` + `topol.top`

**Example Protein.** This example uses a **pMHC–TCR ternary complex** (PDB `1ao7`) composed of five polypeptide chains:

| Chain | Component              |
| ----- | ---------------------- |
| **A** | MHC                    |
| **B** | β2-microglobulin (β2m) |
| **C** | Antigenic peptide      |
| **D** | TCR α chain            |
| **E** | TCR β chain            |

Start from the crystal structure of the complex, strip away crystallographic waters and any bound ligands, perform structural preprocessing, and add missing heavy atoms with MODELLER. From that prepared structure, generate a CHARMM36 topology, centre the complex in a cubic box, fill it with TIP3P water, and add counter-ions plus NaCl to reach an ionic strength of 0.15 M.

```bash
# Create folders and run commands 3 times
mkdir 0 1 2
# Note: The following setup commands should be executed three times in separate `0`, `1`, and `2` folders for the same system.

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


### Phase 1 · Equilibration

**In:** `solv_ions.gro` + `topol.top` &nbsp; **→** &nbsp; **Out:** `npt.gro` (+ `nvt.cpt` checkpoint)

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


### Phase 2 · Production Simulation

**In:** `npt.gro` (+ `npt.cpt`) + `topol.top` &nbsp; **→** &nbsp; **Out:** `md.xtc` + `md.gro` (3 × 50 ns NPT)

Launch the production MD run (3 × 50 ns, NPT ensemble):

```bash
gmx grompp -f md.mdp -c npt.gro -r npt.gro -p topol.top -o md.tpr -maxwarn 2
nohup gmx mdrun -deffnm md &
```


### Phase 3 · Analysis & Feature Extraction

**In:** `md.xtc` (+ `md.gro` / `md.tpr`) &nbsp; **→** &nbsp; **Out:** trajectory frames + extracted features

Extract trajectories, then compute the following features already available from the trajectory:

| Feature | Tool / Script     | What it measures                              |
| ------- | ----------------- | --------------------------------------------- |
| **RMSD**    | `gmx rms`              | Backbone / heavy-atom deviation over time     |
| **RMSF**    | `rmsf_sasa.sh`         | Residue-level fluctuations (B-factor proxy)   |
| **SASA**    | `rmsf_sasa.sh`         | Solvent-accessible surface area               |
| **H-bonds** | `hbond.sh`             | Inter- and intra-chain hydrogen-bond counts   |
| **Contacts** | `contact_pHLA.sh`      | pHLA interface contacts (MHC–peptide)         |
| **Contacts** | `contact_TCR_pHLA.sh`  | TCR–pMHC interface contacts (TCR–peptide/MHC) |

All analysis scripts are executed with `bash *.sh`:

```bash
bash extract_traj_frames.sh
bash rmsf_sasa.sh
bash hbond.sh
bash contact_pHLA.sh
bash contact_TCR_pHLA.sh
```
Note: After performing the analysis in the three folders (0, 1, and 2), the properties provided in descriptors.csv are obtained by calculating the average of the results.
