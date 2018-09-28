#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# setup and teardown are global and run before/after each test
# only use them if you have something needed for every test,
# otherwise do your setup and run call and teardown BEFORE your assertions

# Use source if your script is just an 'include' in other scripts
# and doesn't call the functions itself

declare -g SCRIPT_UNDER_TEST="src/my-script.sh"
declare -g SCRIPTNAME="${SCRIPT_UNDER_TEST##*/}"
declare -gi BAD_USAGE=64

# setup() {
#   source $SCRIPT_UNDER_TEST
# }

# teardown() {
#   # temp_del file
#   if [ -h executable ]; then unlink executable; fi
# }

@test "Should print help_menu if passed no arguments" {
  run bash $SCRIPT_UNDER_TEST
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # printf '%s' "# output: $output" >&3
  # Should exit non-zero if no args
  [ "$status" -eq "$BAD_USAGE" ]
  # All these assert close to the same thing
  expected="Usage:"
  # This fails if the surrounding whitespace doesn't match
  [ "${lines[0]}" = "$expected" ]
  [ "${lines[1]}" = "$SCRIPTNAME" ]
  # This passes with surrounding whitespace
  [[ "$output" =~ $expected ]]
  # This fails if the surrounding whitespace doesn't match
  # This at least shows the output automatically so you can visually compare
  assert_line "$expected"
}

@test "Should print script name in help_menu" {
  run bash $SCRIPT_UNDER_TEST
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # echo '# output:' $output >&3
  # Should exit non-zero if no args
  [ "$status" -eq "$BAD_USAGE" ]
  # All these assert close to the same thing
  # This fails if the surrounding whitespace doesn't match
  [ "${lines[1]}" = "$SCRIPTNAME" ]
  # This passes with surrounding whitespace
  expected="$SCRIPTNAME"
  [[ "$output" =~ $expected ]]
  # This fails if the surrounding whitespace doesn't match
  # This at least shows the output automatically so you can visually compare
  assert_line "$SCRIPTNAME"
  # If the HEREDOC delimiter is quoted this shows up
  refute_line '${0##*/}'
  unset SCRIPTNAME
}

@test "Should print argument passed" {
  run bash $SCRIPT_UNDER_TEST arg1
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # echo '# output:' $output >&3
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "arg1" ]
  [[ "$output" =~ arg1 ]]
  assert_line "arg1"
}

@test "Should detect repository/directory name even if called via symlink" {
  SYMLINK=executable
  ln -s $SCRIPT_UNDER_TEST $SYMLINK
  run bash $SYMLINK
  unlink $SYMLINK
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # echo '# output:' $output >&3
  [ "$status" -eq 2 ]
  assert_line "executable"
  [ "${lines[0]}" = "executable" ]
}

@test "Should detect name called with via symlink" {
  SYMLINK=executable
  ln -s $SCRIPT_UNDER_TEST $SYMLINK
  run bash $SYMLINK
  unlink $SYMLINK
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # echo '# output:' $output >&3
  [ "$status" -eq 2 ]
  assert_line "$SYMLINK"
  #[ "${lines[1]}" = "$SCRIPTNAME" ]
  [ "${lines[0]}" = "$SYMLINK" ]
}

@test "Should return warning message when called with via symlink" {
  SYMLINK=warn
  ln -s $SCRIPT_UNDER_TEST $SYMLINK
  run bash $SYMLINK
  unlink $SYMLINK
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # echo '# output:' $output >&3
  [ "$status" -eq 2 ]
  assert_line "$SYMLINK"
  assert_line "$SYMLINK doesn't do anything"
  #[ "${lines[1]}" = "$SCRIPTNAME" ]
  [ "${lines[0]}" = "$SYMLINK" ]
}

# Have to unset trap if using `set -E`
@test "Should return failure/error message when error occurs" {
  SYMLINK=fail
  FAIL_STRING_REGEX='Attempted .* exited with .* at line'
  ln -s $SCRIPT_UNDER_TEST $SYMLINK
  run bash $SYMLINK
  unlink $SYMLINK
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # echo '# output:' $output >&3
  [ "$status" -eq 1 ]
  assert_line "$SYMLINK"
  [[ "$output" =~ $FAIL_STRING_REGEX ]]
  #[ "${lines[1]}" = "$SCRIPTNAME" ]
  [ "${lines[0]}" = "$SYMLINK" ]
}

@test "Should return failure/error message when called from unknown symlink" {
  SYMLINK=badguy
  FAIL_STRING_REGEX="isn't a known alias for this script"
  ln -s $SCRIPT_UNDER_TEST $SYMLINK
  run bash $SYMLINK
  unlink $SYMLINK
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # echo '# output:' $output >&3
  [ "$status" -eq 3 ]
  assert_line "$SYMLINK"
  [[ "$output" =~ $FAIL_STRING_REGEX ]]
  #[ "${lines[1]}" = "$SCRIPTNAME" ]
  [ "${lines[0]}" = "$SYMLINK" ]
}
