#!/bin/bash
#SBATCH --cpus-per-task=8

blastn -query $HOME/project_data/downy/oomycota-genome/Peronospora-effusa.fna \
  -subject "../data/KT072718.1.fna" \
  -outfmt "6 qseqid sseqid pident length qlen slen evalue staxids" \
  -max_target_seqs 1 \
  -max_hsps 1 \
  -num_threads 8 \
  -out $HOME/project_data/downy/oomycota-genome/Peronospora-effusa.tsv
  

