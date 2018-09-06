#!/bin/bash
if [ $# -gt 0 ]; then ARGS="$@"; else ARGS="test/*.bats"; fi
# Run this file to run all the tests, once
./test/libs/bats/bin/bats $ARGS
