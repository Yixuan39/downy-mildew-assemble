
# Purpose : List every NCBI taxid under Oomycota (taxid 4762); used to build the -taxidlist filter for the
#           BLAST contamination screens.
# Inputs  : NCBI taxonomy dump available to taxonkit
# Outputs : oomycete taxid list on stdout (redirect to a file)
# Runs on : anywhere taxonkit is installed
# Usage   : bash workflow/00-data-acquisition/get-oomycete-taxids.sh > oomycete.taxids
set -euo pipefail
source "${REPO_ROOT:-${SLURM_SUBMIT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}}/workflow/paths.sh"

taxonkit list --ids 4762 --indent ""
