[![PyPi package link](https://img.shields.io/pypi/v/heavyai?style=for-the-badge)](https://pypi.org/project/heavyai/)
[![Conda package link](https://img.shields.io/conda/vn/conda-forge/heavyai?style=for-the-badge)](https://anaconda.org/conda-forge/heavyai)


heavyai
=======

This package enables using common Python data science toolkits with
[HeavyDB](http://heavy.ai).
It brings data frame support on CPU and GPU as well as support for arrow.
See the [documentation](http://heavyai.readthedocs.io/en/latest/?badge=latest)
for more.

Quick Install (CPU)
-------------------

Packages are available on conda-forge and PyPI::

   conda install -c conda-forge heavyai

   pip install heavyai

Quick Install (GPU)
-------------------

We recommend creating a fresh conda 3.8 or 3.9 environment when installing
heavyai with GPU capabilities.

To install heavyai for GPU Dataframe support (conda-only):

```bash
conda create -n heavyai-gpu -c rapidsai -c nvidia -c conda-forge -c defaults python=3.9 cudf cudatoolkit=11.0 heavyai
```

Documentation
-------------

Further documentation for heavyai usage is available at: http://heavyai.readthedocs.io/
