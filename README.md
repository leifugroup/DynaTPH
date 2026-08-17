# DynaTPH
A multi-scale structural and biophysical dataset capturing the dynamic landscape of TCR–pHLA recognition.
# DynaTPH

**DynaTPH: A Multi-scale Structural and Biophysical Dataset Capturing the Dynamic Landscape of TCR–pHLA Recognition**

DynaTPH is a multidimensional structural and biophysical dataset designed to characterize the dynamic landscape of T-cell receptor (TCR) recognition of peptide–human leukocyte antigen (pHLA) complexes. The dataset integrates curated experimental TCR–pHLA structures, molecular dynamics (MD) simulations, and trajectory-derived physicochemical descriptors to provide complementary information on static structures, molecular dynamics, and interface properties.

The dataset contains **256 curated TCR–pHLA complexes**, each simulated using three independent MD replicas of 50 ns, resulting in **768 independent trajectories** and **38.4 μs of total simulation time**.

---

## Dataset Overview

| Item                    | Description        |
| ----------------------- | ------------------ |
| Dataset                 | DynaTPH            |
| Molecular system        | TCR–pHLA complexes |
| Number of complexes     | 256                |
| MD replicas per complex | 3                  |
| Total MD replicas       | 768                |
| Production simulation   | 50 ns per replica  |
| Total simulation time   | 38.4 μs            |
| Trajectory format       | XTC                |
| Structure format        | PDB                |
| Frame interval          | 50 ps              |
| Frames per replica      | 1,001              |

---

## Dataset Organization

The DynaTPH dataset is organized into three major data categories: **Static Data**, **Dynamic Data**, and **Feature Data**, together with system-level and residue-level descriptor files, `descriptor.csv` and `rmsf.csv`, respectively.

The overall organization of the dataset is illustrated below.

<p align="center">
  <img src="figures/dataset_organization.png" width="90%">
</p>

The repository is organized as follows:

```text
DynaTPH/
├── Static Data/
├── Feature Data/
├── descriptor.csv
├── rmsf.csv
└── README.md
```

The complete dataset additionally contains the `Dynamic Data` directory, which is archived on Zenodo because of its large storage requirements.

---

## Data Description

### 1. Static Data

The `Static Data` directory contains curated TCR–pHLA complex structures used as the initial configurations for molecular dynamics simulations.

Each structure is provided in PDB format and named according to its PDB ID.

```text
Static Data/
├── 1BD2.pdb
├── XXXX.pdb
└── ...
```

A total of **256 TCR–pHLA complexes** are included.

The structures were curated and preprocessed before MD simulations to obtain standardized starting configurations. Structure preprocessing information is recorded in `descriptor.csv`.

---

### 2. Dynamic Data

The `Dynamic Data` directory contains the molecular dynamics trajectories and corresponding structural frames generated for the 256 TCR–pHLA complexes.

Because of the large size of the trajectory and frame files, **Dynamic Data is not included in this GitHub repository**.

Instead, the complete `Dynamic Data` directory is available as part of the full DynaTPH dataset archived on **Zenodo**.

The dynamic data are organized by PDB ID and simulation replica:

```text
Dynamic Data/
└── PDB_ID/
    ├── Replica0/
    │   ├── *.xtc
    │   └── Frames/
    │       ├── *.pdb
    │       ├── *.pdb
    │       └── ...
    ├── Replica1/
    │   ├── *.xtc
    │   └── Frames/
    └── Replica2/
        ├── *.xtc
        └── Frames/
```

Each complex contains three independent simulations:

* `Replica0`
* `Replica1`
* `Replica2`

Each replica consists of a **50 ns production trajectory** stored in XTC format and a corresponding `Frames` directory.

Structural frames were extracted from the trajectories at **50 ps intervals**, resulting in **1,001 frames per replica**, including the initial frame at 0 ps.

The first frame (0 ps) corresponds to the initial TCR–pHLA complex structure used for the corresponding simulation.

The index `i` in replica-specific file names denotes:

* `i = 0`: `Replica0`
* `i = 1`: `Replica1`
* `i = 2`: `Replica2`

All trajectories and extracted frames contain the TCR–pHLA complex, with solvent molecules and ions removed.

---

### 3. Feature Data

The `Feature Data` directory contains multidimensional physicochemical and structural descriptors derived from the molecular dynamics trajectories.

The directory is organized by PDB ID and simulation replica:

