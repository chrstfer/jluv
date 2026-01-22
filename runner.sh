#!/usr/bin/env bash

# This file mainly just documents what i had to do to get this to work.

# Note also that this way (adding a login node to the compose cluster) would have probably worked easier.
# https://discourse.jupyter.org/t/jupyter-notebook-sockets/14716
# I found that link pretty early, if I'd actually read it more deeply I may not have wasted the afternoon.

# the --userns and --groupns options also sort of seem to have potential

# CONTAINER_NAME="jluv-dev"
# IMAGE_NAME="jluv-dev"

build_container_image () {
    podman build -t "${IMAGE_NAME}":latest jupyterlab-uv-podman/
}

create_container () {
    podman create  --name "${CONTAINER_NAME}" --replace -v "$PWD/sockets:/home/jluv/.sockets" -v "$PWD/notebooks:/home/jluv/notebooks" "$IMAGE_NAME":latest
}

fix_dir_permissions () {
    chmod -R g+s sockets/
    chmod -R g+s notebooks/

    podman unshare chown -R 1000 sockets/
    podman unshare chown -R 1000 notebooks/
}

run_container () {
    podman start "${CONTAINER_NAME}" # if first run, wait until finished startup before next step
}

fix_run_permissions () {
    podman unshare chmod 660 sockets/jupyterlab-server.sock
}

container_logs () {
    podman logs "${CONTAINER_NAME}"
}

# Option string:
# -b build
# -c create
# -dp dir perms
# -rp run perms
# -r run
# -i|--image-name
# -n|--container-name

SCRIPT_TASK="run_container"
PARAMETERS=""
while (( "$#" )); do
    [[ $1 == --*=* ]] && set -- "${1%%=*}" "${1#*=}" "${@:2}" && SHIFT=2 && echo "$1" "$2"
    case "$1" in
        -b) 
            SCRIPT_TASK="build_container_image"
            shift
            ;;
        -c)
            SCRIPT_TASK="create_container"
            shift
            ;;
        -dp)
            SCRIPT_TASK="fix_dir_permissions"
            shift
            ;;
        -rp)
            SCRIPT_TASK="fix_run_permissions"
            shift
            ;;
        -r)
            SCRIPT_TASK="run_container"
            shift
            ;;
        -l)
            SCRIPT_TASK="container_logs"
            shift
            ;;
        -i|--image-name)
            IMAGE_NAME=$2
            shift "$SHIFT"
            ;;
        -n|--container-name)
            CONTAINER_NAME=$2
            shift "$SHIFT"
            ;;
        *)
            PARAMETERS+=("$1")
            shift
            if [[ "$#" -eq 0 ]]; then
                CONTAINER_NAME="${CONTAINER_NAME:-${PARAMETERS[*]}}"
            fi
            ;;
    esac
    SHIFT=1
done

CONTAINER_NAME="${CONTAINER_NAME:-jluv-dev}"
IMAGE_NAME="${IMAGE_NAME:-jluv-dev}"

echo "$SCRIPT_TASK with: image name: ${IMAGE_NAME}, container name: ${CONTAINER_NAME}"

$SCRIPT_TASK

# while getopts "bcpr" opt; do
#     case $opt in
#         b) 
#             SCRIPT_TASK="build_container"
#             ;;
#         c)
#             SCRIPT_TASK="create_container"
#             ;;
#         p)
#             SCRIPT_TASK="fix_permissions"
#             ;;
#         r)
#             SCRIPT_TASK="run_container"
#             ;;
#         \?) # Handle invalid options
#             echo "Invalid option: -$OPTARG" >&2
#             exit 1
#             ;;
#     esac
# done

