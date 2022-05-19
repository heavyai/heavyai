#!/usr/bin/env bash

set -o errexit
set -o pipefail

# Get current script dir
# then resolve project root, one dir up
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
WORKDIR="$DIR/.."

cd "$WORKDIR"

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$*" >&2
        exitcode=1
    fi
    cat << EOF
Usage: $0 [OPTION]...
Run heavyai tests
Options:
  --db-image IMAGE_NAME         Required.
  --cpu-only                    Only build and test for CPU build.
  --gpu-only                    Only build and test for GPU build.
  -h, --help                    Print this help
EOF
    exit "$exitcode"
}

db_image= # docker image that hosts the HeavyDB instance
db_container_name="heavyai-db" # name of container the db instances runs in
testscript_container_name="heavyai-test" # name of container the tests run in

cpu_only=0
gpu_only=0

# set docker image to run DB in
while [[ $# != 0 ]]; do
    case $1 in
    -h|--help) usage ;;
    --cpu-only) cpu_only=1 ;;
    --gpu-only) gpu_only=1 ;;
    --db-image) shift; db_image=$1 ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) usage "Unexpected argument: $1" ;;
    esac
    shift
done

cleanup() {
    docker rm -f $testscript_container_name &> /dev/null || true
    docker rm -f $db_container_name &> /dev/null || true
}

print_db_logs() {
    echo "=========================="
    echo "  Begin DB Container Logs "
    echo "=========================="
    echo ""

    docker logs $db_container_name

    echo ""
    echo "=========================="
    echo "  End DB Container Logs "
    echo "=========================="
}

exit_on_error() {
    echo "=================================="
    echo "  Failed with error code: $*" >&2
    echo "  Showing DB logs before exiting"
    echo "=================================="
    print_db_logs
    cleanup
    exit 1
}

ready=1
if ! [[ "$db_image" ]]; then
    ready=
    error "Required parameter missing: CPU docker image. Specify it using --db-image"
fi

[[ "$ready" ]] || exit 1

test_heavyai() {
    # Forward args to build-conda.sh
    # --cpu-only
    # or
    # --gpu-only

    params=()

    if [[ gpu_only -eq 1 ]];then
        echo ""
        echo "CUDA toolkit version"
        nvcc --version
        echo ""
        echo "NVIDIA drivers"
        nvidia-smi
        echo ""
        params+=("--runtime=nvidia")
    fi

    docker run "${params[@]}" \
        --rm \
        -v ${WORKDIR}:/heavyai \
        --interactive \
        --workdir="/heavyai" \
        --name "${testscript_container_name}" \
        rapidsai/rapidsai-core:22.04-cuda11.0-base-ubuntu20.04-py3.9 \
        /heavyai/ci/build-conda.sh "$*"
    return $?
}

cleanup

# disable exit on error, so we still
# get logs + perform cleanup
set +o errexit

if [[ gpu_only -eq 1 ]];then
    test_heavyai --gpu-only || exit_on_error "$?"
fi

if [[ cpu_only -eq 1 ]];then
    test_heavyai --cpu-only || exit_on_error "$?"
fi

echo "======================"
echo "  Starting Cleanup"
echo "======================"
cleanup