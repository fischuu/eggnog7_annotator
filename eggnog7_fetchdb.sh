#!/usr/bin/env bash

set -euo pipefail

# =========================
# Configuration
# =========================
BASE_URL="https://a3s.fi/eggnog7_annotator"
DATE_TAG="20251223"

MASTER_TABLE="eggnog7_${DATE_TAG}_master_search_table.tsv.gz"
PROTEIN_DB="eggnog7_${DATE_TAG}_proteins.dmnd"

FILES=(
  "${MASTER_TABLE}"
  "${MASTER_TABLE}.md5"
  "${PROTEIN_DB}"
  "${PROTEIN_DB}.md5"
)

# =========================
# Functions
# =========================
log() {
  echo "[eggnog7_fetchdb] $*"
}

error_exit() {
  echo "[eggnog7_fetchdb][ERROR] $*" >&2
  exit 1
}

# =========================
# Main
# =========================
log "Starting EggNOG v7 database download"
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
