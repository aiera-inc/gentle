#!/bin/bash

patch kaldi/src/configure configure_cuda10.patch

# Prepare Kaldi
cd kaldi/tools
make clean
make
./extras/install_openblas.sh

cd ../src
# make clean (sometimes helpful after upgrading upstream?)
./configure --static --static-math=yes --static-fst=yes --use-cuda=yes --openblas-root=../tools/OpenBLAS/install
make depend
cd ../../
