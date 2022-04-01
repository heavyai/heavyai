.. _contributing:

Contributing to heavyai
=========================

As an open-source company, Heavy.AI welcomes contributions to all of its open-source repositories,
including heavyai. All discussion and development takes place via the `heavyai GitHub repository`_.

It is suggested, but not required, that you `create a GitHub issue`_ before contributing a feature or bug fix. This is so that other
developers 1) know that you are working on the feature/issue and 2) that internal Heavy.AI experts can help you navigate
any database-specific logic that may not be obvious within heavyai. All patches should be submitted as `pull requests`_, and upon passing
the test suite and review by Heavy.AI, will be merged to master for release as part of the next package release cycle.

-----------------------------
Development Environment Setup
-----------------------------

heavyai is written in plain Python 3 (i.e. no Cython), and as such, doesn't require any specialized development
environment outside of installing the dependencies. However, we do suggest creating a new conda development enviornment
with the provided conda `environment.yml` file to ensure that your changes work without relying on unspecified system-level
Python packages.

Two development environment files are provided: one to provide the packages needed to develop on CPU only,
and the other to provide `GPU` development packages. Only one is required, but you may decide to use both in
order to run `pytest` against a CPU or GPU environment.

A `heavyai` development environment can be setup with the following:

*********************
CPU Environment
*********************

.. code-block:: shell

   # clone heavyai repo
   git clone https://github.com/heavyai/heavyai.git && cd heavyai

   conda env create -f ./environment.yml

   # ensure you have activated the environment
   conda activate heavyai-dev

   # install pre-commit hooks
   make develop

*********************
GPU Environment
*********************

.. code-block:: shell

   # from the heavyai project root
   conda env create -f environment_gpu.yml

   # ensure you have activated the environment
   conda activate heavyai-gpu-dev

   # install pre-commit hooks
   make develop

At this point, you have everything you need to develop heavyai. However, to run the test suite, you need to be running
an instance of HeavyDB on the same machine you are devloping on. Heavy.AI provides `Docker`_ images that work great for this purpose.

------------------------
Docker Environment Setup
------------------------

*********************
HeavyDB Core CPU-only
*********************

Unless you are planning on developing GPU-specific functionality in heavyai, using the `CPU image`_ is enough to run the test suite:

.. code-block:: shell

   docker run \
     -d \
     --name heavyai \
     -p 6274:6274 \
     -p 6278:6278 \
     --ipc=host \
     -v /home/<username>/heavydb-storage:/heavydb-storage \
     omnisci/core-os-cpu

With the above code, we:
   * create/run an instance of HeavyDB Core CPU as a daemon (i.e. running in the background until stopped)
   * forward ports ``6274`` (binary connection) and ``6278`` (http connection).
   * set ``ipc=host`` for testing shared memory/IPC functionality
   * point to a local directory to store data loaded to HeavyDB. This allows our container to be ephemeral.

To run the test suite, call ``pytest`` from the top-level heavyai folder:

.. code-block:: shell

   (heavyai_dev) laptop:~/github_work/heavyai$ pytest

``pytest`` will run through the test suite, running the tests against the Docker container. Because we are using CPU-only, the
test suite skips the GPU tests, and you can expect to see the following messages at the end of the test suite run:

.. code-block:: shell

   =============================================== short test summary info ================================================
   SKIPPED [4] tests/test_data_no_nulls_gpu.py:15: No GPU available
   SKIPPED [1] tests/test_deallocate.py:34: No GPU available
   SKIPPED [1] tests/test_deallocate.py:54: deallocate non-functional in recent distros
   SKIPPED [1] tests/test_deallocate.py:67: No GPU available
   SKIPPED [1] tests/test_deallocate.py:80: deallocate non-functional in recent distros
   SKIPPED [1] tests/test_deallocate.py:92: No GPU available
   SKIPPED [1] tests/test_deallocate.py:105: deallocate non-functional in recent distros
   SKIPPED [2] tests/test_integration.py:207: No GPU available
   SKIPPED [1] tests/test_integration.py:238: No GPU available
   ================================== 69 passed, 13 skipped, 1 warnings in 19.40 seconds ==================================

************************
HeavyDB Core GPU-enabled
************************

To run the heavyai test suite with the GPU tests, the workflow is pretty much the same as CPU-only, except with the `HeavyDB Core
GPU-enabled`_ container:

