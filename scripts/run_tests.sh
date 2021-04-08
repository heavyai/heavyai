#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Get current script dir
# then resolve project root, one dir up
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
WORKDIR="$DIR/.."

cd "$WORKDIR"

usage() {
    local exitcode=0
    if [ $# != 0 ]; then
        echo "$*" >&2
        exitcode=1
    fi
    cat << EOF
Usage: $0 [OPTION]...
Run pyomnisci tests
Options:
  --db-image IMAGE_NAME         Required.
  --cpu-only                    Only build and test for CPU build.
  --gpu-only                    Only build and test for GPU build.
  -h, --help                    Print this help
EOF
    exit "$exitcode"
}

db_image= # docker image that hosts the OmniSciDB instance
db_container_name="pyomnisci-db" # name of container the db instances runs in
testscript_container_name="pyomnisci-test" # name of container the tests run in
test_image_name="pyomnisci_test" # image to run the tests in
cpu_only=0
gpu_only=0
rbc_only=0

# set docker image to run DB in
while [[ $# != 0 ]]; do
    case $1 in
    -h|--help) usage ;;
    --rbc-only) rbc_only=1 ;;
    --cpu-only) cpu_only=1 ;;
    --gpu-only) gpu_only=1 ;;
    --db-image) shift; db_image=$1 ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) usage "Unexpected argument: $1" ;;
    esac
    shift
done

cleanup() {
    docker rm -f $testscript_container_name &> /dev/null || true
    docker rm -f $db_container_name &> /dev/null || true
}

fatal() {
    echo "fatal: $*" >&2
    exit 1
}

error() {
    echo "error: $*" >&2
}

ready=1
if ! [[ "$db_image" ]]; then
    ready=
    error "Required parameter missing: CPU docker image. Specify it using --db-image"
fi

[[ "$ready" ]] || exit 1


create_docker_network() {
    # Create docker network
    # to share connection between
    # db container & test container
    docker network create net_pyomnisci || true
}

start_docker_db() {
    docker run \
        -d \
        --rm \
        -p 6273 \
        --ipc="shareable" \
        --network="net_pyomnisci" \
        --name $db_container_name \
        "$db_image" \
        bash -c "\
            /omnisci/startomnisci \
                --non-interactive \
                --data /omnisci-storage/data \
                --enable-runtime-udf \
                --enable-table-functions \
        "
}

build_test_image() {
    docker build --tag $test_image_name --file ./ci/Dockerfile .
}

test_pyomnisci() {
    # Forward args to build-conda.sh
    # --cpu-only
    # or
    # --gpu-only
    docker run \
        --rm \
        --ipc="container:${db_container_name}" \
        --interactive \
        --network="net_pyomnisci" \
        --workdir="/pyomnisci" \
        --env OMNISCI_HOST="${db_container_name}" \
        --name "${testscript_container_name}" \
        $test_image_name \
        /pyomnisci/ci/build-conda.sh "$*"
}

test_pyomnisci_rbc() {
    # Forward args to build-conda.sh
    # --cpu-only
    # or
    # --gpu-only
    docker run \
        --rm \
        --ipc="container:${db_container_name}" \
        --interactive \
        --network="net_pyomnisci" \
        --workdir="/pyomnisci" \
        --env OMNISCI_HOST="${db_container_name}" \
        --name "${testscript_container_name}_rbc" \
        $test_image_name \
        /pyomnisci/ci/test-rbc.sh
}

cleanup

build_test_image

create_docker_network

start_docker_db

if [[ gpu_only -eq 1 ]];then
    test_pyomnisci --gpu-only
fi

if [[ cpu_only -eq 1 ]];then
    docker ps
    docker logs $db_container_name

    test_pyomnisci --cpu-only

    docker logs $db_container_name
fi

if [[ rbc_only -eq 1 ]];then
    test_pyomnisci_rbc
fi

cleanup