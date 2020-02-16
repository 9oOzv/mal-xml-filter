#!/usr/bin/env bash
D="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

function usage() {
    echo "$0 [-r|--reset]"
    exit 1
}

while [ $# -ge 1 ]; do
    case "$1" in
        -r|--reset)
            remove_conda
            shift
            ;;
        *)
            echo "invalid option '$1'"
            usage
            ;;
    esac
done



info() {
    echo "$@" >&2
}

echoerr() {
    echo "$@" >&2
}

err() {
    echoerr "$@"
    echo "1"
}

fatal() {
    echoerr "$@"
    exit 1
}


CONDA_PREFIX="$D/conda"
CONDA="$CONDA_PREFIX/bin/conda"
CONDA_ENVIRONMENT_YAML="$D/environment.yaml"
if [ -f "$CONDA_ENVIRONMENT_YAML" ]; then
    CONDA_ENV="$(cat "$CONDA_ENVIRONMENT_YAML" | egrep '^name:' | sed -E 's/name: ?//')"
else
    CONDA_ENV="env"
fi


function install_conda() {
    info "Downloading Miniconda."
    # wget's -O flag in order to prevent .1 .2 .3 etc. suffixes in case the dest exists
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda3-latest-Linux-x86_64.sh &> /dev/null || return $(err "Could not download conda")
    info "Installing Miniconda to ($CONDA_PREFIX)"
    bash Miniconda3-latest-Linux-x86_64.sh -p "$D/conda" -b > /dev/null   || return $(err "Could not install conda")
    rm Miniconda3-latest-Linux-x86_64.sh
}

function create_conda_env() {
    "$CONDA" create -y -y -n "$CONDA_ENV"      || return $(err "Could not create conda environment")
}


function activate_conda_env() {
    # Test before sourcing so we can return error instead of exiting the script
    . "$CONDA_PREFIX/bin/activate" "$CONDA_ENV"
    local current_env
    current_env="$(conda info | grep 'active environment' | sed 's/^ *active environment : //g')"
    if [ "$current_env" != "$CONDA_ENV" ]; then
        return 1
    fi
}


function remove_conda() {
    info "Removing conda ($CONDA_PREFIX)" 
    if [[ -d "$CONDA_PREFIX" ]] ; then
        rm -rf "$CONDA_PREFIX" || fatal "Could not remove $CONDA_PREFIX"
    fi
}


function reset_conda() {
    info "Resetting the conda environment"
    {
        remove_conda &&
        install_conda &&
        update_conda &&
        create_conda_env
    } || return 1
}


function update_conda() {
    "$CONDA" update -y -n base -c defaults conda || return $(err "Could not update conda")
}


function update_conda_env() {
    info "Updating the conda environment"
    if [ -f "$CONDA_ENVIRONMENT_YAML" ]; then
        "$CONDA" env update -n "$CONDA_ENV" -f "$CONDA_ENVIRONMENT_YAML"     || return $(err "Could not create conda environment")
    fi
}


function init_conda() {
    if [ -d "$CONDA_PREFIX" ]; then
        update_conda &&
        update_conda_env &&
        activate_conda_env || {
            echoerr "Conda/environment seems broken. Trying to reset it." &&
            reset_conda &&
            activate_conda_env
        } || return 1
    else
        info "No conda found in $CONDA_PREFIX. Installing it."
        {
            install_conda &&
            update_conda &&
            create_conda_env &&
            update_conda_env &&
            activate_conda_env
        } || return 1
    fi
}




if [ "$OPT_RESET" ]; then
    remove_conda_env || fatal "Could not remove the conda env"
fi
init_conda || fatal "Could not initialize the conda environment"

