#!/bin/python

import argparse
import pandas as pd
from Bio import SeqIO
import gzip
import os

# get_seq.py extract input.fasta reference_id.tsv 1e-5 output.fasta

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Get sequence from FASTA file')
    parser.add_argument('action', help='Action to perform', choices=['extract', 'remove'])
    parser.add_argument('input_file', help='Input file in FASTA or FASTQ format')
    parser.add_argument('reference_id_file', help='mmseq_result', type=str)
    parser.add_argument('evalue', help='e-value threshold', type=float)
    parser.add_argument('output_file', help='Output file in FASTA format', type=str)
    args = parser.parse_args()
    # make sure directory of output file exists
    output_dir = os.path.dirname(args.output_file)
    os.makedirs(output_dir, exist_ok=True)
    # read in sequence ID txt file
    seq_id = pd.read_csv(args.reference_id_file, sep='\t', header=0)
    sub_seq_id = seq_id[seq_id['evalue'] < args.evalue]
    final_id = sub_seq_id['query'].tolist()
    # remove if final_id duplicates
    final_id = list(set(final_id))

    # read input file
    with gzip.open(args.input_file, 'rt') as handle:
        if '.fastq' in args.input_file:
            records = SeqIO.parse(handle, 'fastq')
        if '.fasta' in args.input_file:
            records = SeqIO.parse(handle, 'fasta')
        
    if args.action == 'extract':
        # extract sequence
        keep = [record for record in records if record.id in final_id]
    elif args.action == 'remove':
        # remove sequence
        keep = [record for record in records if record.id not in final_id]
    # write output file
    if args.output_file.endswith('.gz'):
        with gzip.open(args.output_file, 'wt') as f:
            SeqIO.write(keep, f, 'fasta')
    else:
        SeqIO.write(keep, args.output_file, 'fasta')
