#!/usr/bin/env python3

import argparse
import re
from Bio import SeqIO

def rename_fasta_headers(input_fasta, output_fasta):
    with open(input_fasta) as infile, open(output_fasta, "w") as outfile:
        for record in SeqIO.parse(infile, "fasta"):
            match = re.search(r'\[locus_tag=([^\]]+)\]', record.description)
            if match:
                gene_id = match.group(1)
                record.id = gene_id
                record.description = ""
                SeqIO.write(record, outfile, "fasta")

def clean_headers(input_fasta, output_fasta):
    with open(input_fasta) as in_f, open(output_fasta, "w") as out_f:
        for record in SeqIO.parse(in_f, "fasta"):
            # Keep just the first word, split on whitespace
            header = record.id.split()[0]
            record.id = header
            record.description = ""
            SeqIO.write(record, out_f, "fasta")

def main():
    parser = argparse.ArgumentParser(description="Rename FASTA headers using locus_tag from NCBI protein FASTA.")
    parser.add_argument("-i", "--input", required=True, help="Input peptide FASTA")
    parser.add_argument("-o", "--output", required=True, help="Output renamed FASTA")
    parser.add_argument("--clean", action="store_true", help="Clean headers by keeping only the first word")
    args = parser.parse_args()
    rename_fasta_headers(args.input, args.output)

if __name__ == "__main__":
    main()
