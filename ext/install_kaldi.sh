#!/bin/bash

# Prepare Kaldi
cd kaldi/tools
make clean
make
./extras/install_openblas.sh
cd ../src
# make clean (sometimes helpful after upgrading upstream?)
./configure --static --static-math=yes --static-fst=yes --use-cuda=yes --cudatk-dir=/usr/local/cuda --openblas-root=../tools/OpenBLAS/install
make depend
cd ../../
