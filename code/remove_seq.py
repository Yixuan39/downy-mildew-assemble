#!/bin/python

import argparse
from Bio import SeqIO

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Remove sequence from FASTA file')
    parser.add_argument('input_file', help='Input file in FASTA format')
    parser.add_argument('sequence_id', help='Sequence ID to remove', type=str)
    parser.add_argument('output_file', help='Output file in FASTA format')
    args = parser.parse_args()
    # read in sequence ID txt file
    with open(args.sequence_id, 'r') as f:
        seq_id = f.read().strip()
    # read input file
    records = Bio.SeqIO.parse(args.input_file, 'fasta')
    # remove sequence
    keep = [record for record in records if record.id != seq_id]
    # write output file
    Bio.SeqIO.write(keep, args.output_file, 'fasta')