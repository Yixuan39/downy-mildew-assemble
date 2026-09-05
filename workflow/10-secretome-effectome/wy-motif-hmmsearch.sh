
# ----------------------------------------------------------------------------------------
# Purpose : hmmsearch the soluble secretome with the WY-motif HMM to identify WY-domain effector candidates.
# Inputs  : the soluble secretome FASTA and WY_motif.hmm
# Outputs : hmmsearch table and alignment output
# Runs on : external system - see stage README
# Usage   : bash workflow/10-secretome-effectome/wy-motif-hmmsearch.sh
# ----------------------------------------------------------------------------------------
hmmsearch \
  --max \
  -T 0 \
  --domT 0 \
  --incT 0 \
  --incdomT 0 \
  --tblout OR502AA_WY.tblout \
  --domtblout OR502AA_WY.domtblout \
  -o OR502AA_WY.output \
  WY_motif.hmm \
  OR502AA_final_soluble_secretome.faa
