#!/bin/bash

mkdir -p $HOME/project_data/downy/coverage

minimap2 -ax map-hifi -t 32 \
$HOME/project_data/downy/cleaned_contigs/p_effusa/p_effusa.fasta.gz \
$HOME/project_data/downy/p_effusa/p_effusa.fastq.gz | \
samtools sort -@ 16 --write-index -o $HOME/project_data/downy/coverage/p_effusa.bam -

minimap2 -ax map-hifi -t 32 \
$HOME/project_data/downy/cleaned_contigs/Quesada_SQIIe_Phumuli/Quesada_SQIIe_Phumuli.fasta.gz \
$HOME/project_data/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_Phumuli.fastq.gz | \
samtools sort -@ 16 --write-index -o $HOME/project_data/downy/coverage/Quesada_SQIIe_Phumuli.bam -

minimap2 -ax map-hifi -t 32 \
$HOME/project_data/downy/cleaned_contigs/Quesada_SQIIe_MSU1/Quesada_SQIIe_MSU1.fasta.gz \
$HOME/project_data/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_MSU1.fastq.gz | \
samtools sort -@ 16 --write-index -o $HOME/project_data/downy/coverage/Quesada_SQIIe_MSU1.bam -

minimap2 -ax map-hifi -t 32 \
$HOME/project_data/downy/cleaned_contigs/Quesada_SQIIe_SC1982/Quesada_SQIIe_SC1982.fasta.gz \
$HOME/project_data/downy/GSL_Data/fastq/filtered/Quesada_SQIIe_SC1982.fastq.gz | \
samtools sort -@ 16 --write-index -o $HOME/project_data/downy/coverage/Quesada_SQIIe_SC1982.bam -