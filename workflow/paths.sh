#!/usr/bin/env bash
# Source once from the repository root before submitting jobs. Overrides must be absolute.
export REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
export PROJECT_DATA="${PROJECT_DATA:-$HOME/project_data/downy}"
export DB_ROOT="${DB_ROOT:-$HOME/db}"
export SOFTWARE_ROOT="${SOFTWARE_ROOT:-$HOME/software}"
export TARGET_ASM_DIR="${TARGET_ASM_DIR:-$SOFTWARE_ROOT/targetasm}"
for path in "$REPO_ROOT" "$PROJECT_DATA" "$DB_ROOT" "$SOFTWARE_ROOT" "$TARGET_ASM_DIR"; do
    [[ "$path" = /* ]] || { echo "Expected an absolute path: $path" >&2; return 1; }
done
unset path
# Both runtimes support the container commands used here.
if [[ -z "${CONTAINER_RUNTIME:-}" ]]; then
    if command -v apptainer >/dev/null 2>&1; then CONTAINER_RUNTIME=apptainer
    else CONTAINER_RUNTIME=singularity
    fi
fi
export CONTAINER_RUNTIME
