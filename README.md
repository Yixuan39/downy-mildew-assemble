# Genome Cleaning and Assembly

This project aimed to assemble downy mildew genome collected from highly contaminated sample sequenced by PacBio HIFI technology.

# Analysis

[Reference genome quality](https://yixuan39.github.io/downy-mildew-assemble/analysis/ref-genome-quality.html)

[Results of pipeline: hifiasm->FCS-GX->purge_dups](https://yixuan39.github.io/downy-mildew-assemble/analysis/pipeline-result.html)

[Read length distribution and taxonomy analysis](https://yixuan39.github.io/downy-mildew-assemble/analysis/read_distribution.html)

[FCS-GX taxonomy analysis of contigs](https://yixuan39.github.io/downy-mildew-assemble/analysis/taxonomy-analysis.html)

[Final assembly](https://yixuan39.github.io/downy-mildew-assemble/analysis/final_result.html)

# Pipeline

## Environment

Required softwares:

1. [hifiasm](https://github.com/chhylp123/hifiasm)
2. [FCS-GX](https://github.com/ncbi/fcs-gx)
3. [Purge_Dups](https://github.com/dfguan/purge_dups)
3. [Kraken2](https://github.com/DerrickWood/kraken2)
6. [compleasm](https://github.com/huangnengCSU/compleasm)
7. [QUAST](https://github.com/ablab/quast)

## Database

`FCS-GX` database. This database will require approximately 500GB memory.

```
sync_files.py get \
    --mft=https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/FCS/database/latest/all.manifest \
    --dir ./fcs-db/
GX_DB=$HOME/fcs-db/
```

`Kraken2` database

Composition of the database: 
1. oomycota genomes that are evolutionary closely related.
2. uncommon contamination DNA (Cucumis sativus, Humulus lupulus).
3. common contamination (optional: human, plant, fungi...)

```
KrakenDB=$HOME/KrakenDB
kraken2-build --db ${KrakenDB} --download-taxonomy
kraken2-build --db ${KrakenDB} --add-to-library ${REF_PATH}/oomycota-genome.fasta
kraken2-build --db ${KrakenDB} --add-to-library ${REF_PATH}/common-contam-genome.fasta
kraken2-build --db ${KrakenDB} --build --threads 24
kraken2-build --db ${KrakenDB} --clean
```

# Process

Here we use `sample.fastq.gz` to represent the PacBio HIFI read file.

## 1.Assemble the PacBio data

Assemble genome with `hifiasm`

```
hifiasm \
    -t 24 \
    -l0 \
    --primary \
    -o ./sample.asm/sample.asm \
    ./sample.fastq.gz

echo "Converting GFA to FASTA..."
gfatools gfa2fa \
    ./sample.asm/sample.asm.p_ctg.gfa \
    > ./sample.asm/sample.asm.p_ctg.fa
```

## 2.Clean out common contamination with FCS-GX

Screen the assembly with `FCS-GX`. `tax-id` was set to 4762 (oomycota) to avoid recognize target contigs as contamination.

```
run_gx.py \
    --fasta ./sample.asm/sample.asm.p_ctg.fa \
    --tax-id 4762 \
    --gx-db ${GX_DB} \
    --out-dir . \
    --out-basename sample
```

Remove contamination contigs based on the action report of `FCS-GX`

```
gx clean-genome \
    --input ./sample.asm/sample.asm.p_ctg.fa \
    --action-report ./sample.fcs_gx_report.txt \
    --output ./sample.fcs.fasta
```

## 3. Purge duplicated contigs

see [purge_dups.sh](https://yixuan39.github.io/downy-mildew-assemble/code/purge_dups.sh)

## 4.Quality evaluation

You can evaluate the genome assembly quality with the tool you prefer. In this study we used `compleasm` and `QUAST`.

