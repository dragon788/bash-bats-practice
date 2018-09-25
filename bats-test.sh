#!/usr/bin/env bash
# Don't use `-r test` because the test/libs directory has MANY tests from the bats* submodules
if [ $# -gt 0 ]; then ARGS="$@"; else ARGS="test/*.bats"; fi
# Run this file to run all the tests, once
docker run -it --rm -v "$(pwd):/opt/bats" --workdir /opt/bats bats/bats:latest $ARGS
