#!/bin/bash
set -e

# Assuming GNU Radio is installed on a volume (i.e., not part of the image),
# update the dynamic linker's run-time bindings on initialization
ldconfig

exec "$@"
