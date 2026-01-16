#!/usr/bin/env bash
set -euo pipefail

############################################
# Defaults / configuration
############################################
BASE_URL="https://a3s.fi/eggnog7_annotator"
DATE_TAG="20251223"
VERSION="0.1"

MASTER_TABLE="eggnog7_${DATE_TAG}_master_search_table.tsv.gz"
PROTEIN_DB="eggnog7_${DATE_TAG}_proteins.dmnd"

FILES=(
  "${MASTER_TABLE}"
  "${MASTER_TABLE}.md5"
  "${PROTEIN_DB}"
  "${PROTEIN_DB}.md5"
)

############################################
# Help & version
############################################
usage() {
cat << EOF
Usage:
  $(basename "$0") [OPTIONS]

Options:
  -v, --version
            Print version information and exit
  -h        Show this help message and exit

This script downloads the EggNOG v7 Diamond database and
master search table and verifies their MD5 checksums.

Files downloaded:
  ${MASTER_TABLE}
  ${PROTEIN_DB}

Source:
  ${BASE_URL}

EOF
}

version() {
    echo "$(basename "$0") version ${VERSION}"
}

############################################
# Functions
############################################
log() {
  echo "[eggnog7_fetchdb] $*"
}

error_exit() {
  echo "[eggnog7_fetchdb][ERROR] $*" >&2
  exit 1
}

############################################
# Argument parsing
############################################
OPTS=$(getopt -o hv -l help,version -n "$(basename "$0")" -- "$@")
if [ $? != 0 ]; then
    usage
    exit 1
fi
eval set -- "$OPTS"

while true; do
    case "$1" in
        -v|--version) version; exit 0 ;;
        -h|--help) usage; exit 0 ;;
        --) shift; break ;;
        *) usage; exit 1 ;;
    esac
done

############################################
# Main
############################################
log "Starting EggNOG v7 database download"
log "Script version: ${VERSION}"
log "Base URL: ${BASE_URL}"
log "Date tag: ${DATE_TAG}"
echo

# Download files
for f in "${FILES[@]}"; do
  if [[ -f "${f}" ]]; then
    log "File already exists, skipping: ${f}"
  else
    log "Downloading: ${f}"
    wget -q --show-progress "${BASE_URL}/${f}" \
      || error_exit "Failed to download ${f}"
  fi
done

echo
log "All files downloaded successfully"
echo

# Verify checksums
log "Verifying MD5 checksums"

md5sum -c "${MASTER_TABLE}.md5" \
  || error_exit "MD5 check failed for ${MASTER_TABLE}"

md5sum -c "${PROTEIN_DB}.md5" \
  || error_exit "MD5 check failed for ${PROTEIN_DB}"

echo
log "MD5 verification successful"
log "EggNOG v7 database is ready to use 🎉"
