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

Quick Install (CPU)
-------------------

Packages are available on conda-forge and PyPI::

   conda install -c conda-forge pyomnisci

   pip install pyomnisci

Quick Install (GPU)
-------------------

We recommend creating a fresh conda 3.7 or 3.8 environment when installing
pymapd with GPU capabilities.

To install pymapd and cudf for GPU Dataframe support (conda-only)::

   conda create -n omnisci-gpu -c rapidsai -c nvidia -c conda-forge \
    -c defaults cudf=0.15 python=3.7 cudatoolkit=10.2 pyomnisci

.. _DB API: https://www.python.org/dev/peps/pep-0249/
.. _OmniSci: https://www.omnisci.com/
.. _documentation: http://pyomnisci.readthedocs.io/en/latest/?badge=latest
