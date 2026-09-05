# config/

Configuration that is shared between runs rather than belonging to a single script.

- `rnaseq/samplesheet_*.csv` - nf-core/rnaseq input samplesheets, one per isolate.
- `rnaseq/custom.config` - cluster resource profile for the nf-core/rnaseq runs.

The stage-08 launchers reference these by repository-relative path, so run them from the repository
root.

## Canonical data locations (NCSU BRC)

Scripts hardcode these paths rather than sourcing a config file, deliberately: each script stays
runnable on its own. This is the list they assume, and the list to update if anything moves.

| what | path |
|---|---|
| project results tree | `$HOME/project_data/downy` |
| reference databases | `$HOME/db` |
| Kraken2 PlusPFP | `$HOME/db/kraken2/PlusPFP` |
| compleasm lineages | `$HOME/db/compleasm` |
| FCS-GX (NCBI screen) | `$HOME/db/fcs-gx` |
| eggNOG | `$HOME/db/eggnog` |
| InterProScan data | `$HOME/db/interproscan-5.77-108.0` |
| DIAMOND nr | `$HOME/db/nr.dmnd` |
| targetasm checkout | `$HOME/software/targetasm` |

Earlier versions of some scripts pointed at `project_data/downy/fcs-db` and
`project_data/downy/BUSCO_DB`; those directories no longer exist and the references have been
repointed at `$HOME/db`.

## Isolates

| label | species | reads |
|---|---|---|
| MSU1 | *Pseudoperonospora cubensis* MSU-1 | `GSL_Data/fastq/filtered/Quesada_SQIIe_MSU1.fastq.gz` |
| SC1982 | *Pseudoperonospora cubensis* SC1982 | `GSL_Data/fastq/filtered/Quesada_SQIIe_SC1982.fastq.gz` |
| OR502AA | *Pseudoperonospora humuli* OR502AA | `GSL_Data/fastq/filtered/` (Phumuli library) |
| UA202013 | *Peronospora effusa* UA202013 (public) | `UA202013/filtered/UA202013.fastq.gz` |
