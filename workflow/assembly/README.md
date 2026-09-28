# Assembly

`run-targetasm.sh MSU1|SC1982|OR502AA|UA202013` runs the external [targetasm](https://github.com/Yixuan39/targetasm) Nextflow pipeline on adapter-filtered HiFi reads. It writes the original run names under `$PROJECT_DATA/results/assembly/`. The three focal runs retain their isolate-specific target sizes and seed; UA202013 has no downsampling target. Run this launcher from a login node because Nextflow submits the jobs.
