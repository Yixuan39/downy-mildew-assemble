#!/bin/env python

import os
import subprocess
import argparse
import shutil
import pandas as pd

def compleasm(input_file, output_dir, threads, library_path, linkage):
    output_dir = os.path.join(output_dir, linkage)
    os.makedirs(output_dir, exist_ok=True)
    cmd = 'compleasm run \
           --assembly_path {} \
           --output_dir {} \
           --threads {} \
           --library_path {} \
           --lineage {}'.format(input_file, output_dir, threads, library_path, linkage)
    subprocess.call(cmd, shell=True)
    # read in the output
    output_file = os.path.join(output_dir, 'summary.txt')
    df = pd.read_csv(output_file, sep=',', index_col=False, skiprows=1, header=None)
    column1 = df.iloc[:, 0]
    split_column = column1.str.split(':', n=2)
    new_df = pd.DataFrame()
    new_df['Metric'] = split_column.str[0]
    new_df['Value'] = split_column.str[1]
    # add a new row for linkage
    new_df.loc[-1] = ['Linkage', linkage]
    shutil.rmtree(output_dir, ignore_errors=False)
    return new_df

def quast(input_file, output_dir, threads):
    output_dir = os.path.join(output_dir, 'quast')
    os.makedirs(output_dir, exist_ok=True)
    cmd = 'quast \
           --output-dir {} \
           --threads {} \
           --eukaryote \
           {}'.format(output_dir, threads, input_file)
    subprocess.call(cmd, shell=True)
    # read in the output
    output_file = os.path.join(output_dir, 'report.tsv')
    df = pd.read_csv(output_file, sep='\t')
    df.columns = ['Metric', 'Value']
    shutil.rmtree(output_dir, ignore_errors=False)
    return df
  
if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Quality check')
    parser.add_argument('--input_file', help='Input file in fasta format')
    parser.add_argument('--output_dir', help='Output directory')
    parser.add_argument('--threads', help='Number of threads', type=int, default=24)
    parser.add_argument('--library_path', help='path to compleasm library', default='$HOME/project_data/downy/BUSCO_DB')
    args = parser.parse_args()
    compleasm_euk = compleasm(args.input_file, args.output_dir, args.threads, args.library_path, 'eukaryota_odb10')
    compleasm_stram = compleasm(args.input_file, args.output_dir, args.threads, args.library_path, 'stramenopiles_odb10')
    quast_output = quast(args.input_file, args.output_dir, args.threads)
    
    # combine compleasm and quast result
    compleasm_euk = pd.concat([compleasm_euk, quast_output], axis=0).reset_index(drop=True)
    compleasm_stram = pd.concat([compleasm_stram, quast_output], axis=0).reset_index(drop=True)
    
    # save output as csv
    compleasm_euk.to_csv(os.path.join(args.output_dir, 'compleasm_euk.csv'), index=False)
    compleasm_stram.to_csv(os.path.join(args.output_dir, 'compleasm_stram.csv'), index=False)

    
    
