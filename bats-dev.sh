#!/bin/bash
hash entr 2>&1 >/dev/null || { echo "Please install entr package for file monitoring"; exit 1; }
# Run this file (with 'entr' installed) to watch all files and rerun tests on changes
ls -d **/* | entr ./bats-test.sh
