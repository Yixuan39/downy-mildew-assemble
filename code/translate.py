#!/bin/python3

import os
import argparse
import FastaValidator

def transeq(input_file, output_file):
    command = 'transeq -sequence ' + input_file + ' -outseq ' + output_file + ' -frame 6'
    os.system(command)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Translate DNA to protein')
    parser.add_argument('input_folder', help='Input file in FASTA format')
    parser.add_argument('output_folder', help='Output file in FASTA format')
    args = parser.parse_args()

    # list fasta files in folder
    files = os.listdir(args.input_folder)
    files = [file for file in files if FastaValidator.fasta_validator(os.path.join(args.input_folder, file)) == 0]
    os.makedirs(args.output_folder, exist_ok=True)
    for file in files:
        input_file = os.path.join(args.input_folder, file)
        output_file = os.path.join(args.output_folder, file)
        transeq(input_file, output_file)