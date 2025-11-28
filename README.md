# Genome Cleaning and Assembly

This project aimed to assemble downy mildew genome collected from highly contaminated sample sequenced by PacBio HIFI technology.

# Analysis

[Reference genome quality](https://yixuan39.github.io/downy-mildew-assemble/analysis/ref-genome-quality.html)

[Read length distribution and taxonomy analysis](https://yixuan39.github.io/downy-mildew-assemble/analysis/read_distribution.html)

[Final assembly](https://yixuan39.github.io/downy-mildew-assemble/analysis/final_result.html)

[unplaced contigs](https://yixuan39.github.io/downy-mildew-assemble/analysis/unplaced-contigs.html)

[scaffolds](https://yixuan39.github.io/downy-mildew-assemble/analysis/scaffolds.html)

**get database**

`FCS-GX` database. This database will require approximately 500GB memory.

```
sync_files.py get \
    --mft=https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/FCS/database/latest/all.manifest \
    --dir ./fcs-db/
GX_DB=$HOME/fcs-db/
```

