#!/bin/sh
set -e

export WORKDIR=`pwd`

apt update
apt install cmake g++ wget git bzip2 -y

export CC=gcc
export CXX=g++

export MINICONDA_VERSION="latest"
export MINICONDA_LINUX="Linux-x86_64"
export MINICONDA_OSX="MacOSX-x86_64"

wget "http://repo.continuum.io/miniconda/Miniconda3-$MINICONDA_VERSION-$MINICONDA_LINUX.sh" -O miniconda.sh;
bash miniconda.sh -b -u -p $WORKDIR/miniconda
export PATH="$WORKDIR/miniconda/bin:$PATH"
hash -r
conda config --set always_yes yes --set changeps1 no
conda update -q conda
conda install nlohmann_json pybind11 numpy pytest -c QuantStack -c conda-forge

export PY_EXE=`which python3`

# install xtl

cd xtl
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$WORKDIR/miniconda/
make install
cd $WORKDIR

# install xtensor

cd xtensor
mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$WORKDIR/miniconda/
make install -j16
cd $WORKDIR

# test xtensor-julia

julia -E "using Pkg; Pkg.add(PackageSpec(name=\"CxxWrap\", version=\"0.8.1\"))"
export JlCxx_DIR=$(julia -E "using CxxWrap; joinpath(dirname(pathof(CxxWrap)), \"..\", \"deps\", \"usr\", \"lib\", \"cmake\", \"JlCxx\")")
export JlCxx_DIR=${JlCxx_DIR//\"/}

cd xtensor-julia
mkdir build
cd build
cmake .. -DDOWNLOAD_GTEST=ON -DJlCxx_DIR=$JlCxx_DIR -DCMAKE_INSTALL_PREFIX=$WORKDIR/miniconda -DPYTHON_EXECUTABLE=$PY_EXE
make xtest -j16