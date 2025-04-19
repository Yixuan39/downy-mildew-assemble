# Genome Cleaning and Assembly

This project aimed to assemble downy mildew genome collected from highly contaminated sample sequenced by PacBio HIFI technology.

# Prepare

## Environment

You can create the environment with the following command

```
conda create -n clean-asm --file environment.txt
```

## Database

`FCS-GX` database

```
sync_files.py get \
    --mft=https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/FCS/database/latest/all.manifest \
    --dir ./fcs-db/
GX_DB="./fcs-db/"
```

# Process

Here we use `sample.fastq.gz` to represent the PacBio HIFI read file.

## 1.Assemble the PacBio data

Assemble genome with `metaMDBG`

```
metaMDBG asm \
    --out-dir ./sample.asm \
    --in-hifi ./sample.fastq.gz \
    --threads 24
mv ./sample.asm/contigs.fasta.gz ./sample.fasta.gz
```

Set a threshold for contig length. Here we require contig length > 5000 bp

```
seqtk seq \
    -L 5000 \
    ./sample.fasta.gz \
    | gzip > ./sample.filtered.fasta.gz
```

## 2.Clean out common contamination with FCS-GX

Screen the assembly with `FCS-GX`. `tax-id` was set to 4762 (oomycota) to avoid recognize target contigs as contamination.

```
run_gx.py \
    --fasta ./sample.filtered.fasta.gz \
    --tax-id 4762 \
    --gx-db ${GX_DB} \
    --out-dir . \
    --out-basename sample
```

Remove contamination contigs based on the action report of `FCS-GX`

```
gx clean-genome \
    --input ./sample.filtered.fasta.gz \
    --action-report ./sample.fcs_gx_report.txt \
    --output ./sample.fcs.fasta
```

## 3.Extract target genome contigs

Assign taxonomy with `Kraken2`. Here we choose `confidence score = 0.5`

```
kraken2 \
    --db ${KrakenDB} \
    --confidence 0.5 \
    --threads 24 \
    --output ./sample.kraken \
    --report ./sample.kreport \
    ./sample.fcs.fasta
```

Extract contigs that classified under Oomycota class

```
extract_kraken_reads.py \
    -k ./sample.kraken \
    -s ./sample.fcs.fasta \
    --report ./sample.kreport \
    --taxid 4762 \
    --output ./sample.kraken.fasta \
    --include-children
```

## 4.Quality evaluation

You can evaluate the genome assembly quality with the tool you prefer. In this study we used `compleasm` and `QUAST`.