.. code-block:: shell

   docker run \
     --runtime=nvidia \
     -d \
     --name heavyai \
     -p 6274:6274 \
     -p 6278:6278 \
     --ipc=host \
     -v /home/<username>/heavydb-storage:/heavydb-storage \
     omnisci/core-os-cuda

You also need to `install cudf`_ in your development environment. Because cudf is in active development, and requires attention
to the specific version of CUDA installed, we recommend checking the `cudf documentation`_ to get the most up-to-date
installation instructions.

-------------------------------
Updating Apache Thrift Bindings
-------------------------------

When the upstream `mapd-core`_ project updates its Apache Thrift definition file, the bindings shipped with
``heavyai`` need to be regenerated. Note that the `heavydb` repository must be cloned locally.

.. code-block:: shell

   # Clone the heavydb repository
   git clone https://github.com/heavyai/heavydb

   # Ensure you are at the root of the heavydb directory.
   cd ./heavydb

   # Use Thrift to generate the Python bindings
   thrift -gen py -r omnisci.thrift

   # Copy the generated bindings to the heavyai root
   cp -r ./gen-py/heavydb/* ../heavyai/heavydb/


--------------------------
Updating the Documentation
--------------------------

The documentation for heavyai is generated by ReadTheDocs on each commit. Some pages (such as this one) are manually created,
others such as the API Reference is generated by the docstrings from each method.

If you are planning on making non-trival changes to the documentation and want to preview the result before making a commit,
you need to install sphinx and sphinx-rtd-theme into your development environment:

.. code-block:: shell

   pip install sphinx sphinx-rtd-theme

Once you have sphinx installed, to build the documentation switch to the ``heavyai/docs`` directory and run ``make html``. This will update the documentation
in the ``heavyai/docs/build/html`` directory. From that directory, running ``python -m http.server`` will allow you to preview the site on ``localhost:8000``
in the browser. Run ``make html`` each time you save a file to see the file changes in the documentation.

--------------------------------
Publishing a new package version
--------------------------------

heavyai doesn't currently follow a rigid release schedule; rather, when enough functionality is deemed to be "enough" for a new
version to be released, or a sufficiently serious bug/issue is fixed, we will release a new version. heavyai is distributed via `PyPI`_
and `conda-forge`_.

Prior to submitting to PyPI and/or conda-forge, create a new `release tag`_ on GitHub (with notes), then run ``git pull`` to bring this tag to your
local heavyai repository folder.

****
PyPI
****

To publish to PyPI, we use the `twine`_ package via the CLI. twine only allows for submitting to PyPI by registered users
(currently, internal Heavy.AI employees):

.. code-block:: shell

   conda install twine
   python setup.py sdist
   twine upload dist/*

Publishing a package to PyPI is near instantaneous after runnning ``twine upload dist/*``. Before running ``twine upload``, be sure
the ``dist`` directory only has the current version of the package you are intending to upload.

***********
conda-forge
***********

The release process for conda-forge is triggered via creating a new version number on the heavyai GitHub repository. Given the
volume of packages released on conda-forge, it can take several hours for the bot to open a PR on heavyai-feedstock. There is
nothing that needs to be done to speed this up, just be patient.

When the conda-forge bot opens a PR on the heavyai-feedstock repo, one of the feedstock maintainers needs to validate the correctness
of the PR, check the accuracy of the package versions on the `meta.yaml`_ recipe file, and then merge once the CI tests pass.

.. _mapd-core: https://github.com/omnisci/mapd-core
.. _Docker: https://hub.docker.com/u/omnisci
.. _CPU image: https://hub.docker.com/r/omnisci/core-os-cpu
.. _HeavyDB Core GPU-enabled: https://hub.docker.com/r/omnisci/core-os-cuda
.. _install cudf: https://github.com/rapidsai/cudf#installation
.. _cudf documentation: https://rapidsai.github.io/projects/cudf/en/latest/
.. _commit: https://github.com/heavyai/heavyai/commit/28441055959e62443954a9826f1f03d876a1cfdb
.. _heavyai GitHub repository: https://github.com/heavyai/heavyai
.. _create a GitHub issue: https://github.com/heavyai/heavyai/issues
.. _pull requests: https://github.com/heavyai/heavyai/pulls
.. _PyPI: https://pypi.org/project/heavyai/
.. _conda-forge: https://github.com/conda-forge/heavyai-feedstock
.. _release tag: https://github.com/heavyai/heavyai/releases
.. _twine: https://pypi.org/project/twine/
.. _meta.yaml: https://github.com/conda-forge/heavyai-feedstock/blob/master/recipe/meta.yaml
