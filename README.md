# EGGNOG Annotator

# Requirements

* Diamond 2.1.16

The annotator uses Diamond to search for matching proteins in the database. The file was created with Diamond v2.1.16. Currently, the software is not
bundled with it, so Diamond needs to be installed already on the system. There are no other requirements. Also, the tool has not been tested with other
versions of Diamond.

* Linux / Mac

The script makes mainly use of basic bash commands like awk and sed and consequently they need to be isntalled (as it is default on Linux and Mac)

# Installation

## Tool installation
Just download the `eggnog7_annotator.sh` script, either by cloning the entire repository or by direct download



## Fetching the databases

### Manual download

The eggnog annotator uses a master search table, which was created based on the database files provided by the eggnog project (https://eggnogdb.com) and
they can be downloaded directly from our server via `wget`

```
# The master search table
wget https://a3s.fi/eggnog7_annotator/eggnog7_20251223_master_search_table.tsv.gz
wget https://a3s.fi/eggnog7_annotator/eggnog7_20251223_master_search_table.tsv.gz.md5
md5sum -c eggnog7_20251223_master_search_table.tsv.gz.md5

# The protein search diamond database
wget https://a3s.fi/eggnog7_annotator/eggnog7_20251223_proteins.dmnd
wget https://a3s.fi/eggnog7_annotator/eggnog7_20251223_proteins.dmnd.md5
md5sum -c eggnog7_20251223_proteins.dmnd.md5
```

### Download via wrapper
<t.b.a.>

# Usage

The script performs a **two-step annotation** workflow:

1. **Run `diamond blastp`** of a protein FASTA against the EggNOG 7 database.
2. **Merge Diamond hits with a EggNOG master table** to produce a combined annotation file.

All outputs are organized using a **sample prefix** and an **output directory**.

---

## Basic usage

```bash
./run_diamond_eggnog.sh [OPTIONS]
```

### Required Arguments

| Option    | Description                                                         |
| --------- | ------------------------------------------------------------------- |
| `-d FILE` | Path to the Diamond database file (`.dmnd`) downloaded by the user. |
| `-q FILE` | Protein FASTA file (amino acid fasta, e.g. from Prodigal).                    |
| `-m FILE` | EggNOG master search table file (`.tsv.gz`).                        |
| `-s NAME` | Sample name / prefix used for output files (e.g., `test`).    |

### Optional Arguments

| Option           | Description                            | Default                 |
| ---------------- | -------------------------------------- | ----------------------- |
| `-o DIR`         | Output directory                       | `.` (current directory) |
| `-e FLOAT`       | E-value threshold for Diamond          | `1e-5`                  |
| `-p INT`         | Number of threads                      | `1`                     |
| `--keep-diamond` | Keep the intermediate Diamond TSV file | (not kept by default)   |
| `-h`             | Show this help message and exit        | -                       |

---

## Output Files

All output files are written to `<outdir>` and use the sample prefix `<sample>`:

| File                              | Description                                               |
| --------------------------------- | --------------------------------------------------------- |
| `<outdir>/<sample>.diamond.tsv`   | Raw Diamond BLASTP output (optional, deleted by default). |
| `<outdir>/<sample>.eggnog.tsv.gz` | Combined annotation file with EggNOG hits.                |

---

## Example

```bash
./run_diamond_eggnog.sh \
  -d /data/db/eggnog7_20251223_proteins.dmnd \
  -q test.fa \
  -m /data/db/eggnog7_20251223_master_search_table.tsv.gz \
  -s test \
  -o results \
  -p 1
```

After running, the final combined annotation is available at:

```
results/test.eggnog.tsv.gz
```

---

## Notes

* Make sure the Diamond database and EggNOG master table are **downloaded beforehand**.
* The script automatically **creates the output directory** if it does not exist.
* By default, the **intermediate Diamond TSV file is removed** to save space; use `--keep-diamond` to preserve it.
