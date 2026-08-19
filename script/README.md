# DynaTPH

Jupyter notebooks used for the **data collection and screening** stage of DynaTPH. The notebooks process TCR–peptide–MHC structure records collected from six public databases and identify human HLA-restricted PDB structures for subsequent dataset curation.
﻿
The screened records from the six databases are then combined and deduplicated using `combine.ipynb`.

## What each notebook does

| Notebook | Database | Input | Output |
|---|---|---|---|
| `ATLAS.ipynb` | [ATLAS](https://atlas.wenglab.org/) | `ATLAS/ATLAS.xlsx` | `ATLAS/ATLAS_pdb.csv`, `ATLAS/ATLAS_hla.csv` |
| `TCR3d.ipynb` | [TCR3d](https://tcr3d.ibbr.umd.edu/) | `TCR3d/TCR3d_raw.tsv` | `TCR3d/TCR3d_pdb.csv`, `TCR3d/TCR3d_hla.csv` |
| `TRAIT.ipynb` | [TRAIT](https://pgx.zju.edu.cn/trait/) | `TRAIT/Interactive_TCR-pMHC_Pairs.xlsx` | `TRAIT/TRAIT_pdb.csv`, `TRAIT/TRAIT_hla.csv` |
| `VDJdb.ipynb` | [VDJdb](https://vdjdb.cdr3.net/) | `VDJdb/vdjdb-2025-02-21/vdjdb.txt` | `VDJdb/VDJdb_pdb.csv`, `VDJdb/VDJdb_hla.csv` |
| `STCRDab.ipynb` | [STCRDab](https://opig.stats.ox.ac.uk/webapps/stcrdab-stcrpred/) | `STCRDab/STCRDab_raw.tsv` | `STCRDab/STCRDab_pdb.csv`, `STCRDab/STCRDab_hla.csv`, `STCRDab/pdb.csv` |
| `IEDB.ipynb` | [IEDB](https://www.iedb.org/) | `IEDB/tcell_full_v3.csv` | `IEDB/IEDB_pdb.csv`, `IEDB/IEDB_hla.csv` |
| `combine.ipynb` | merges all six above | `total.tsv`, `newpdb_name.txt`, all `*_pdb/*_hla` outputs | `unique_pdb.csv`, `drop_duplicates/*.pdb.txt`, `hla.csv` |

Each database notebook cleans in 4 steps: (0) load raw data → (1) drop rows without PDB, keep relevant records → (2) drop duplicate PDBs → (3) keep only human HLA-restricted structures. It also writes `0.pdb.txt`–`3.pdb.txt` (PDB lists per step) in the same folder.

## Dependencies

Python 3 + `pip install pandas openpyxl requests beautifulsoup4` (`requests`/`bs4` only needed by `STCRDab.ipynb`). `wget`/`unzip` needed only if you use the commented download cells.

## How to use

1. **Download raw data** — download each database file into its folder (URLs are in the commented cells of each notebook; uncomment them or download manually).
2. **Run the six database notebooks** — open in Jupyter and run top to bottom, in any order.
3. **Run `combine.ipynb` last** — it merges the six results. Before running, prepare:
   - `total.tsv` — columns are the six databases, cells are the PDB IDs each contributed.
   - `newpdb_name.txt` — your target PDB list, one per line.
   
   Output: `hla.csv`, the final consolidated PDB → HLA table (original PDB casing kept in `RAW_PDB`).

Headless alternative: `jupyter nbconvert --to notebook --execute --inplace <notebook>.ipynb`
