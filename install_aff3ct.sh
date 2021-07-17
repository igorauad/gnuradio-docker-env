#!/bin/bash

cd /root/gr_prefix/src/
git clone --recursive https://github.com/aff3ct/aff3ct.git
cd aff3ct/
mkdir build && cd $_

# Build the shared and static libraries only (see
# https://github.com/aff3ct/my_project_with_aff3ct)
cmake .. -G"Unix Makefiles" \
	  -DCMAKE_INSTALL_PREFIX=/root/gr_prefix/ \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_CXX_FLAGS="-funroll-loops -march=native" \
	  -DAFF3CT_COMPILE_EXE="OFF" \
	  -DAFF3CT_COMPILE_STATIC_LIB="ON" \
	  -DAFF3CT_COMPILE_SHARED_LIB="ON"
make -j`nproc`
make install
