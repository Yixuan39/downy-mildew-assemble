#!/usr/bin/env python3
"""Split a multi-record GenBank file into one file per genome."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_SOURCE = SCRIPT_DIR.parent / "14_mitochondrial_genomes.gb"


def split_genbank(source: Path, output_dir: Path) -> list[Path]:
    text = source.read_text(encoding="utf-8")
    records = [
        part.strip() + "\n//\n"
        for part in re.split(r"(?m)^//\s*$", text)
        if re.search(r"(?m)^LOCUS\s", part)
    ]
    if not records:
        raise ValueError(f"No GenBank records found in {source}")

    output_dir.mkdir(parents=True, exist_ok=True)
    used: set[str] = set()
    paths: list[Path] = []

    for record in records:
        locus = re.search(r"(?m)^LOCUS\s+(\S+)", record).group(1)
        isolate_match = re.search(r'/isolate=(?:"([^"]+)"|([^\s]+))', record)
        isolate = (isolate_match.group(1) or isolate_match.group(2)) if isolate_match else None
        stem = re.sub(r"[^A-Za-z0-9._-]+", "_", isolate or locus).strip("_")
        if stem in used:
            stem = f"{stem}_{re.sub(r'[^A-Za-z0-9._-]+', '_', locus)}"
        used.add(stem)

        path = output_dir / f"{stem}.gb"
        path.write_text(record, encoding="utf-8")
        paths.append(path)

    for path in paths:
        result = path.read_text(encoding="utf-8")
        assert len(re.findall(r"(?m)^LOCUS\s", result)) == 1
        assert result.rstrip().endswith("//")
    return paths


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", nargs="?", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("-o", "--output-dir", type=Path, default=SCRIPT_DIR)
    args = parser.parse_args()

    for path in split_genbank(args.source, args.output_dir):
        print(path)


if __name__ == "__main__":
    main()
