#!/bin/bash

set -e
set -x
# To be run from root of repo

# GCC needed to build thrift wheel
# git needed for setup.py scm version
/opt/conda/bin/conda create -n heavyai-dev-pip python=${PYTHON} git gcc_linux-64 gxx_linux-64 --yes

source /opt/conda/bin/activate heavyai-dev-pip

pip install -e '.[test]'