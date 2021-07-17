#!/bin/bash

cd /root/gr_prefix/src/

# Check out the library.
git clone https://github.com/google/benchmark.git

# Benchmark requires Google Test as a dependency. Add the source tree as a
# subdirectory.
git clone https://github.com/google/googletest.git benchmark/googletest

# Go to the library root directory
cd benchmark

# Make a build directory to place the build output.
cmake -E make_directory "build"

# Generate build system files with cmake.
cmake -E chdir "build" cmake ../ \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCMAKE_INSTALL_PREFIX=/root/gr_prefix/

# Build the library.
cmake --build "build" --config Release

# Run the tests
cmake -E chdir "build" ctest --build-config Release

# Install
cmake --build "build" --config Release --target install
