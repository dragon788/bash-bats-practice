# BATS practice
This repo will show the progression of building up a Bash script using BATS to
ensure things work as desired and refactoring doesn't cause changes in behavior.

## Running the tests

    git clone <this_repo>
    git submodule update --init --recursive
    ./bats-test.sh

## Developing new features/tests

    git clone <this_repo>
    git submodule update --init --recursive
    ./bats-dev.sh

## Making your own practice repo

    mkdir ~/bats-practice
    cd ~/bats-practice
    git init
    mkdir -p test/libs
    git submodule init https://github.com/bats-core/bats-core  test/lib/bats
    git submodule init https://github.com/ztombol/bats-support test/lib/bats-support
    git submodule init https://github.com/ztombol/bats-assert test/lib/bats-assert
    git submodule init https://github.com/ztombol/bats-file test/lib/bats-file
    git submodule init https://github.com/grayhemp/bats-mock test/lib/bats-mock

## References

This post was a good starter to using BATS with practical examples, though it doesn't have the more recently updated bats-core instead of sstephenson/bats.
https://medium.com/@pimterry/testing-your-shell-scripts-with-bats-abfca9bdc5b9
