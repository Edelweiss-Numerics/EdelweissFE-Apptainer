# Shared by build.sh, deploy.sh and check_deployed.sh: the per-cluster
# settings, selected by --target=<name>. Source this file, then call
# load_target <name>.
#
# Public cluster facts (CPU, Apptainer module) live here. Who deploys where
# (login, container directory) is personal and lives in deploy.local.sh at the
# repository root (git-ignored; copy deploy.local.sh.example), or in the
# environment: <TARGET>_HOST, <TARGET>_CONTAINER_DIR, MANUAL_MATERIALS,
# MANUAL_MATERIALS_DIR. The environment wins over deploy.local.sh.

APPTAINER_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$APPTAINER_REPO_DIR/.build}"
TARGETS="leo5 leo4 vsc5 generic"

# Sets for target $1:
#   TARGET, ARCH_FLAGS, TARGET_TAG (image-name suffix), CONTAINER_MODULE,
#   CONTAINER_CMD, DEPLOY_HOST, DEPLOY_DIR (empty if not configured).
load_target() {
    TARGET="$1"
    TARGET_TAG="-$TARGET"
    case "$TARGET" in
        # LEO5 (Uni Innsbruck): Intel Xeon Platinum 8358 (Ice Lake-SP), AVX-512.
        leo5)
            ARCH_FLAGS="-march=icelake-server -mtune=icelake-server"
            CONTAINER_MODULE="singularityce/4.3.0-python-3.11.9-gcc-13.3.0-n5qceek"
            CONTAINER_CMD=singularity
            ;;
        # LEO4 (Uni Innsbruck): Intel Xeon E5-2690 v4 (Broadwell), AVX2 only --
        # an Ice Lake image dies with SIGILL there.
        leo4)
            ARCH_FLAGS="-march=broadwell -mtune=broadwell"
            CONTAINER_MODULE="singularity/3.x"
            CONTAINER_CMD=singularity
            ;;
        # VSC-5 (Vienna): AMD EPYC 7713 (Zen 3), AVX2, no AVX-512.
        vsc5)
            ARCH_FLAGS="-march=znver3 -mtune=znver3"
            CONTAINER_MODULE="apptainer/1.1.9-gcc-12.2.0-ab3ze5o"
            CONTAINER_CMD=apptainer
            ;;
        # Any x86 CPU with AVX2/FMA; same flags as the CI release image.
        generic)
            ARCH_FLAGS="-march=x86-64-v3"
            CONTAINER_MODULE=""
            CONTAINER_CMD=apptainer
            ;;
        *)
            echo "ERROR: unknown target '$TARGET' (one of: $TARGETS)" >&2
            exit 1
            ;;
    esac

    local config="${DEPLOY_CONFIG:-$APPTAINER_REPO_DIR/deploy.local.sh}"
    # shellcheck source=/dev/null
    [ -f "$config" ] && source "$config"
    local host_var="${TARGET^^}_HOST" dir_var="${TARGET^^}_CONTAINER_DIR"
    DEPLOY_HOST="${!host_var:-}"
    DEPLOY_DIR="${!dir_var:-}"
}

# Parses --target=<name> out of "$@" (default: generic) and calls load_target.
parse_target() {
    local target=generic arg
    for arg in "$@"; do
        case "$arg" in --target=*) target="${arg#--target=}" ;; esac
    done
    load_target "$target"
}

# Runs "$CONTAINER_CMD exec $*" on DEPLOY_HOST's login node with the module
# loaded. Non-interactive ssh shells may lack `module`, so source the profile.
remote_container_exec() {
    local load=""
    [ -n "$CONTAINER_MODULE" ] && load="module load $CONTAINER_MODULE >/dev/null 2>&1 &&"
    ssh -q -o BatchMode=yes "$DEPLOY_HOST" \
        "source /etc/profile >/dev/null 2>&1; $load $CONTAINER_CMD exec $*"
}

require_deploy_config() {
    if [ -z "$DEPLOY_HOST" ] || [ -z "$DEPLOY_DIR" ]; then
        echo "ERROR: no deploy host/directory for target '$TARGET'. Set ${TARGET^^}_HOST and" \
             "${TARGET^^}_CONTAINER_DIR in deploy.local.sh (see deploy.local.sh.example)." >&2
        exit 1
    fi
}
