# DynaTPH Dataset Repository

Welcome to the DynaTPH dataset repository! 

DynaTPH is a systematically curated structural and biophysical dataset of human T cell receptor-peptide-human leukocyte antigen (TCR-pHLA) complexes, integrating **static experimental structures, molecular dynamics (MD) trajectories and corresponding structural frames, multidimensional physicochemical properties, and experimental binding annotations**. The dataset covers both **HLA class I and class II** complexes and is designed to provide a comprehensive representation of the structural and dynamic landscape of TCR-pHLA recognition. DynaTPH comprises 256 representative TCR-pHLA complexes, each subjected to three independent 50 ns all-atom MD simulations, resulting in 38.4 μs of cumulative simulation time. The dataset includes curated starting structures, dynamic trajectories, trajectory-derived structural frames, multidimensional physicochemical descriptors (hydrogen bonds, intermolecular contacts, solvent-accessible surface area, conformational flexibility), and residue-level dynamic and experimental binding data.

**This GitHub repository contains a lightweight version of the DynaTPH dataset and the dataset-specific scripts used for data collection and screening.**

---

## Useful Links

**Zenodo**：The complete DynaTPH dataset is available on Zenodo **(https://doi.org/10.5281/zenodo.21971877)** 
（The Zenodo repository is currently restricted for peer review.）

The complete `Dynamic Data` are archived on Zenodo because of their large storage requirements.

---

## Dataset Workflow
The overall workflow used to construct the DynaTPH dataset is illustrated below.

<p align="center">
  <img src="dataset_workflow.png" width="90%">
</p>

The scripts provided in this repository correspond to the **Data Collection and Screening** stage of the workflow. Database-specific scripts were used to screen TCR-pHLA structures collected from multiple structural databases, followed by `combine.ipynb` for combining screened records and removing duplicate structures. Detailed information on script inputs, outputs, and usage is provided in `scripts/README.md`.

---


## Dataset Overview

| Item                    | Description        |
| ----------------------- | ------------------ |
| Dataset                 | DynaTPH            |
| Molecular system        | TCR-pHLA complexes |
| Number of complexes     | 256                |
| HLA class I complexes   | 205                |
| HLA class II complexes  | 51                 |
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

The DynaTPH dataset is organized into **four top-level directories** — `Static Data`, `Dynamic Data`, `Feature Data`, and `Rep_Stru_MD` — accompanied by one system-level descriptor file (`descriptor.csv`), three residue-level descriptor files (`rmsf.csv`, `CDR3_pep_contact_freq.csv`, `TCR_IMGT_res_mapping.csv`), one missing-residue modelling record (`modelled_missing_res.csv`), and two experimental binding data files (`TCR_pHLA_affinity.csv`, `peptide_HLA_binding.csv`).

The overall organization of the dataset is illustrated below.

<p align="center">
  <img src="dataset_organization.png" width="90%">
</p>

| Component | Content |
| --------- | ------- |
| `Static Data/` | Curated TCR-pHLA starting structures (PDB) |
| `Dynamic Data/` | MD trajectories (XTC) and extracted frames (PDB) per replica |
| `Feature Data/` | Trajectory-derived physicochemical features per replica |
| `Rep_Stru_MD/` | One representative structure per complex (PDB) |
| `descriptor.csv` | System-level structural, sequence, physicochemical, and dynamic descriptors |
| `rmsf.csv` | Residue-level RMSF of peptide residues |
| `CDR3_pep_contact_freq.csv` | Residue-pair contact frequencies between CDR3β and peptide |
| `TCR_IMGT_res_mapping.csv` | IMGT49 residue mapping for TCR α/β chains |
| `modelled_missing_res.csv` | Record of missing residues modelled before MD |
| `TCR_pHLA_affinity.csv` | Experimental TCR-pHLA binding affinity (ATLAS) |
| `peptide_HLA_binding.csv` | Experimental peptide-HLA binding measurements (IEDB) |

**This GitHub repository contains the lightweight components of DynaTPH and is organized as follows:**


---

## Citation

If you use DynaTPH in your research, please cite the associated publication and the archived dataset.

Citation information for the associated publication will be provided here upon publication.

---

## Contact

For any questions regarding the dataset, please contact the corresponding author.

Lei Fu: [leifu@szu.edu.cn](mailto:leifu@szu.edu.cn)

Institute of Medical Artificial Intelligence, South China Hospital, Medical School, Shenzhen University, Shenzhen, 518116, P. R. China
