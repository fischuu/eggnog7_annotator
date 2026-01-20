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

My suggestion is to clone it via git and then add the path to your PATH variable to have the commands system-wide available like this

```
# Go to home folder
cd

# Change to the git repos
mkdir -p git
cd git

# clone it to the folder
git clone https://github.com/fischuu/eggnog7_annotator.git

# Export it to make the command system-wide available
export PATH="/users/fischerd/git/eggnog7_annotator:$PATH"
```

(Obviously, you need to adjust the first path `/users/fischerd/` to the folder to where you cloned repository)

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

# Optional: test data
wget https://a3s.fi/eggnog7_annotator/test.fa
wget https://a3s.fi/eggnog7_annotator/test.fa.md5
md5sum -c test.fa.md5
```

### Download via wrapper
```
cd /path/where/the/databases/should/be/fetched
eggnog7_fetchdb.sh
```

# Usage

The script performs a **two-step annotation** workflow:

1. **Run `diamond blastp`** of a protein FASTA against the EggNOG 7 database.
2. **Merge Diamond hits with a EggNOG master table** to produce a combined annotation file.

All outputs are organized using a **sample prefix** and an **output directory**.

---

## Basic usage

```bash
./eggnog7_annotator.sh [OPTIONS]
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
./eggnog7_annotator.sh \
  -d eggnog7_20251223_proteins.dmnd \
  -q test.fa \
  -m eggnog7_20251223_master_search_table.tsv.gz \
  -s test \
  -o results \
  -p 16
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
* I am not affiliated to the eggNOG project, I just wrote this convenience wrapper for my own usage and share it

If you are searching a worry-free MetaG snakemake pipeline, please have a look at

https://github.com/fischuu/Pipeline-Holoruminant-Meta
