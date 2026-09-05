#!/usr/bin/env python3
"""Small regression checks; run with python3 tests/check-workflow.py (requires seqkit and R)."""
import ast
import csv
import gzip
import importlib.util
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
for path in (ROOT / 'workflow').rglob('*.sh'):
    subprocess.run(['bash', '-n', str(path)], check=True)
for path in (ROOT / 'workflow').rglob('*.py'):
    ast.parse(path.read_text())

with tempfile.TemporaryDirectory(prefix='downy check ') as folder:
    tmp = Path(folder)
    env = {**os.environ, 'REPO_ROOT': str(ROOT), 'PROJECT_DATA': str(tmp)}
    # Test the real fixed-coordinate split, including ordering, identities, repeat runs and rejection.
    before = tmp / 'before.fasta.gz'
    after = tmp / 'after.fasta.gz'
    original = [('Pcub-SC1982_001', 'ACGT' * 100),
                ('Pcub-SC1982_002', 'A' * 4523546 + 'N' * 8381 + 'C' * 303827),
                ('Pcub-SC1982_003', 'TGCA' * 100)]
    with gzip.open(before, 'wt') as out:
        for name, seq in original:
            out.write(f'>{name}\n{seq}\n')
    command = ['bash', str(ROOT / 'workflow/05-assembly-qc/split-contigs.sh'), str(before), str(after)]
    subprocess.run(command, env=env, check=True, capture_output=True)
    def fasta(path):
        with gzip.open(path, 'rt') as handle:
            return [(part.split('\n', 1)[0], ''.join(part.split('\n')[1:]))
                    for part in handle.read().split('>')[1:]]
    expected = [original[0], ('Pcub-SC1982_002', 'A' * 4523546), original[2],
                ('Pcub-SC1982_004', 'C' * 303827)]
    assert fasta(after) == expected
    subprocess.run(command, env=env, check=True, capture_output=True)
    assert fasta(after) == expected
    bad = subprocess.run(command[:-2] + [str(after), str(tmp / 'bad.gz')], env=env, capture_output=True)
    assert bad.returncode and not (tmp / 'bad.gz').exists()
    # CSV path resolution preserves spaces, checks inputs, and rejects escapes without partial output.
    spec = importlib.util.spec_from_file_location('samplesheet', ROOT / 'workflow/08-rnaseq-support/prepare-samplesheet.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    reads = tmp / 'reads with spaces'
    reads.mkdir()
    for mate in ('R1', 'R2'):
        (reads / f'{mate}.fq.gz').write_bytes(b'test')
    sheet = tmp / 'in.csv'
    sheet.write_text('sample,fastq_1,fastq_2,strandedness\nS,reads with spaces/R1.fq.gz,reads with spaces/R2.fq.gz,auto\n')
    module.prepare(sheet, tmp / 'out.csv', tmp)
    with open(tmp / 'out.csv') as handle:
        row = next(csv.DictReader(handle))
    assert row['fastq_1'] == str((reads / 'R1.fq.gz').resolve())
    sheet.write_text(sheet.read_text().replace('reads with spaces/R1.fq.gz', '../outside.gz'))
    try:
        module.prepare(sheet, tmp / 'bad.csv', tmp)
    except ValueError:
        pass
    else:
        raise AssertionError('Escaping read path accepted')
    assert not (tmp / 'bad.csv').exists()
print('PASS: shell syntax, Python syntax, SC1982 split, RNA-seq paths')
