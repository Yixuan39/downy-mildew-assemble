#!/bin/bash
#SBATCH --cpus-per-task=32

# seqkit fx2tab \
#     $HOME/project_data/downy/GSL_Data/fastq/Quesada_SQIIe_MSU1.fastq.gz \
#     -n -l -j 32 \
#     -o $HOME/project_data/downy/GSL_Data/length/MSU1.tsv.gz
#     
# seqkit fx2tab \
#     $HOME/project_data/downy/GSL_Data/fastq/Quesada_SQIIe_Phumuli.fastq.gz \
#     -n -l -j 32 \
#     -o $HOME/project_data/downy/GSL_Data/length/Phumuli.tsv.gz
# 
# seqkit fx2tab \
#     $HOME/project_data/downy/GSL_Data/fastq/Quesada_SQIIe_SC1982.fastq.gz \
#     -n -l -j 32 \
#     -o $HOME/project_data/downy/GSL_Data/length/SC1982.tsv.gz
    
# count contig length
# FCS
seqkit fx2tab \
    $HOME/project_data/downy/result/asm-kraken2-fcs/oomycota-genomic/0.5/Quesada_SQIIe_MSU1.fcs.fasta.gz \
    -n -l -j 32 \
    -o $HOME/project_data/downy/GSL_Data/length/fcs/MSU1.tsv.gz
    
seqkit fx2tab \
    $HOME/project_data/downy/result/asm-kraken2-fcs/oomycota-genomic/0.5/Quesada_SQIIe_Phumuli.fcs.fasta.gz \
    -n -l -j 32 \
    -o $HOME/project_data/downy/GSL_Data/length/fcs/Phumuli.tsv.gz
    
seqkit fx2tab \
    $HOME/project_data/downy/result/asm-kraken2-fcs/oomycota-genomic/0.5/Quesada_SQIIe_SC1982.fcs.fasta.gz \
    -n -l -j 32 \
    -o $HOME/project_data/downy/GSL_Data/length/fcs/SC1982.tsv.gz
    
# FCS->Kraken2
seqkit fx2tab \
    $HOME/project_data/downy/result/asm-kraken2-fcs/oomycota-genomic/0.5/Quesada_SQIIe_MSU1.kraken.fasta.gz \
    -n -l -j 32 \
    -o $HOME/project_data/downy/GSL_Data/length/kraken/MSU1.tsv.gz
    
seqkit fx2tab \
    $HOME/project_data/downy/result/asm-kraken2-fcs/oomycota-genomic/0.5/Quesada_SQIIe_Phumuli.kraken.fasta.gz \
    -n -l -j 32 \
    -o $HOME/project_data/downy/GSL_Data/length/kraken/Phumuli.tsv.gz
    
seqkit fx2tab \
    $HOME/project_data/downy/result/asm-kraken2-fcs/oomycota-genomic/0.5/Quesada_SQIIe_SC1982.kraken.fasta.gz \
    -n -l -j 32 \
    -o $HOME/project_data/downy/GSL_Data/length/kraken/SC1982.tsv.gz