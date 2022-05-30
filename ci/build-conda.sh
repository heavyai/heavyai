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


if [[ gpu_only -eq 1 ]];then
    echo "================================"
    echo "  Starting GPU Build and Test"
    echo "================================"
    environment_file=ci/environment_gpu.yml
    environment_name=heavyai-gpu-dev
    heavydb_version="heavydb=*=*_cuda"
else
    echo "================================"
    echo "  Starting CPU Build and Test"
    echo "================================"
    environment_file=ci/environment.yml
    environment_name=heavyai-dev
    heavydb_version="heavydb=*=*_cpu"
fi


conda install -y mamba
eval "$(command conda 'shell.bash' 'hook' 2> /dev/null)"


echo "================================"
echo "  Installing Dependencies"
echo "================================"
mamba env create -f $environment_file
conda activate $environment_name

if [[ gpu_only -eq 1 ]];then
     python -c "import cudf"
fi

pip install --no-deps .
conda deactivate

echo "================================"
echo "  Starting HeavyDB"
echo "================================"
mamba create -n heavyai-db $heavydb_version
conda activate heavyai-db
rm -rf data-db && mkdir data-db && initheavy data-db
heavydb --data data-db &
sleep 10
conda deactivate

echo "================================"
echo "  Test HeavyAI"
echo "================================"
conda activate $environment_name
pytest -sv tests/
