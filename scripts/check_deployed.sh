#!/bin/bash
# Compares the upstream branch tips against what edelweissfe-latest.sif on a
# cluster was built from, to tell whether build.sh + deploy.sh need to run.
#
# Usage: scripts/check_deployed.sh --target=<leo5|leo4|vsc5>
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/_targets.sh"
parse_target "$@"
require_deploy_config
EDELWEISSFE_REPO="${EDELWEISSFE_REPO:-https://github.com/Edelweiss-Numerics/EdelweissFE.git}"
EDELWEISSFE_BRANCH="${EDELWEISSFE_BRANCH:-next_v26.11}"
MARMOT_REPO="${MARMOT_REPO:-https://github.com/MAteRialMOdelingToolbox/Marmot.git}"
MARMOT_BRANCH="${MARMOT_BRANCH:-next_v26.11}"

echo "=== Upstream ==="
echo "EdelweissFE commit: $(git ls-remote "$EDELWEISSFE_REPO" "refs/heads/$EDELWEISSFE_BRANCH" | cut -f1) ($EDELWEISSFE_BRANCH)"
echo "Marmot commit: $(git ls-remote "$MARMOT_REPO" "refs/heads/$MARMOT_BRANCH" | cut -f1) ($MARMOT_BRANCH)"
echo ""
echo "=== Deployed on $TARGET ($DEPLOY_DIR/edelweissfe-latest.sif) ==="
remote_container_exec "$DEPLOY_DIR/edelweissfe-latest.sif" cat /opt/build_info.txt \
    || echo "(nothing deployed yet, or unreadable)"
