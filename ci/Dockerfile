    # docker run \
    #     --rm \
    #     -it \
    #     -v $PWD:/pymapd \
    #     --workdir="/pymapd" \
    #     --name test_omnisci \
    #     omnisci/core-os-cpu-dev:master \
    #     /bin/bash
FROM condaforge/linux-anvil-comp7

COPY . /pyomnisci/

# ENTRYPOINT /pyomnisci/ci/build-conda.sh