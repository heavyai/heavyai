=========
pyomnisci
=========

.. image:: https://jenkins-os.mapd.com/buildStatus/icon?job=pyomnisci-tests-pr
   :target: https://jenkins-os.mapd.com/job/pyomnisci-tests-pr/
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
    -c defaults cudf=0.18 python=3.7 cudatoolkit=11.0 pyomnisci
   
Documentation
-------------

Further documentation for pyomnisci usage is available at: http://pyomnisci.readthedocs.io/

.. _DB API: https://www.python.org/dev/peps/pep-0249/
.. _OmniSci: https://www.omnisci.com/
.. _documentation: http://pyomnisci.readthedocs.io/en/latest/?badge=latest
