#!/bin/python3

import os
import subprocess
import argparse

class pacbio_cleaning:
    def __init__(self, input_file, output_file, ref_genome=None, threads=24):
        self.input_file = input_file
        self.output_file = output_file
        self.ref_genome = ref_genome
        self.threads = threads
        self.output_dir = os.path.dirname(self.output_file)
        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir, exist_ok=True)

    def check_blast_database(self):
        if not os.path.exists(self.ref_genome + '.dmnd'):
            print('Generating blast database...')
            command = ('diamond makedb --threads ' + str(self.threads) +
                       ' --in ' + self.ref_genome + ' -d ' + self.ref_genome)
            print(command)
            subprocess.run(command, shell=True)
        else:
            print('Blast database already exist.')

    def blast(self):
        self.check_blast_database()
        blast_out = self.output_file + '.tsv'
        tblastx = ('diamond blastx' +
                   ' --query ' + self.fasta_file +
                   ' --db ' + self.ref_genome +
                   ' --out ' + blast_out +
                   ' --outfmt 6' +
                   ' --max-hsps 1' +
                   ' --al ' + self.output_file +
                   ' --alfmt fasta' +
                   ' --evalue 1e-10' +
                   ' --threads ' + str(self.threads))

        print(tblastx)
        subprocess.run(str(tblastx), shell=True)

    def kraken2(self):
        kraken2 = ('kraken2 --db ' + self.ref_genome +
                   ' --output ' + self.output_file.replace('.fastq', '.tsv') +
                   ' --classified-out ' + self.output_file +
                   ' --threads ' + str(self.threads) +
                   #' --minimum-hit-groups 1' +
                   #' --report-minimizer-data' +
                   ' --report ' + self.output_file.replace('.fasta', '_report.txt') +
                   ' ' + self.fasta_file)
        print(kraken2)
        subprocess.run(str(kraken2), shell=True)

    def hifiasm(self):
        asm_dir = os.path.join(self.output_dir, os.path.basename(self.input_file) + '.hifiasm')
        file = os.path.basename(self.input_file).replace('.fastq', '.asm')
        os.makedirs(asm_dir, exist_ok=True)
        asm_out = os.path.join(asm_dir, file)
        command = ('hifiasm' +
                   ' -t ' + str(self.threads) +
                   ' -o ' + asm_out +
                   ' ' + self.input_file)
        subprocess.run(command, shell=True)
        assembly_result = asm_out + '.bp.p_ctg.gfa'
        self.fasta_file = assembly_result.replace('.gfa', '.fasta')
        # convert gfa to fasta
        gfa_fasta = ("""awk '/^S/{print ">"$2;print $3}' """ +
                     assembly_result + " > " +
                     self.fasta_file)
        subprocess.run(gfa_fasta, shell=True)

    def quast(self):
        sub_folder = os.path.basename(self.output_file).replace('.asm.bp.p_ctg.fasta', '.quast')
        output_folder = os.path.join(self.output_dir, sub_folder)
        command = ('quast.py ' +
                   ' -o ' + output_folder +
                   ' --threads ' + str(self.threads) +
                   ' --large ' +
                   ' ' + str(self.output_file))
        print(command)
        subprocess.run(command, shell=True)

    def busco(self):
        sub_folder = os.path.basename(self.output_file).replace('.asm.bp.p_ctg.fasta', '.busco')
        output_folder = os.path.join(self.output_dir, sub_folder)
        command = ('busco -i ' + str(self.output_file) +
                   ' --out ' + output_folder +
                   ' --mode genome ' +
                   ' --cpu ' + str(self.threads) +
                   ' --long ' +
                   ' --auto-lineage ' +
                   ' --offline ' +
                   ' --quiet ' +
                   ' --force ' +
                   ' --tar '  # compress some subdirectories
                   )
        print(command)
        subprocess.run(command, shell=True)

    def run(self, method='blast', asm=True):
        # assemble the pacbio reads first, then clean the assembly
        self.hifiasm()
        if method == 'blast':
            self.blast()
        elif method == 'kraken2':
            self.kraken2()
        else:
            assert FALSE, 'No method selected.'
        self.quast()
        self.busco()






if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='tblastx pacbio raw reads to reference genome')
    parser.add_argument('--input', required=True, help='pacbio raw reads file')
    parser.add_argument('--output', required=True, help='pacbio trimmed reads file')
    parser.add_argument('--ref', required=True, help='reference genome file')
    parser.add_argument('--threads', default=8, help='number of threads')
    parser.add_argument('--method', default='blast', help='blast or kraken2')
    args = parser.parse_args()
    pacbio_cleaning(args.input, args.output, args.ref, args.threads).run(args.method, args.asm)
