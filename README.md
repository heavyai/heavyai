[![PyPi package link](https://img.shields.io/pypi/v/heavyai?style=for-the-badge)](https://pypi.org/project/heavyai/)
[![Conda package link](https://img.shields.io/conda/vn/conda-forge/heavyai?style=for-the-badge)](https://anaconda.org/conda-forge/heavyai)


heavyai
=======
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/heavyai/heavyai/blob/main/LICENSE.txt)
[![Security](https://img.shields.io/badge/Security-Report%20a%20Vulnerability-red.svg)](https://github.com/heavyai/heavyai/blob/main/SECURITY.md)
[![GitHub Discussions](https://img.shields.io/badge/GitHub-Discussions-blue?logo=github)](https://github.com/orgs/heavyai/discussions)



This package enables using common Python data science toolkits with
[HeavyDB](https://github.com/heavyai/heavydb).
It brings data frame support on CPU and GPU as well as support for arrow.
See the [documentation](http://heavyai.readthedocs.io/en/latest/?badge=latest)
for more. NOTE: This documentation may not be up to date to the latest HeavyDB version.

Quick Install (CPU)
-------------------

Packages are available on conda-forge and PyPI:

```bash
# using conda-forge
conda install -c conda-forge heavyai

# using pip
pip install heavyai
```

Quick Install (GPU)
-------------------

We recommend creating a fresh conda 3.8 or 3.9 environment when installing
heavyai with GPU capabilities.

To install heavyai for GPU Dataframe support (conda-only):

```bash
mamba create -n heavyai-gpu -c rapidsai -c nvidia -c conda-forge -c defaults \
    --no-channel-priority \
    cudf heavyai pyheavydb pytest shapely geopandas pyarrow=*=*cuda
```

Documentation
-------------

Further documentation for heavyai usage is available at: http://heavyai.readthedocs.io/ NOTE: This documentation may not be up to date to the latest HeavyDB version.

## Security
> [!WARNING]
> **Do not report security vulnerabilities through public GitHub issues!**

NVIDIA takes security seriously. If you discover a vulnerability in heavyai, **DO NOT open a public issue**. Use one of the private reporting channels described in [SECURITY.md](https://github.com/heavyai/heavyai/blob/main/SECURITY.md).

## Support
Join the [HeavyAI GitHub Discussions](https://github.com/orgs/heavyai/discussions) to ask questions, share feedback, and report issues. HeavyAI maintainers review issues, discussions, and pull requests on a best effort basis without guaranteed response timelines.
  
## License
Apache 2.0. See [LICENSE](https://github.com/heavyai/heavyai/blob/main/LICENSE.txt).

