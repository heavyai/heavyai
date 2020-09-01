=========
pyomnisci
=========

.. image:: https://readthedocs.org/projects/pyomnisci/badge/?version=latest
   :target: http://pyomnisci.readthedocs.io/en/latest/?badge=latest
   :alt: Documentation Status

.. image:: https://jenkins-os.mapd.com/buildStatus/icon?job=pymapd-tests
   :target: https://jenkins-os.mapd.com/job/pymapd-tests/
   :alt: Jenkins Build Status

This package enables using common Python data science toolkits with `OmniSciDB`. It brings data frame 
support on CPU and GPU as well as support for arrow. See the `documentation`_ for more.

Quick Install
-------------

Packages are available on conda-forge and PyPI::

   conda install -c conda-forge pyomnisci

   pip install pyomnisci

To install cudf for GPU Dataframe support (conda-only)::

   conda install -c nvidia/label/cuda10.0 -c rapidsai/label/cuda10.0 -c numba -c conda-forge -c defaults cudf pyomnisci

.. _OmniSci: https://www.omnisci.com/
.. _documentation: http://pyomnisci.readthedocs.io/en/latest/?badge=latest
