#!/usr/bin/env python3
"""Resolve checked-in RNA-seq paths against PROJECT_DATA; validate before launching Nextflow."""
import csv
import os
import sys
from pathlib import Path


def prepare(source, destination, project_data):
    root = Path(project_data).expanduser().resolve()
    with open(source, newline="") as handle:
        reader = csv.DictReader(handle)
        fields, rows = reader.fieldnames, list(reader)
    if not rows or not {"sample", "fastq_1", "fastq_2", "strandedness"}.issubset(fields):
        raise ValueError("Samplesheet is empty or missing required columns")
    for row in rows:
        for key in ("fastq_1", "fastq_2"):
            path = (root / row[key]).resolve()
            if not path.is_relative_to(root):
                raise ValueError(f"Read path is outside PROJECT_DATA: {path}")
            if not path.is_file() or path.stat().st_size == 0:
                raise FileNotFoundError(path)
            row[key] = str(path)
    with open(destination, "w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)


if __name__ == "__main__":
    prepare(sys.argv[1], sys.argv[2], os.environ["PROJECT_DATA"])
