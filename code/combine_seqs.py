#!/bin/python3

import os
import argparse
import glob
import subprocess

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='combine fasta files to a single file')
    parser.add_argument('input_folder', help='Input file in FASTA format')
    parser.add_argument('output_file', help='Output file in FASTA format')
    args = parser.parse_args()

    # list fasta files in folder
    files = glob.glob(args.input_folder + '/**/*', recursive=True)
    print('remove directories from list of files')
    files = [file for file in files if os.path.isfile(file)]
    print('avoid adding masked files to list of files')
    files = [file for file in files if not file.endswith('.masked')]
    print('validating fasta files...')
    files = [file for file in files if 'fna' in file or 'faa' in file]
    if len(files) == 0:
        print('No fasta files found in:', args.input_folder)
        exit(1)

    print('Combining fasta files:', files)
    os.makedirs(os.path.dirname(args.output_file), exist_ok=True)
    # combine fasta files
    subprocess.run(['cat'] + files, stdout=open(args.output_file, 'w'))