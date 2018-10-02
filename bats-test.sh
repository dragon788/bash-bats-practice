#!/usr/bin/env bash
# Don't use `-r test` because the test/libs directory has MANY tests from the bats* submodules
if [ $# -gt 0 ]; then ARGS="$@"; else ARGS="test/*.bats"; fi
# Run this file to run all the tests, once
# bats --pretty $ARGS
docker run -it --rm -v "$(pwd):/opt/bats" --workdir /opt/bats bats/bats:with-libs $ARGS

# Can save the below as ~/.local/bin/bats and make it executable for Docker magic
: <<-'DOCKERIZED'
#!/bin/bash
set -Eeu -o pipefail

[ $# -gt 0 ] && options_and_path="$@" || options_and_path="test"
docker run --rm -i -t \
		--name df-bats \
		-v $(pwd):/opt/bats \
		--workdir /opt/bats \
    --entrypoint bats \
		bats/bats:latest $options_and_path
DOCKERIZED
