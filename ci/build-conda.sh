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


run_heavydb() {
    mamba create -n heavyai-db heavydb
    conda activate heavyai-db

    mkdir data && initheavy data
    heavydb \
        --data data \
        --enable-runtime-udfs \
        --enable-table-functions &

    sleep 10
    conda deactivate
}


build_test_cpu() {
    mamba env create -f ci/environment.yml
    conda activate heavyai-dev
    which python
    pip install --no-deps .

    conda deactivate
    run_heavydb
    conda activate heavyai-dev
}

build_test_gpu() {
    mamba env create -f ci/environment_gpu.yml
    conda activate heavyai-gpu-dev
    which python
    python -c "import cudf"
    pip install --no-deps .

    conda deactivate
    run_heavydb
    conda activate heavyai-gpu-dev
}


conda install -y mamba
eval "$(command conda 'shell.bash' 'hook' 2> /dev/null)"

if [[ cpu_only -eq 1 ]];then
    echo "================================"
    echo "  Starting CPU Build and Test"
    echo "================================"
    build_test_cpu
fi

if [[ gpu_only -eq 1 ]];then
    echo "================================"
    echo "  Starting GPU Build and Test"
    echo "================================"
    build_test_gpu
fi

pytest -sv tests/
