#!/bin/bash
#SBATCH -c 32
#SBATCH --mem=0
#SBATCH --output=blast_hifiasm_blast_%j.out

total_start=$EPOCHREALTIME
echo "BLAST-HIFIASM-BLAST pipeline started: $(date)"

mkdir -p $HOME/project_data/downy/benchmarking/blast_hifiasm_blast

# Convert fastq to fasta
start=$EPOCHREALTIME
seqkit fq2fa \
  --threads 32 \
  --out-file $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa_reads.fasta \
  $HOME/project_data/downy/p_effusa/filtered/p_effusa.fastq.gz 
runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "FASTQ conversion: $runtime seconds"

# BLAST reads
start=$EPOCHREALTIME
blastn -query $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa_reads.fasta \
  -db nt \
  -outfmt "6 qseqid sseqid pident length qlen slen evalue staxids" \
  -max_target_seqs 1 \
  -max_hsps 1 \
  -evalue 1e-10 \
  -perc_identity 95 \
  -num_threads 32 \
  -out $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/reads_blast.tsv
runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "Read BLAST: $runtime seconds"

# Filter oomycete reads
start=$EPOCHREALTIME
awk -F'\t' -v pat="$pattern" '$8 ~ pat {print $1}' \
    $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/reads_blast.tsv \
    > $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/oomycete_reads.txt

seqkit grep -f $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/oomycete_reads.txt \
  $HOME/project_data/downy/p_effusa/filtered/p_effusa.fastq.gz \
  --threads 32 \
  -o $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa_oomycete_reads.fastq.gz
runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "Read filtering: $runtime seconds"

# Assemble
start=$EPOCHREALTIME
hifiasm \
    -t 32 \
    -l 2 \
    --primary \
    -o $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa \
    $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa_oomycete_reads.fastq.gz
runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "Assembly: $runtime seconds"

# Convert to fasta and filter ≥5kb
# gfatools gfa2fa \
#     $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa.p_ctg.gfa \
# | seqkit seq -m 5000 --threads 32 \
# > $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa_contigs.fasta

gfatools gfa2fa \
    $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa.p_ctg.gfa \
> $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa_contigs.fasta

# BLAST contigs
start=$EPOCHREALTIME
blastn -query $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa_contigs.fasta \
  -db nt \
  -outfmt "6 qseqid sseqid pident length qlen slen evalue staxids" \
  -max_target_seqs 1 \
  -max_hsps 1 \
  -evalue 1e-10 \
  -perc_identity 95 \
  -num_threads 32 \
  -out $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/contigs_blast.tsv
runtime=$(echo "$EPOCHREALTIME - $start" | bc -l)
echo "Contig BLAST: $runtime seconds"

# Filter for oomycete contigs
awk -F'\t' -v pat="$pattern" '$8 ~ pat {print $1}' \
    $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/contigs_blast.tsv \
    > $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/oomycete_contigs.txt

seqkit grep -f $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/oomycete_contigs.txt \
  $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa_contigs.fasta \
  --threads 32 \
| gzip > $HOME/project_data/downy/benchmarking/blast_hifiasm_blast/p_effusa.fasta.gz

total_runtime=$(echo "$EPOCHREALTIME - $total_start" | bc -l)
echo "Pipeline completed: $(date)"
echo "Total runtime: $total_runtime seconds"