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
  --cpu-only                    Only build and test for CPU build.
  --gpu-only                    Only build and test for GPU build.
  -h, --help                    Print this help
EOF
    exit "$exitcode"
}

testscript_container_name="heavyai-test" # name of container the tests run in

cpu_only=0
gpu_only=0

# set docker image to run DB in
while [[ $# != 0 ]]; do
    case $1 in
    -h|--help) usage ;;
    --cpu-only) cpu_only=1 ;;
    --gpu-only) gpu_only=1 ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) usage "Unexpected argument: $1" ;;
    esac
    shift
done


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

# disable exit on error, so we still
# get logs
set +o errexit

if [[ gpu_only -eq 1 ]];then
    test_heavyai --gpu-only
fi

if [[ cpu_only -eq 1 ]];then
    test_heavyai --cpu-only
fi
