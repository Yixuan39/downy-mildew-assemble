#!/bin/python

import argparse
from Bio import SeqIO

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Get sequence from FASTA file')
    parser.add_argument('action', help='Action to perform', choices=['extract', 'remove'])
    parser.add_argument('input_file', help='Input file in FASTA format')
    parser.add_argument('sequence_id', help='Sequence ID', type=str)
    parser.add_argument('output_file', help='Output file in FASTA format')
    args = parser.parse_args()
    # read in sequence ID txt file
    with open(args.sequence_id, 'r') as f:
        seq_id = f.read().strip()
    # remove duplicated sequence id
    seq_id = list(set(seq_id.split('\n')))

    # read input file
    records = SeqIO.parse(args.input_file, 'fasta')
    if args.action == 'extract':
        # extract sequence
        keep = [record for record in records if record.id in seq_id]
    elif args.action == 'remove':
        # remove sequence
        keep = [record for record in records if record.id not in seq_id]
    # write output file
    SeqIO.write(keep, args.output_file, 'fasta')
