#!/usr/bin/env python3
"""
Split assembly contigs at internal runs of N, dropping only the N characters.

GenBank does not accept contigs containing long internal runs of Ns that stand in
for hard-masked (removed) sequence. This script splits such contigs into their
resolved segments, removing ONLY the Ns and leaving every resolved base untouched.

Segment naming: a contig split into n segments yields <contig>a, <contig>b, ...
Contigs with no qualifying N-run keep their original name and sequence.

Usage:
  split-n-gaps.py --in <assembly.fasta[.gz]> --out <submission.fasta>
                  --report <splits.tsv> [--min-n 10] [--min-segment 200]
"""
import argparse, gzip, re, sys

def open_maybe_gz(p, mode="rt"):
    return gzip.open(p, mode) if p.endswith(".gz") else open(p, mode)

def read_fasta(path):
    name, chunks = None, []
    with open_maybe_gz(path) as fh:
        for line in fh:
            line = line.rstrip("\n")
            if line.startswith(">"):
                if name is not None:
                    yield name, "".join(chunks)
                name, chunks = line[1:].split()[0], []
            else:
                chunks.append(line.strip())
    if name is not None:
        yield name, "".join(chunks)

def wrap(seq, width=80):
    return "\n".join(seq[i:i+width] for i in range(0, len(seq), width))

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--in", dest="inp", required=True)
    ap.add_argument("--out", dest="out", required=True)
    ap.add_argument("--report", dest="report", required=True)
    ap.add_argument("--min-n", type=int, default=10,
                    help="minimum length of an N-run to split at (default 10)")
    ap.add_argument("--min-segment", type=int, default=200,
                    help="drop resolved segments shorter than this (GenBank floor, default 200)")
    a = ap.parse_args()

    nrun = re.compile(r"[Nn]{%d,}" % a.min_n)
    rows = ["\t".join(["contig", "action", "orig_length_bp", "n_removed_bp",
                       "segment", "segment_start_1based", "segment_end_1based",
                       "segment_length_bp"])]
    n_in = n_out = 0
    bp_in = bp_out = bp_n_removed = 0
    dropped = []

    with open(a.out, "w") as out:
        for name, seq in read_fasta(a.inp):
            n_in += 1
            bp_in += len(seq)
            runs = [(m.start(), m.end()) for m in nrun.finditer(seq)]
            if not runs:
                out.write(f">{name}\n{wrap(seq)}\n")
                n_out += 1
                bp_out += len(seq)
                rows.append("\t".join([name, "unchanged", str(len(seq)), "0",
                                       name, "1", str(len(seq)), str(len(seq))]))
                continue
            # resolved segments between the N-runs
            segs, prev = [], 0
            for s, e in runs:
                segs.append((prev, s))
                prev = e
            segs.append((prev, len(seq)))
            removed = sum(e - s for s, e in runs)
            bp_n_removed += removed
            kept = [(s, e) for s, e in segs if e - s >= a.min_segment]
            for i, (s, e) in enumerate(kept):
                sub = seq[s:e]
                nm = f"{name}{chr(ord('a')+i)}" if len(kept) > 1 else name
                out.write(f">{nm}\n{wrap(sub)}\n")
                n_out += 1
                bp_out += len(sub)
                rows.append("\t".join([name, f"split_into_{len(kept)}", str(len(seq)),
                                       str(removed), nm, str(s+1), str(e), str(e-s)]))
            for s, e in segs:
                if 0 < (e - s) < a.min_segment:
                    dropped.append((name, s+1, e, e-s))

    with open(a.report, "w") as rh:
        rh.write("\n".join(rows) + "\n")

    print(f"contigs in : {n_in}\tbp in : {bp_in}")
    print(f"contigs out: {n_out}\tbp out: {bp_out}")
    print(f"N bp removed: {bp_n_removed}")
    print(f"bp accounting: {bp_in} - {bp_n_removed} = {bp_in - bp_n_removed} (out {bp_out})")
    if dropped:
        print(f"WARNING dropped {len(dropped)} sub-{a.min_segment}bp segment(s): {dropped}",
              file=sys.stderr)
    if bp_out != bp_in - bp_n_removed - sum(d[3] for d in dropped):
        print("ERROR: base accounting does not balance", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
