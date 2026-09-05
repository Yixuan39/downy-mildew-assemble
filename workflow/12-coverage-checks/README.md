# Stage 12 - Targeted coverage checks

The read-level evidence behind the SC1982 assembly-gap discussion: HiFi reads mapped back to contig
`Pcub-SC1982_002` to check support across the gap and at the contig tail, plus the summary of
annotation and read support for the 14 genes in that region.

## Scripts

| file | what it does | where it runs |
|---|---|---|
| `check-sc1982-gap-tail-coverage.sh` | Map the SC1982 HiFi reads back to contig Pcub-SC1982_002 to check read support across the gap and the contig tail - the coverage evidence behind the SC1982 assembly-gap discussion. Reads live on an external drive; edit REFERENCE/READS before running. | local macOS workstation, 16 threads |
| `summarize-sc1982-14-gene-support.R` | Summarise the annotation and read support for the 14 genes in the SC1982 region of interest, as reported in the text. | local, R |

## Notes

Runs locally and reads from an external drive (`/Volumes/YY3/downy/...`). Edit `REFERENCE` and
`READS` before running.
