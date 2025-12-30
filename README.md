# Human RNA-seq Snakemake Pipeline

**Description**
A lightweight Snakemake pipeline for processing human RNA-seq data: download (optional) → trimming → alignment → counting → QC & plotting. Designed to be configurable via `config.yaml` and to use reference files in `data/refs/` (FASTA, GTF, aligner indices).

---

## Quickstart 

1. Clone the repository

   ```bash
   git clone <repo-url>
   cd human_rnaseq_project
   ```

2. (Optional) Download example data

   ```bash
   bash scripts/download_data.sh
   ```

3. Check and edit configuration

   - Open `config.yaml` and set sample names, paths, and parameters as needed.

4. Dry-run the workflow

   ```bash
   snakemake -n
   ```

5. Run the pipeline

   - Without conda:

     ```bash
     snakemake --cores 8
     ```

   - With Snakemake-managed conda environments:

     ```bash
     snakemake --use-conda --cores 8
     ```

6. (Optional) Generate an HTML report

   ```bash
   snakemake --report pipeline_report.html
   ```

---

## Requirements & tools

- Snakemake
- Conda or mamba (optional, for `--use-conda`)
- Standard bioinformatics tools (trimmer, aligner, `featureCounts` or equivalent, FastQC, etc.). See `Snakefile` for exact tools and any environment YAML files.

---

## Repository layout

- `data/raw/` — raw FASTQ files (paired reads named consistently: `sample_R1.fastq.gz`, `sample_R2.fastq.gz`)
- `data/trimmed/` — trimmed reads (intermediate)
- `data/refs/` — reference FASTA, GTF, and aligner indices (e.g. `Homo_sapiens.GRCh38.dna.primary_assembly.fa`, `Homo_sapiens.GRCh38.110.gtf`, `genome_index.*.bt2`)
- `results/alignments/` — resulting BAM files
- `results/counts/` — gene/transcript count matrices
- `results/plots/` — QC and summary plots
- `results/qc/` — per-sample QC outputs and logs
- `scripts/` — helper scripts (e.g. `download_data.sh`)

---

## Adding samples

1. Add raw FASTQ(s) to `data/raw/` following the expected naming convention.
2. Update `config.yaml` if your `Snakefile` requires explicit listing of samples.
3. Run `snakemake -n` to confirm expected rules and targets.

---

## Troubleshooting & tips

- Use `snakemake -n` for a dry run and `snakemake -p` to print shell commands for debugging.
- Check per-rule log files in `results/` if a job fails.
- Re-run with `snakemake -k --cores 8` to keep going on non-fatal errors.

---

## Contributing & license

- Contributions: open an issue or submit a PR with a clear description and tests when applicable.
- License: MIT

---

## Contact

For questions, please open an issue. 

