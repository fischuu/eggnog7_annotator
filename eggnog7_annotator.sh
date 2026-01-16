#!/usr/bin/env bash
set -euo pipefail

############################################
# Defaults
############################################
EVALUE="1e-5"
THREADS=1
OUTDIR="."
KEEP_DIAMOND=0
VERSION="0.1"

############################################
# Help & version
############################################
usage() {
cat << EOF
Usage:
  $(basename "$0") [OPTIONS]

Required arguments:
  -d FILE   Diamond database (.dmnd)
  -q FILE   Protein FASTA file (Prodigal AA output)
  -m FILE   EggNOG master search table (.tsv.gz)
  -s NAME   Sample name / prefix (e.g. ERR2019356)

Optional arguments:
  -o DIR    Output directory (default: current directory)
  -e FLOAT  E-value threshold for Diamond (default: 1e-5)
  -p INT    Number of threads (default: 1)
  --keep-diamond
            Keep intermediate Diamond TSV file
  -v, --version
            Print version information and exit
  -h        Show this help message and exit

Output files:
  <outdir>/<sample>.diamond.tsv
  <outdir>/<sample>.eggnog.tsv.gz

Example:
  $(basename "$0") \\
    -d eggnog7_20251223_proteins.dmnd \\
    -q ERR2019356.prodigal.fa \\
    -m eggnog7_20251223_master_search_table.tsv.gz \\
    -s ERR2019356 \\
    -o results \\
    -p 16

EOF
}

version() {
    echo "$(basename "$0") version ${VERSION}"
}

############################################
# Argument parsing
############################################
OPTS=$(getopt -o d:q:m:s:o:e:p:hv -l keep-diamond,version -n "$(basename "$0")" -- "$@")
if [ $? != 0 ]; then
    usage
    exit 1
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -d) DIAMOND_DB="$2"; shift 2 ;;
        -q) QUERY_FASTA="$2"; shift 2 ;;
        -m) MASTER_TABLE="$2"; shift 2 ;;
        -s) SAMPLE="$2"; shift 2 ;;
        -o) OUTDIR="$2"; shift 2 ;;
        -e) EVALUE="$2"; shift 2 ;;
        -p) THREADS="$2"; shift 2 ;;
        --keep-diamond) KEEP_DIAMOND=1; shift ;;
        -v|--version) version; exit 0 ;;
        -h) usage; exit 0 ;;
        --) shift; break ;;
        *) echo "Unknown option $1"; usage; exit 1 ;;
    esac
done

############################################
# Checks
############################################
for var in DIAMOND_DB QUERY_FASTA MASTER_TABLE SAMPLE; do
    if [ -z "${!var:-}" ]; then
        echo "ERROR: Missing required argument: $var" >&2
        usage
        exit 1
    fi
done

for f in "$DIAMOND_DB" "$QUERY_FASTA" "$MASTER_TABLE"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: File not found: $f" >&2
        exit 1
    fi
done

command -v diamond >/dev/null 2>&1 || {
    echo "ERROR: diamond not found in PATH" >&2
    exit 1
}

command -v awk >/dev/null 2>&1 || {
    echo "ERROR: awk not found in PATH" >&2
    exit 1
}

command -v gzip >/dev/null 2>&1 || {
    echo "ERROR: gzip not found in PATH" >&2
    exit 1
}

mkdir -p "$OUTDIR"

############################################
# File names
############################################
DIAMOND_OUT="${OUTDIR}/${SAMPLE}.diamond.tsv"
EGGNOG_OUT="${OUTDIR}/${SAMPLE}.eggnog.tsv.gz"

############################################
# Summary
############################################
echo "========================================"
echo "Script version: $VERSION"
echo "Sample:         $SAMPLE"
echo "Diamond DB:     $DIAMOND_DB"
echo "Query FASTA:    $QUERY_FASTA"
echo "Master table:   $MASTER_TABLE"
echo "Threads:        $THREADS"
echo "E-value:        $EVALUE"
echo "Output dir:     $OUTDIR"
echo "========================================"

############################################
# Step 1: Diamond blastp
############################################
echo "[1/2] Running Diamond blastp..."
diamond blastp \
    -d "$DIAMOND_DB" \
    -q "$QUERY_FASTA" \
    -o "$DIAMOND_OUT" \
    --outfmt 6 \
    --max-target-seqs 1 \
    --evalue "$EVALUE" \
    -p "$THREADS"

############################################
# Step 2: Merge with EggNOG master table
############################################
echo "[2/2] Merging Diamond output with EggNOG annotations..."

awk -F'\t' -v OFS='\t' '
NR==FNR {
    prot[$6] = $0
    next
}
{
    key = $2
    if (key in prot) {
        print $1, $2, $3, $4, $11, $12, prot[key]
    } else {
        print $1, $2, $3, $4, $11, $12, "NA"
    }
}
' <(zcat "$MASTER_TABLE") "$DIAMOND_OUT" | gzip > "$EGGNOG_OUT"

############################################
# Cleanup
############################################
if [ "$KEEP_DIAMOND" -eq 0 ]; then
    rm -f "$DIAMOND_OUT"
fi

echo "Done."
echo "Final output: $EGGNOG_OUT"
