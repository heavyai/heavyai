#!/bin/bash

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
WORKDIR="$DIR/.."

pushd "$WORKDIR"

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$*" >&2
        exitcode=1
    fi
    cat << EOF
Usage: $0 [OPTION]...
Build and test heavyai in conda environment.
Options:
  --cpu-only              Only run CPU based build and test.
  --gpu-only              Only run GPU based build and test.
  -h, --help                          Print this help
EOF
    exit "$exitcode"
}

# args=()
cpu_only=0
gpu_only=0
while [[ $# != 0 ]]; do
    case $1 in
    -h|--help) usage ;;
    --cpu-only) shift; cpu_only=1 ;;
    --gpu-only) shift; gpu_only=1 ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) usage "Unexpected argument: $1" ;;
    esac
done

build_test_cpu() {
    mamba env create -f environment.yml
    conda activate heavyai-dev
    pip install -e .
    pytest -sv tests/
}

build_test_gpu() {
    mamba env create -f environment_gpu.yml
    conda activate heavyai-gpu-dev
    pip install -e .
    pytest -sv tests/
}


conda install -y mamba
eval "$(command conda 'shell.bash' 'hook' 2> /dev/null)"

if [[ gpu_only -ne 1 ]];then
    echo "================================"
    echo "  Starting CPU Build and Test"
    echo "================================"
    build_test_cpu
fi

if [[ cpu_only -ne 1 ]];then
    echo "================================"
    echo "  Starting GPU Build and Test"
    echo "================================"
    build_test_gpu
fi