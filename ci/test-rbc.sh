#!/usr/bin/env bash

set -o errexit

eval "$(command conda 'shell.bash' 'hook' 2> /dev/null)"

# TMP: Upstream patches
git clone https://github.com/xnd-project/rbc /tmp/rbc

pushd /tmp/rbc

conda env create --force --file .conda/environment.yml

conda activate rbc

pytest --capture=no --exitfirst --verbose rbc/