```text
Feature Data/
└── PDB_ID/
    ├── Replica0/
    ├── Replica1/
    └── Replica2/
```

The feature data include trajectory-derived properties such as:

* RMSD of the peptide, TCR, and HLA
* peptide RMSF
* solvent-accessible surface area (SASA)
* hydrogen-bond profiles
* contact profiles

Interface-specific descriptors are provided for both:

* `TCR_pHLA`: TCR–pHLA interface
* `pep_HLA`: peptide–HLA interface

These features provide complementary information on structural stability, conformational fluctuations, intermolecular hydrogen bonding, and interfacial contacts during the MD simulations.

---

### 4. `descriptor.csv`

`descriptor.csv` is the **system-level descriptor file** of DynaTPH.

Each row corresponds to one TCR–pHLA complex and is indexed by PDB ID.

The file contains structural, sequence, physicochemical, and dynamic information, including:

#### Structural and sequence information

* PDB ID
* HLA class
* HLA allele
* peptide sequence
* peptide length

#### Physicochemical and interface properties

* peptide SASA
* peptide–HLA hydrogen-bond counts
* peptide–HLA contact counts
* TCR–pHLA hydrogen-bond counts
* TCR–pHLA contact counts

Dynamic quantities were calculated from the three independent MD trajectories using a consistent analysis workflow and summarized at the system level.

Information describing structural modifications and preprocessing applied before MD simulations is also recorded in this file.

---

### 5. `rmsf.csv`

`rmsf.csv` provides **residue-level RMSF information for peptide residues** in individual TCR–pHLA complexes.

Each RMSF value is associated with a specific peptide residue and PDB ID.

Because peptide sequences have variable lengths, residue-level RMSF values are provided separately rather than being incorporated into the fixed-column, system-level `descriptor.csv`.

This organization preserves the residue-level information without introducing a large number of length-dependent columns into the system-level descriptor table.

---

## Molecular Dynamics Simulations

The molecular dynamics simulations were performed using a standardized simulation workflow.

| Parameter                 | Setting                   |
| ------------------------- | ------------------------- |
| MD engine                 | GROMACS 2023.5            |
| Force field               | CHARMM36m                 |
| Water model               | TIP3P                     |
| Replicas                  | 3 independent simulations |
| Production time           | 50 ns per replica         |
| Total simulation time     | 38.4 μs                   |
| Frame extraction interval | 50 ps                     |
| Frames per replica        | 1,001                     |

For detailed simulation and analysis protocols, please refer to the associated publication.

---

## File Naming Conventions

The dataset uses consistent naming conventions across trajectory and feature files.

### Simulation replicas

| Identifier | Replica    |
| ---------- | ---------- |
| `0`        | `Replica0` |
| `1`        | `Replica1` |
| `2`        | `Replica2` |

### Interface identifiers

| Identifier | Meaning               |
| ---------- | --------------------- |
| `TCR_pHLA` | TCR–pHLA interface    |
| `pep_HLA`  | peptide–HLA interface |

PDB IDs are used consistently across the Static Data, Dynamic Data, Feature Data, and descriptor files to enable cross-referencing between different data modalities.

---

## Data Availability

### GitHub Repository

This GitHub repository provides the lightweight and directly accessible components of DynaTPH, including:

* `Static Data`
* `Feature Data`
* `descriptor.csv`
* `rmsf.csv`
* dataset documentation and organization information

The large `Dynamic Data` directory is intentionally excluded from this GitHub repository because of its substantial storage requirements.

### Complete Dataset

**The complete DynaTPH dataset is available on Zenodo.**

The Zenodo archive contains **all components of the dataset**, including:

* `Static Data`
* `Dynamic Data`
* `Feature Data`
* `descriptor.csv`
* `rmsf.csv`

Thus, **Zenodo should be used as the complete and archived version of the DynaTPH dataset**, whereas this GitHub repository provides a convenient, lightweight entry point for accessing and exploring the dataset.

**Zenodo DOI:** 10.5281/zenodo.21971877

---

## Citation

If you use DynaTPH in your research, please cite the associated publication and the archived dataset.

### Dataset

DynaTPH. Zenodo.
DOI: **10.5281/zenodo.21971877**

### Associated publication

Citation information for the associated publication will be provided here upon publication.

---

## Contact

For questions regarding the dataset, please contact the corresponding authors of the associated publication.
