#!/usr/bin/env python3
"""Read-only audit of existing flagged BAMs; TSV goes to stdout, metadata to stderr.

Run on the cluster with --evidence-dir and --samtools, or locally with --self-test.
No remapping is performed. Coordinates internally are zero-based, half-open.
Purpose: Verify boundary/full-span support from existing primary alignments.
Inputs: spans.tsv, *.flagged.bam and indexes, *.percontig_aligned.tsv.
Outputs: TSV on stdout; long-contig depth benchmarks on stderr.
Runs on: NCSU BRC, one process; indexed queries of flagged regions only.
Usage: python3 audit-cigar-support.py --evidence-dir PATH --samtools PATH
"""
import argparse
import csv
import re
import statistics
import subprocess
import sys
from pathlib import Path


def parse_cigar(start, cigar):
    ops = re.findall(r"(\d+)([MIDNSHP=X])", cigar)
    if not ops or ''.join(n + op for n, op in ops) != cigar:
        raise ValueError(f"Invalid CIGAR: {cigar}")
    pos, blocks, gaps = start, [], []
    for n, op in ops:
        n = int(n)
        if n <= 0:
            raise ValueError(f"Invalid CIGAR length: {cigar}")
        if op in 'M=X':
            blocks.append((pos, pos + n))
        elif op in 'DN':
            gaps.append((pos, pos + n))
        if op in 'MDN=X':
            pos += n
    return pos, blocks, gaps


def support(start, end, blocks, gaps, lo, hi, flank=1000, max_gap=50):
    coordinate = start <= lo - flank and end >= hi + flank
    # Count aligned query bases, not reference-consuming deletions, in each flank.
    left = sum(max(0, min(b, lo) - a) for a, b in blocks if a < lo)
    right = sum(max(0, b - max(a, hi)) for a, b in blocks if b > hi)
    # Conservatively reject large D/N operations anywhere in the alignment.
    clean = not any(b - a >= max_gap for a, b in gaps)
    return coordinate, coordinate and left >= flank and right >= flank and clean


def self_test():
    def check(cigar, lo, hi, expected):
        end, blocks, gaps = parse_cigar(0, cigar)
        assert support(0, end, blocks, gaps, lo, hi) == expected
    check('3000M', 1000, 2000, (True, True))
    check('999M', 1000, 2000, (False, False))
    check('1000M1000D1000M', 1000, 2000, (True, False))
    check('1000M1000N1000M', 1000, 2000, (True, False))
    check('999M1D2000M', 1000, 2000, (True, False))
    check('100S1500M20I1500M100S', 1000, 2000, (True, True))
    check('1500=1X1499=', 1000, 2000, (True, True))
    try:
        parse_cigar(0, '10Mbad')
    except ValueError:
        pass
    else:
        raise AssertionError('Malformed CIGAR accepted')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--self-test', action='store_true')
    parser.add_argument('--evidence-dir', type=Path)
    parser.add_argument('--samtools', default='samtools')
    args = parser.parse_args()
    self_test()
    if args.self_test:
        print('CIGAR self-check passed')
        return
    if args.evidence_dir is None:
        parser.error('--evidence-dir is required')
    root = args.evidence_dir
    spans = list(csv.DictReader((root / 'spans.tsv').open(), delimiter='\t'))
    headers = {}
    writer = csv.writer(sys.stdout, delimiter='\t', lineterminator='\n')
    writer.writerow(['label', 'test', 'coordinate_mq20', 'aligned_flanks_no_DN_ge50_mq20'])
    for row in spans:
        if row['action'] == 'exclude':
            continue
        species, contig = row['species'], row['contig']
        bam = str(root / f'{species}.flagged.bam')
        if species not in headers:
            header = subprocess.check_output([args.samtools, 'view', '-H', bam], text=True)
            lengths = {}
            for line in header.splitlines():
                if line.startswith('@SQ\t'):
                    fields = dict(x.split(':', 1) for x in line.split('\t')[1:])
                    lengths[fields['SN']] = int(fields['LN'])
            headers[species] = lengths
            with (root / f'{species}.percontig_aligned.tsv').open() as f:
                aligned = {r['contig']: int(r['aligned_bp']) for r in csv.DictReader(f, delimiter='\t')}
            median = statistics.median(aligned.get(c, 0) / n for c, n in lengths.items())
            long_depths = [aligned.get(c, 0) / n for c, n in lengths.items() if n >= 100000]
            print(f'{species}: {len(lengths)} reference contigs; all-contig median={median:.4f}; '
                  f'long-contig (>=100 kb, n={len(long_depths)}) median={statistics.median(long_depths):.4f}', file=sys.stderr)
        lo, hi = int(row['start']) - 1, int(row['end'])
        assert 0 <= lo < hi <= headers[species][contig]
        # A boundary is a point between bases; the full region is [lo, hi).
        tests = [('left', lo, lo), ('right', hi, hi), ('full', lo, hi)]
        counts = {name: [set(), set()] for name, _, _ in tests}
        proc = subprocess.Popen([args.samtools, 'view', '-F', '2308', bam,
                                 f'{contig}:{lo + 1}-{hi}'], stdout=subprocess.PIPE, text=True)
        for line in proc.stdout:
            fields = line.rstrip('\n').split('\t')
            if int(fields[4]) < 20:
                continue
            start = int(fields[3]) - 1
            end, blocks, gaps = parse_cigar(start, fields[5])
            for name, a, b in tests:
                for j, ok in enumerate(support(start, end, blocks, gaps, a, b)):
                    if ok:
                        counts[name][j].add(fields[0])
        if proc.wait() != 0:
            raise RuntimeError(f'samtools view failed: {bam}')
        for name, _, _ in tests:
            writer.writerow([row['label'], name, *(len(x) for x in counts[name])])
        sys.stdout.flush()


if __name__ == '__main__':
    main()
