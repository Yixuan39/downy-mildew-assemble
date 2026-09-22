#!/usr/bin/env bash
# Purpose : For one isolate, map its HiFi reads back onto the (pre-submission) nuclear
#           assembly, restricted to the contigs NCBI's FCS-GX/contamination screen flagged,
#           then compute the per-base depth around each flagged span (+/-100kb flanks) and
#           the per-read alignment intervals on the flagged contigs. This is the evidence
#           behind the misjoin/contamination rebuttal in ../ncbi_reply.Rmd.
# Inputs  : $1 = species/isolate label matching the "species" column of spans.tsv
#             (e.g. Pseudoperonospora_cubensis_MSU1)
#           $2 = path to the isolate's HiFi read FASTQ(.gz)
#           $PD/results/assembly-qc/nuclear/$SP.fasta.gz   - the assembly
#           $OUT/spans.tsv                                 - flagged-span coordinates (see ../data/spans.tsv)
# Outputs : (all under $OUT, i.e. $PD/results/assembly-qc/ncbi-flag-evidence/)
#             $SP.flagged.bam(.bai)                 - primary alignments on flagged contigs only
#             $SP.percontig_aligned.tsv              - reads/aligned-bp per flagged contig, MQ0 and MQ20
#             $SP.flagged_contig_coverage.tsv         - samtools coverage over the flagged contigs
#             <label>.depth_mq0.tsv / <label>.depth_mq20.tsv   - per-base depth around each span
#             $SP.<contig>.read_intervals.tsv         - per-read (start,end,mapq) on each flagged contig
# Runs on : SLURM (submitted with 32 cores / 100G mem; see submit_mapping_*.sh for the three
#           per-isolate submissions actually run for this rebuttal)
# Usage   : bash map_and_measure.sh Pseudoperonospora_cubensis_MSU1 /path/to/MSU1.hifi.fastq.gz
set -euo pipefail
SP="$1"; READS="$2"
export PATH=$HOME/miniforge3/envs/downy/bin:$PATH
PD=$HOME/project_data/downy
OUT=$PD/results/assembly-qc/ncbi-flag-evidence
ASM=$PD/results/assembly-qc/nuclear/$SP.fasta.gz
THREADS=32
FLANK=100000
CTGS=$(awk -F'\t' -v s="$SP" 'NR>1 && $2==s {print $3}' $OUT/spans.tsv | sort -u | paste -sd, -)
echo "[$(date)] $SP flagged contigs: $CTGS"
BAM=$OUT/$SP.flagged.bam

minimap2 -t $THREADS -ax map-hifi --secondary=no "$ASM" "$READS" \
 | samtools view -h -F 2308 -@ 4 - \
 | awk -v want="$CTGS" -v pcf="$OUT/$SP.percontig_aligned.tsv" '
     BEGIN{ n=split(want,w,","); for(i=1;i<=n;i++) keep[w[i]]=1 }
     /^@/ { print; next }
     { cig=$6; ref=0
       while (match(cig, /^[0-9]+[MIDNSHP=X]/)) {
         len=substr(cig,RSTART,RLENGTH-1)+0; op=substr(cig,RSTART+RLENGTH-1,1)
         if (op=="M"||op=="D"||op=="N"||op=="="||op=="X") ref+=len
         cig=substr(cig,RSTART+RLENGTH) }
       nr[$3]++; ab[$3]+=ref
       if ($5>=20) { nr20[$3]++; ab20[$3]+=ref }
       if ($3 in keep) print }
     END{ printf "contig\tn_reads\taligned_bp\tn_reads_mq20\taligned_bp_mq20\n" > pcf
          for (c in ab) printf "%s\t%d\t%d\t%d\t%d\n", c, nr[c], ab[c], nr20[c]+0, ab20[c]+0 >> pcf }' \
 | samtools sort -@ 8 -m 3G -o "$BAM" -
samtools index -@ $THREADS "$BAM"
echo "[$(date)] mapping done"

samtools coverage "$BAM" > $OUT/$SP.flagged_contig_coverage.tsv

awk -F'\t' -v s="$SP" 'NR>1 && $2==s' $OUT/spans.tsv | while IFS=$'\t' read -r iso sp ctg st en lab act src; do
  lo=$(( st - FLANK )); [ $lo -lt 1 ] && lo=1
  hi=$(( en + FLANK ))
  samtools depth -a -r "$ctg:$lo-$hi" "$BAM"       | awk -v OFS='\t' -v l="$lab" '{print l,$1,$2,$3}' > $OUT/$lab.depth_mq0.tsv
  samtools depth -a -Q 20 -r "$ctg:$lo-$hi" "$BAM" | awk -v OFS='\t' -v l="$lab" '{print l,$1,$2,$3}' > $OUT/$lab.depth_mq20.tsv
  echo "  depth done $lab ($ctg:$lo-$hi)"
done

for ctg in $(echo "$CTGS" | tr ',' ' '); do
  samtools view "$BAM" "$ctg" | awk -v OFS='\t' -v c="$ctg" '
    { cig=$6; ref=0
      while (match(cig, /^[0-9]+[MIDNSHP=X]/)) {
        len=substr(cig,RSTART,RLENGTH-1)+0; op=substr(cig,RSTART+RLENGTH-1,1)
        if (op=="M"||op=="D"||op=="N"||op=="="||op=="X") ref+=len
        cig=substr(cig,RSTART+RLENGTH) }
      print c,$1,$4,$4+ref-1,$5 }' > $OUT/$SP.$ctg.read_intervals.tsv
  echo "  intervals done $ctg: $(wc -l < $OUT/$SP.$ctg.read_intervals.tsv) reads"
done
echo "[$(date)] $SP complete"
