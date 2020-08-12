#!/bin/sh
set -x

env

OS=$(uname -s)
if [ "$OS" = "Darwin" ]; then
    OS_LABEL=osx-64
else
    OS_LABEL=linux-64
fi

#####################################################################
# Get Miniconda
#####################################################################

if [ ! -d "${HOME}/miniconda3" ]; then
    MINICONDA_URL="https://repo.continuum.io/miniconda"
    if [ "$OS" = "Darwin" ]; then
        MINICONDA_FILE="Miniconda3-latest-MacOSX-x86_64.sh"
    else
        MINICONDA_FILE="Miniconda3-latest-Linux-x86_64.sh"
    fi
    if [ ! -f "${MINICONDA_FILE}" ]; then
        curl -L -O "${MINICONDA_URL}/${MINICONDA_FILE}"
    fi
    bash $MINICONDA_FILE -b -p "${HOME}/miniconda3"
fi

#####################################################################
# Activate and configure
#####################################################################

export CONDARC="$(pwd)/condarc"
export CONDA_ENVS_PATH="$(pwd)/condaenv"

source "${HOME}/miniconda3/bin/activate" root

conda config --file "${CONDARC}" --add channels conda-forge
conda config --file "${CONDARC}" --add channels astrorama
conda config --file "${CONDARC}" --add channels astrorama/label/develop

conda config --file "${CONDARC}" --set channel_priority flexible 

conda create --yes -n build
conda activate build

conda install --yes --quiet conda-build anaconda-client

#####################################################################
# Configure MacOSX SDK
#####################################################################

if [ "$OS" = "Darwin" ]; then
    echo "CONDA_BUILD_SYSROOT:" > $HOME/conda_build_config.yaml
    echo "    - $(xcrun --sdk macosx --show-sdk-path) # [osx]" >> $HOME/conda_build_config.yaml
    cat $HOME/conda_build_config.yaml
fi

#####################################################################
# Build
#####################################################################

if [ "$GIT_BRANCH" = "origin/master" ]; then
    LABELS="main"
else
    LABELS="${GIT_BRANCH#origin/}"
fi

if [ -n "${ANACONDA_TOKEN}" ]; then
    conda build --user "$ANACONDA_USER" --token "$ANACONDA_TOKEN" --label "$LABELS" ./recipe
else
    conda build --no-anaconda-upload ./recipe
fi
ls -lh

