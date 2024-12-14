#!/bin/python3

import os
import FastaValidator
import argparse
import glob
import subprocess

from FastaValidator import fasta_validator

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='combine fasta files to a single file')
    parser.add_argument('input_folder', help='Input file in FASTA format')
    parser.add_argument('output_file', help='Output file in FASTA format')
    args = parser.parse_args()

    # list fasta files in folder
    files = glob.glob(args.input_folder + '/*', recursive=True)
    #files = [file for file in files if FastaValidator.fasta_validator(file)]

    print('Combining fasta files:', files)
    os.makedirs(os.path.dirname(args.output_file), exist_ok=True)
    # combine fasta files
    subprocess.run(['cat'] + files, stdout=open(args.output_file, 'w'))
    # compress output file
    subprocess.run(['gzip', args.output_file])