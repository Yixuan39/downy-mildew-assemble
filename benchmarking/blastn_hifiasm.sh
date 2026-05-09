#!/bin/bash
#SBATCH -c 32
#SBATCH --mem=0
#SBATCH --output=blast_hifiasm_%j.out

total_start=$EPOCHREALTIME
echo "BLAST-HIFIASM pipeline started: $(date)"

mkdir -p $HOME/project_data/downy/benchmarking/blast_hifiasm

# Convert fastq to fasta
start=$EPOCHREALTIME
seqkit fq2fa \
  --threads 32 \
  --out-file $HOME/project_data/downy/benchmarking/blast_hifiasm/p_effusa_reads.fasta \
  $HOME/project_data/downy/p_effusa/filtered/p_effusa.fastq.gz 
runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "FASTQ conversion: $runtime seconds"

# BLAST reads
start=$EPOCHREALTIME
blastn -query $HOME/project_data/downy/benchmarking/blast_hifiasm/p_effusa_reads.fasta \
  -db nt \
  -outfmt "6 qseqid sseqid pident length qlen slen evalue staxids" \
  -max_target_seqs 1 \
  -max_hsps 1 \
  -evalue 1e-10 \
  -perc_identity 95 \
  -num_threads 32 \
  -out $HOME/project_data/downy/benchmarking/blast_hifiasm/p_effusa.tsv
runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "Read BLAST: $runtime seconds"

# Filter oomycete reads
start=$EPOCHREALTIME
awk -F'\t' -v pat="$pattern" '$8 ~ pat {print $1}' \
    $HOME/project_data/downy/benchmarking/blast_hifiasm/p_effusa.tsv \
    > $HOME/project_data/downy/benchmarking/blast_hifiasm/oomycetes_reads.txt

seqkit grep -f $HOME/project_data/downy/benchmarking/blast_hifiasm/oomycetes_reads.txt \
  $HOME/project_data/downy/p_effusa/filtered/p_effusa.fastq.gz \
  --threads 32 \
  -o $HOME/project_data/downy/benchmarking/blast_hifiasm/p_effusa_oomycetes.fastq.gz
runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "Read filtering: $runtime seconds"

# Assemble with hifiasm
start=$EPOCHREALTIME
hifiasm \
    -t 32 \
    -l 2 \
    --primary \
    -o $HOME/project_data/downy/benchmarking/blast_hifiasm/p_effusa \
    $HOME/project_data/downy/benchmarking/blast_hifiasm/p_effusa_oomycetes.fastq.gz
runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "Assembly: $runtime seconds"

# Convert to fasta with 5kb filter
# gfatools gfa2fa \
#     $HOME/project_data/downy/benchmarking/blast_hifiasm/p_effusa.p_ctg.gfa \
# | seqkit seq -m 5000 --threads 32 \
# | gzip > $HOME/project_data/downy/benchmarking/blast_hifiasm/p_effusa.fasta.gz

gfatools gfa2fa \
    $HOME/project_data/downy/benchmarking/blast_hifiasm/p_effusa.p_ctg.gfa \
| gzip > $HOME/project_data/downy/benchmarking/blast_hifiasm/p_effusa.fasta.gz

total_runtime=$(echo "$EPOCHREALTIME - $total_start" | bc -l)
echo "Pipeline completed: $(date)"
echo "Total runtime: $total_runtime seconds"