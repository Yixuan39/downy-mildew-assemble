#!/bin/env python

# ----------------------------------------------------------------------------------------
# Purpose : Run compleasm (stramenopiles) and QUAST on one FASTA and write the merged metrics as
#           quality.csv. Helper for ref-genome-quality.sh; not run directly.
# Inputs  : one genome FASTA, a compleasm library path, a thread count
# Outputs : <output_dir>/quality.csv
# Runs on : inside the same job as ref-genome-quality.sh
# Usage   : python workflow/05-assembly-qc/quality-check.py --help
# ----------------------------------------------------------------------------------------

import os
import subprocess
import argparse
import shutil
import pandas as pd
import tempfile

def compleasm(input_file, temp_dir, threads, library_path, linkage):
    output_dir = os.path.join(temp_dir, linkage)
    os.makedirs(output_dir, exist_ok=True)
    cmd = f'compleasm run --assembly_path {input_file} --output_dir {output_dir} --threads {threads} --library_path {library_path} --lineage {linkage}'
    subprocess.call(cmd, shell=True)
    output_file = os.path.join(output_dir, 'summary.txt')
    df = pd.read_csv(output_file, sep=',', index_col=False, skiprows=1, header=None)
    column1 = df.iloc[:, 0]
    split_column = column1.str.split(':', n=2)
    new_df = pd.DataFrame()
    new_df['Metric'] = split_column.str[0]
    new_df['Value'] = split_column.str[1]
    new_df = new_df.set_index('Metric').T
    # new_df['Linkage'] = linkage
    shutil.rmtree(output_dir, ignore_errors=False)
    return new_df

def quast(input_file, temp_dir, threads):
    output_dir = os.path.join(temp_dir, 'quast')
    os.makedirs(output_dir, exist_ok=True)
    cmd = f'quast --output-dir {output_dir} --threads {threads} --eukaryote {input_file}'
    subprocess.call(cmd, shell=True)
    output_file = os.path.join(output_dir, 'report.tsv')
    df = pd.read_csv(output_file, sep='\t')
    df.columns = ['Metric', 'Value']
    df = df.set_index('Metric').T
    shutil.rmtree(output_dir, ignore_errors=False)
    return df

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Quality check with temp storage')
    parser.add_argument('--input_file', help='Input file in fasta format')
    parser.add_argument('--output_dir', help='Output directory')
    parser.add_argument('--threads', help='Number of threads', type=int, default=24)
    parser.add_argument('--library_path', help='Path to compleasm library', default=os.path.expandvars('$HOME/db/compleasm'))
    args = parser.parse_args()

    if not os.path.exists(args.input_file):
        raise FileNotFoundError('Input file does not exist')

    temp_dir = tempfile.mkdtemp(prefix="qualitycheck_temp_")
    print(f"Storing intermediate files in: {temp_dir}")

    compleasm_stram = compleasm(args.input_file, temp_dir, args.threads, args.library_path, 'stramenopiles')
    quast_output = quast(args.input_file, temp_dir, args.threads)

    compleasm_stram = pd.concat([compleasm_stram, quast_output], axis=1)

    os.makedirs(args.output_dir, exist_ok=True)
    compleasm_stram.to_csv(os.path.join(args.output_dir, 'quality.csv'), index=False)

    shutil.rmtree(temp_dir, ignore_errors=False)
    print(f"Cleaned up temporary directory: {temp_dir}")
