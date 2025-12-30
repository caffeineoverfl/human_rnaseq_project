##########################################
# Paired-end RNA-seq pipeline (repo-root safe)
##########################################

import glob

# Config file
configfile: "config.yaml"

SAMPLES = config["samples"]
RAW_DIR = config["raw_data_dir"]        # "data/raw"
RESULTS_DIR = config["results_dir"]    # "results"
GTF = config["reference"]["annotation_gtf"]
THREADS = config.get("threads", 4)

# List all Bowtie2 index files for Snakemake input
GENOME_INDEX_FILES = glob.glob("refs/genome_index*")
GENOME_INDEX_BASENAME = "refs/genome_index"  # used by bowtie2 in shell

# -------------------------
# Rule all: final outputs
# -------------------------
rule all:
    input:
        expand(f"{RESULTS_DIR}/qc/{{sample}}_fastqc.html", sample=SAMPLES),
        expand(f"{RESULTS_DIR}/alignments/{{sample}}.sorted.bam", sample=SAMPLES),
        f"{RESULTS_DIR}/multiqc/multiqc_report.html",
        f"{RESULTS_DIR}/counts/gene_counts.tsv"

# -------------------------
# FASTQC
# -------------------------
rule fastqc:
    input:
        r1=f"{RAW_DIR}/{{sample}}_R1.fastq.gz",
        r2=f"{RAW_DIR}/{{sample}}_R2.fastq.gz"
    output:
        html=f"{RESULTS_DIR}/qc/{{sample}}_fastqc.html",
        zip=f"{RESULTS_DIR}/qc/{{sample}}_fastqc.zip"
    shell:
        """
        mkdir -p {RESULTS_DIR}/qc
        fastqc {input.r1} {input.r2} --outdir {RESULTS_DIR}/qc
        """

# -------------------------
# ALIGNMENT (Bowtie2)
# -------------------------
rule align:
    input:
        r1=f"{RAW_DIR}/{{sample}}_R1.fastq.gz",
        r2=f"{RAW_DIR}/{{sample}}_R2.fastq.gz",
        index=GENOME_INDEX_FILES   # Snakemake sees all index files
    output:
        bam=f"{RESULTS_DIR}/alignments/{{sample}}.bam"
    threads: THREADS
    shell:
        """
        mkdir -p {RESULTS_DIR}/alignments
        bowtie2 -x {GENOME_INDEX_BASENAME} -1 {input.r1} -2 {input.r2} \
            | samtools view -bS - > {output.bam}
        """

# -------------------------
# SORT BAM
# -------------------------
rule sort_bam:
    input:
        f"{RESULTS_DIR}/alignments/{{sample}}.bam"
    output:
        f"{RESULTS_DIR}/alignments/{{sample}}.sorted.bam"
    shell:
        """
        samtools sort -o {output} {input}
        samtools index {output}
        """

# -------------------------
# GENE COUNTS (featureCounts)
# -------------------------
rule count:
    input:
        bam=expand(f"{RESULTS_DIR}/alignments/{{sample}}.sorted.bam", sample=SAMPLES),
        gtf=GTF
    output:
        f"{RESULTS_DIR}/counts/gene_counts.tsv"
    shell:
        """
        mkdir -p {RESULTS_DIR}/counts
        featureCounts -T {THREADS} -a {input.gtf} -o {output} {input.bam}
        """

# -------------------------
# MULTIQC
# -------------------------
rule multiqc:
    input:
        expand(f"{RESULTS_DIR}/qc/{{sample}}_fastqc.zip", sample=SAMPLES)
    output:
        f"{RESULTS_DIR}/multiqc/multiqc_report.html"
    shell:
        """
        mkdir -p {RESULTS_DIR}/multiqc
        multiqc {RESULTS_DIR}/qc -o {RESULTS_DIR}/multiqc
        """
