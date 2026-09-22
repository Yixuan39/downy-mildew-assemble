#!/usr/bin/env bash
# Purpose : Actual SLURM job body run on the cluster (via `host.compute` job submission,
#           not sbatch by hand) to generate the mapping/coverage/read-interval evidence for
#           spans OR502AA_015_s1, OR502AA_022_s1 in ../ncbi_reply.Rmd. Thin wrapper around
#           map_and_measure.sh: locate the isolate's reads, run the core script, then stage
#           the small outputs into the job's own working directory (large intermediates -
#           the BAM and per-base depth tables outside the flagged spans - stay on the cluster).
# Inputs  : $PD/results/read-filtering-screening/reads/focal/Quesada_SQIIe_*.fastq.gz
#           map_and_measure.sh (this directory), and its inputs (see that script's header)
# Outputs : percontig_aligned.tsv, flagged_contig_coverage.tsv, per-span read_intervals.tsv.gz,
#           per-span depth_mq0.tsv.gz / depth_mq20.tsv.gz - copied into ../data/ for this isolate
# Runs on : SLURM, 32 cores, 100G mem (job.sh harness omitted - this is the command body)
# Usage   : bash submit_mapping_*.sh   (paths are absolute to the cluster project tree;
#           kept as historical record of exactly what ran, not meant to be re-run verbatim
#           on a different machine)
export PATH=$HOME/miniforge3/envs/downy/bin:$PATH
PD=$HOME/project_data/downy
OUT=$PD/results/assembly-qc/ncbi-flag-evidence
READS=$(ls $PD/results/read-filtering-screening/reads/focal/Quesada_SQIIe_Phumuli*.fastq.gz | head -1)
echo "reads: $READS"
bash $OUT/map_and_measure.sh Pseudoperonospora_humuli_OR502AA "$READS"

cp $OUT/Pseudoperonospora_humuli_OR502AA.percontig_aligned.tsv ./ || true
cp $OUT/Pseudoperonospora_humuli_OR502AA.flagged_contig_coverage.tsv ./ || true
for ctg in $(awk -F'\t' -v s=Pseudoperonospora_humuli_OR502AA 'NR>1 && $2==s {print $3}' $OUT/spans.tsv | sort -u); do
  cp $OUT/Pseudoperonospora_humuli_OR502AA.$ctg.read_intervals.tsv ./ || true
done
for lab in OR502AA_015_s1 OR502AA_022_s1; do
  cp $OUT/$lab.depth_mq0.tsv ./ || true
  cp $OUT/$lab.depth_mq20.tsv ./ || true
done
gzip -f ./*.depth_mq*.tsv ./*read_intervals.tsv || true
ls -lh ./*.tsv ./*.tsv.gz || true
