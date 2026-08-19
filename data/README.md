# TCR–pMHC Database Curation Pipeline

A collection of Jupyter notebooks that download, clean, and unify **TCR–peptide–MHC (pMHC) complex structure** records from six public databases. Each per-database notebook filters its source into a curated list of **human (HLA-restricted) PDB structures**, and `combine.ipynb` merges all of them into a single consolidated PDB → HLA mapping table.

| Notebook | Source database | Curated output |
|---|---|---|
| [`ATLAS.ipynb`](ATLAS.ipynb) | [ATLAS](https://atlas.wenglab.org/) | `ATLAS_pdb.csv`, `ATLAS_hla.csv` |
| [`TCR3d.ipynb`](TCR3d.ipynb) | [TCR3d](https://tcr3d.ibbr.umd.edu/) | `TCR3d_pdb.csv`, `TCR3d_hla.csv` |
| [`TRAIT.ipynb`](TRAIT.ipynb) | [TRAIT](https://pgx.zju.edu.cn/trait/) | `TRAIT_pdb.csv`, `TRAIT_hla.csv` |
| [`VDJdb.ipynb`](VDJdb.ipynb) | [VDJdb](https://vdjdb.cdr3.net/) | `VDJdb_pdb.csv`, `VDJdb_hla.csv` |
| [`STCRDab.ipynb`](STCRDab.ipynb) | [STCRDab](https://opig.stats.ox.ac.uk/webapps/stcrdab-stcrpred/) | `STCRDab_pdb.csv`, `STCRDab_hla.csv`, `pdb.csv` |
| [`IEDB.ipynb`](IEDB.ipynb) | [IEDB](https://www.iedb.org/) (T cell full v3) | `IEDB_pdb.csv`, `IEDB_hla.csv` |
| [`combine.ipynb`](combine.ipynb) | — (merges all six) | `unique_pdb.csv`, `drop_duplicates/*.pdb.txt`, `hla.csv` |

---

## 1. Common pipeline (all six per-database notebooks)

Every per-database notebook follows the same four-stage cleaning workflow. A PDB-ID list is dumped to `{N}.pdb.txt` after **each** stage so you can inspect exactly which structures survive at every filter level:

| Stage | Filter level | What happens |
|---|---|---|
| Raw download | `0.pdb.txt` | All PDB IDs present in the raw dump (including missing/NA values) |
| Filter 1 | `1.pdb.txt` | Remove rows **without** a PDB ID; lowercase PDB IDs; apply database-specific content rules (see each notebook below) |
| Filter 2 | `2.pdb.txt` | **Drop duplicate** PDB IDs |
| Filter 3 | `3.pdb.txt` | Keep only **human MHC** rows, i.e. alleles starting with `HLA` |

Final outputs produced after stage 3:

- **`<DB>/<DB>_pdb.csv`** — one column, the final list of unique human PDB IDs.
- **`<DB>/<DB>_hla.csv`** — a PDB → MHC-allele mapping (PDB as the row index, one or more allele columns), used later by `combine.ipynb`.

> ⚠️ **Before running:** every notebook contains a commented-out download cell (using `wget`/`unzip`/`mkdir`). You must either uncomment it or manually download the raw data into the corresponding `<DB>/` folder (the exact URL is given in each section below). If a folder does not exist, create it first.

---

## 2. Per-notebook details

### 2.1 `ATLAS.ipynb` — ATLAS

- **Database:** [ATLAS](https://atlas.wenglab.org/) — curated TCR–pMHC complex structures.
- **Input:** `ATLAS/ATLAS.xlsx` — download from `https://atlas.wenglab.org/web/tables/ATLAS.xlsx` (the `Index` column is dropped on load).
- **Filtering rules:**
  1. Drop rows without a `true_PDB` value (stage 1).
  2. Drop duplicate `true_PDB` (stage 2).
  3. Keep rows whose `MHCname` starts with `HLA` (stage 3, human MHC).
- **Outputs:**
  - `ATLAS/0.pdb.txt`, `ATLAS/1.pdb.txt`, `ATLAS/2.pdb.txt`, `ATLAS/3.pdb.txt`
  - `ATLAS/ATLAS_pdb.csv` — final human PDB list (column `ATLAS`).
  - `ATLAS/ATLAS_hla.csv` — PDB → MHC name mapping (PDB as index, column `TRAIT_MHCname`).

### 2.2 `TCR3d.ipynb` — TCR3d

- **Database:** [TCR3d](https://tcr3d.ibbr.umd.edu/) — TCR–peptide–MHC complex structures.
- **Input:** `TCR3d/TCR3d_raw.tsv` (tab-separated) — download from `https://tcr3d.ibbr.umd.edu/static/download/tcr_complexes_data.tsv`.
- **Filtering rules:**
  1. Manually fill empty `MHC_allele` with `HLA` for a known rule list of PDB IDs: `8rj5`, `8yiv`, `8yj2`, `9c3e`; lowercase `PDB_ID` (stage 1).
  2. Drop duplicate `PDB_ID` (stage 2).
  3. Keep rows whose `MHC_allele` starts with `HLA` (stage 3).
- **Outputs:**
  - `TCR3d/0.pdb.txt` … `TCR3d/3.pdb.txt`
  - `TCR3d/TCR3d_pdb.csv` — final human PDB list (column `TCR3d`).
  - `TCR3d/TCR3d_hla.csv` — PDB → allele mapping (PDB as index, column `TCR3d_MHC_allele`).

### 2.3 `TRAIT.ipynb` — TRAIT

- **Database:** [TRAIT](https://pgx.zju.edu.cn/trait/) — TCR–pMHC pairs with structural information.
- **Input:** `TRAIT/Interactive_TCR-pMHC_Pairs.xlsx` — download the zip `https://pgx.zju.edu.cn/download.trait/Interactive_TCR-pMHC_Pairs.zip`, unzip it into `TRAIT/`.
- **Filtering rules:**
  1. Drop rows without a `Structure` (PDB) value; lowercase (stage 1).
  2. Drop duplicate `Structure` (stage 2).
  3. Keep rows whose `MHC_A` starts with `HLA` (stage 3; `MHC_A`/`MHC_B` allele statistics are printed first).
- **Outputs:**
  - `TRAIT/TRAIT_raw.csv` — raw dump in CSV form.
  - `TRAIT/0.pdb.txt` … `TRAIT/3.pdb.txt`
  - `TRAIT/TRAIT_pdb.csv` — final human PDB list (column `TRAIT`).
  - `TRAIT/TRAIT_hla.csv` — PDB → allele mapping (PDB as index, columns `TRAIT_MHC_A`, `TRAIT_MHC_B`).

### 2.4 `VDJdb.ipynb` — VDJdb

- **Database:** [VDJdb](https://vdjdb.cdr3.net/) — TCR epitope specificity database (GitHub release `antigenomics/vdjdb-db`).
- **Input:** `VDJdb/vdjdb-2025-02-21/vdjdb.txt` (tab-separated) — download `https://github.com/antigenomics/vdjdb-db/releases/download/pyvdjdb-2025-02-21/vdjdb-2025-02-21.zip` and unzip into `VDJdb/`.
- **Filtering rules:**
  1. Extract `structure.id` from the JSON `meta` column; keep only 4-character PDB IDs; lowercase (stage 1).
  2. Drop duplicate `structure.id` (stage 2).
  3. Keep rows whose `mhc.a` starts with `HLA` (stage 3; `mhc.a`/`mhc.b` statistics printed first).
- **Outputs:**
  - `VDJdb/0.pdb.txt` … `VDJdb/3.pdb.txt`
  - `VDJdb/VDJdb_pdb.csv` — final human PDB list (column `VDJdb`).
  - `VDJdb/VDJdb_hla.csv` — PDB → allele mapping (PDB as index, columns `VDJdb_mhc.a`, `VDJdb_mhc.b`).

### 2.5 `STCRDab.ipynb` — STCRDab

- **Database:** [STCRDab](https://opig.stats.ox.ac.uk/webapps/stcrdab-stcrpred/) — Structural T-Cell Receptor Database.
- **Input:** `STCRDab/STCRDab_raw.tsv` (tab-separated) — download from `https://opig.stats.ox.ac.uk/webapps/stcrdab-stcrpred/summary/all`.
- **Filtering rules:**
  1. Keep rows satisfying **all** rules: `TCRtype == 'abTCR'`, `antigen_type == 'peptide'`, `mhc_type ∈ {'MH1','MH2'}`; lowercase `pdb` (stage 1).
  2. Drop duplicate `pdb` (stage 2).
  3. Keep rows whose `compound` contains `HLA` (stage 3).
  4. *(Extra cell)* Scrapes the STCRDab [Browser page](https://opig.stats.ox.ac.uk/webapps/stcrdab-stcrpred/Browser?all=true) with `requests` + `BeautifulSoup` to build a PDB metadata table (species, method, resolution, affinity, TCR chains) → `STCRDab/pdb.csv`. **This file is required by `combine.ipynb` for the species check.**
- **Outputs:**
  - `STCRDab/0.pdb.txt` … `STCRDab/3.pdb.txt`
  - `STCRDab/STCRDab_pdb.csv` — final human PDB list (column `STCRDab`).
  - `STCRDab/STCRDab_hla.csv` — PDB → allele mapping (PDB as index, column `STCRDab_compound`).
  - `STCRDab/pdb.csv` — scraped PDB metadata (columns: `PDB`, `Species`, `Method`, `Resolution`, `Affinity`, `TCR_Chains`).

### 2.6 `IEDB.ipynb` — IEDB

- **Database:** [IEDB](https://www.iedb.org/) — Immune Epitope Database, T cell assay full export (v3).
- **Input:** `IEDB/tcell_full_v3.csv` — download `https://www.iedb.org/downloader.php?file_name=doc/tcell_full_v3.zip` and unzip into `IEDB/`. The CSV has a **two-level header** (group / field), read with `header=[0,1]`.
- **Filtering rules:**
  1. Drop rows without a `('Complex','PDB ID')`; keep only `('Epitope','Object Type') == 'Linear peptide'` **and** `('Assay','Qualitative Measurement') == 'Positive'`; keep 4-character PDB IDs; lowercase (stage 1).
  2. Drop duplicate `('Complex','PDB ID')` (stage 2).
  3. Keep rows whose `('MHC Restriction','Name')` starts with `HLA` (stage 3).
- **Outputs:**
  - `IEDB/0.pdb.txt` … `IEDB/3.pdb.txt`
  - `IEDB/IEDB_pdb.csv` — final human PDB list (column `IEDB`).
  - `IEDB/IEDB_hla.csv` — PDB → allele mapping (columns `pdb`, `IEDB_mhc`; no index).

---

## 3. `combine.ipynb` — merging everything

`combine.ipynb` is **not** tied to a single database. It consumes the outputs of the six notebooks above and produces the final consolidated tables. Run it **after** all six per-database notebooks have completed.

### Inputs (must exist before running)

| File | Produced by | Purpose |
|---|---|---|
| `total.tsv` | user-provided | Tab-separated file whose **columns are the six databases** and whose cells are the PDB IDs each database contributed (a PDB × database occurrence matrix). |
| `STCRDab/pdb.csv` | `STCRDab.ipynb` | PDB metadata used for the **species check**. |
| `{DB}/0.pdb.txt` … `{DB}/3.pdb.txt` for `DB ∈ {TRAIT, STCRDab, TCR3d, ATLAS, IEDB, VDJdb}` | the six notebooks | PDB ID lists at each filter level. |
| `{DB}/{DB}_hla.csv` for the same six databases | the six notebooks | Per-database PDB → HLA allele mappings. |
| `newpdb_name.txt` | user-provided | One PDB ID per line — the **target list** of structures to keep in the final output (may use uppercase names; they are lowercased for matching, with the original name preserved). |

### What it does, cell by cell

1. **Build the presence matrix** — reads `total.tsv`, builds `unique_pdb.csv`: one row per PDB, one column per database, value `o` (present) or `x` (absent).
2. **Species check** — flags PDBs from `unique_pdb.csv` that are annotated as **mouse** in `STCRDab/pdb.csv` (`suspect_pdb_df`), so you can review/remove non-human structures.
3. **Drop duplicates across databases** — merges the PDB-ID lists of all six databases at each filter level into a single de-duplicated set, writing `drop_duplicates/0.pdb.txt`, `1.pdb.txt`, `2.pdb.txt`, `3.pdb.txt` (the union of all databases at that level).
4. **Extract HLA using PDB** — concatenates all six `{DB}_hla.csv` files (outer join on the PDB index) into one `hla_df` table: every PDB row × every database's allele columns.
5. **Map to the target PDB list** — reads `newpdb_name.txt` as the target structures, builds `target_df` indexed by **lowercase** PDB IDs (with the original case kept in a `RAW_PDB` column), and fills in the known HLA allele values from `hla_df` wherever the target PDB is found.
6. **Final output** — `target_df.to_csv('hla.csv')` writes the consolidated **PDB → HLA allele** table for the target structures.

### Outputs

- `unique_pdb.csv` — PDB × database presence matrix (`o`/`x`).
- `drop_duplicates/0.pdb.txt` … `drop_duplicates/3.pdb.txt` — cross-database de-duplicated PDB lists per filter level.
- `hla.csv` — **final combined PDB → HLA mapping** for the target PDBs (`RAW_PDB` column holds the original casing).

---

## 4. Dependencies

- **Python 3** (notebooks run on the `python3` ipykernel, nbformat 4).
- **pandas** — used by every notebook (data loading/cleaning).
- **openpyxl** — required to read `.xlsx` inputs (`ATLAS.xlsx`, `Interactive_TCR-pMHC_Pairs.xlsx`).
- **requests** + **beautifulsoup4** — required only by `STCRDab.ipynb` (scraping the STCRDab Browser page).
- **System tools (optional, only for the commented download cells):** `wget` and `unzip` (`mkdir` for output folders).

```bash
pip install pandas openpyxl requests beautifulsoup4
# optional download helpers
brew install wget unzip        # macOS
apt-get install wget unzip     # Debian/Ubuntu
```

## 5. How to run

1. Clone/copy this repo and make sure the folder structure is present (`ATLAS/`, `TCR3d/`, `TRAIT/`, `VDJdb/`, `STCRDab/`, `IEDB/`, `drop_duplicates/`).
2. Download the raw data for each database (uncomment the `wget`/`unzip` cell in each notebook, or download manually per the URLs in Section 2).
3. Open each notebook in **Jupyter** (`jupyter notebook` or VS Code) and run the cells top to bottom, in this order:
   1. `ATLAS.ipynb` → `TCR3d.ipynb` → `TRAIT.ipynb` → `VDJdb.ipynb` → `STCRDab.ipynb` → `IEDB.ipynb` (any order works; each is independent).
   2. `combine.ipynb` **last** — it needs the outputs of all six plus `total.tsv` and `newpdb_name.txt`.
4. Alternatively, execute a notebook headlessly:

```bash
jupyter nbconvert --to notebook --execute --inplace ATLAS.ipynb
```

## 6. Resulting directory layout (summary)

```
ATLAS/       ATLAS.xlsx, 0-3.pdb.txt, ATLAS_pdb.csv, ATLAS_hla.csv
TCR3d/       TCR3d_raw.tsv, 0-3.pdb.txt, TCR3d_pdb.csv, TCR3d_hla.csv
TRAIT/       Interactive_TCR-pMHC_Pairs.xlsx, TRAIT_raw.csv, 0-3.pdb.txt, TRAIT_pdb.csv, TRAIT_hla.csv
VDJdb/       vdjdb-2025-02-21/, 0-3.pdb.txt, VDJdb_pdb.csv, VDJdb_hla.csv
STCRDab/     STCRDab_raw.tsv, 0-3.pdb.txt, STCRDab_pdb.csv, STCRDab_hla.csv, pdb.csv
IEDB/        tcell_full_v3.csv, 0-3.pdb.txt, IEDB_pdb.csv, IEDB_hla.csv
drop_duplicates/   0-3.pdb.txt        (written by combine.ipynb)
unique_pdb.csv      (written by combine.ipynb)
hla.csv             (written by combine.ipynb — final PDB → HLA table)
```
