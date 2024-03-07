#!/usr/bin/bash


#
# Script to be either run locally to build the system or to be run from a
# Jenkins job
#
# Note the build and release to PyPI is handled via gthub actions and is 
# controlled by a yaml file under PROJECT_DIR/.guthub/workflows

python3 -c '
import sys
print("Python version [{}]".format(sys.version_info))
if sys.version_info.minor < 10:
  print("ERROR.  Minimum python version 3.10 required")
  exit(1)
exit(0)
' ; ST=$?

if [[ $ST -ne 0 ]] ; then
  echo "Python version error. Exiting"
  exit $ST
fi

python3 -m venv venv
. ./heavyai_env/bin/activate
pip install flit sphinx sphinx_rtd_theme numpydoc
flit build 

pip install dist/heavyai-1.3-py3-none-any.whl
sphinx-build -M html docs/source/ docs/build
