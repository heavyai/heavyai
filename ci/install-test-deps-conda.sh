#!/bin/bash

set -o errexit   # abort on nonzero exitstatus
# set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

eval "$(command conda 'shell.bash' 'hook' 2> /dev/null)"

conda install -y mamba

PROJECT_ROOT=/pymapd
PYTHON=3.7
CPU_ONLY=true 
pushd $PROJECT_ROOT

function print_status() {
    printf "STATUS %s" "$1"
}

function build_conda_env() {
    print_status "Building conda env"
    env_file="$PROJECT_ROOT/environment.yml"
    env_name=omnisci-dev
    sed -E "s/- python[^[:alpha:]]+$/- python=$PYTHON/" ${env_file} > "/tmp/${env_name}_${PYTHON}.yml"

    cat "/tmp/${env_name}_${PYTHON}.yml"

    mamba env create -f "/tmp/${env_name}_${PYTHON}.yml"

    conda activate "${env_name}"

    conda install -y git conda-build \
        conda-forge::binutils_impl_linux-64 \
        conda-forge::binutils_linux-64 \
        conda-forge::gcc_impl_linux-64 \
        conda-forge::gcc_linux-64 \
        conda-forge::gxx_impl_linux-64 \
        conda-forge::gxx_linux-64 \
        conda-forge::libgcc-ng \
        conda-forge::libstdcxx-ng && \
        conda env list && \
        conda list "${env_name}" && \
        which python && \
        which gcc && \
        pip install -e .
}

build_conda_env
# if [ "$CPU_ONLY" = true ] ; then
# else
#     ENV_FILE="$PROJECT_ROOT/environment_gpu.yml"
#     ENV_NAME=omnisci-gpu-dev
# fi


# create a copy of the environment file, replacing
# with the python version we specify.


# /opt/conda/bin/activate ${ENV_NAME}


# echo
# exit 0
