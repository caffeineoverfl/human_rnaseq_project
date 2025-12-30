#!/bin/bash
# scripts/download_data.sh
# Downloads public RNA-seq FASTQ files and renames them for the Snakemake pipeline
# Run from the project root: bash scripts/download_data.sh

set -e  # Exit on error

# -----------------------------
# Paths
# -----------------------------
PROJECT_ROOT="$(dirname "$0")/.."   # parent of scripts/
RAW_DIR="${PROJECT_ROOT}/data/raw"
mkdir -p "${RAW_DIR}"

# -----------------------------
# Define samples and URLs
# -----------------------------
# Replace these with real ENA/SRA URLs for paired-end FASTQs
# Format: SAMPLE_NAME URL_R1 URL_R2
declare -A SAMPLES
SAMPLES=(
  ["control1"]="https://www.ebi.ac.uk/ena/browser/api/fasta/SRR1039508?download=true https://www.ebi.ac.uk/ena/browser/api/fasta/SRR1039508?download=true"
  ["control2"]="https://www.ebi.ac.uk/ena/browser/api/fasta/SRR1039509?download=true https://www.ebi.ac.uk/ena/browser/api/fasta/SRR1039509?download=true"
  ["treated1"]="https://www.ebi.ac.uk/ena/browser/api/fasta/SRR1039512?download=true https://www.ebi.ac.uk/ena/browser/api/fasta/SRR1039512?download=true"
  ["treated2"]="https://www.ebi.ac.uk/ena/browser/api/fasta/SRR1039513?download=true https://www.ebi.ac.uk/ena/browser/api/fasta/SRR1039513?download=true"
)

# -----------------------------
# Download and rename files
# -----------------------------
for SAMPLE in "${!SAMPLES[@]}"; do
    URLS=(${SAMPLES[$SAMPLE]})
    URL_R1=${URLS[0]}
    URL_R2=${URLS[1]}

    OUT_R1="${RAW_DIR}/${SAMPLE}_R1.fastq.gz"
    OUT_R2="${RAW_DIR}/${SAMPLE}_R2.fastq.gz"

    echo "Downloading ${SAMPLE} R1..."
    curl -L ${URL_R1} -o ${OUT_R1}

    echo "Downloading ${SAMPLE} R2..."
    curl -L ${URL_R2} -o ${OUT_R2}

    echo "Downloaded ${SAMPLE} -> ${OUT_R1}, ${OUT_R2}"
done

echo "All samples downloaded and renamed to ${RAW_DIR}/"
