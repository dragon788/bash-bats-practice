#!./test/libs/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/bats-file/load'

# setup and teardown are global and run before/after each test
# only use them if you have something needed for every test,
# otherwise do your setup and run call and teardown BEFORE your assertions

# Use source if your script is just an 'include' in other scripts
# and doesn't call the functions itself

# setup() {
#   source my-script.sh
# }

# teardown() {
#   # temp_del file
#   if [ -h executable ]; then unlink executable; fi
# }

@test "Should print help_menu if passed no arguments" {
  run bash my-script.sh
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # echo '# output:' $output >&3
  # Should exit non-zero if no args
  [ "$status" -eq 1 ]
  # All these assert close to the same thing
  # This fails if the surrounding whitespace doesn't match
  [ "${lines[0]}" = "Usage:" ]
  # This passes with surrounding whitespace
  expected="Usage:"
  [[ "$output" =~ $expected ]]
  # This fails if the surrounding whitespace doesn't match
  # This at least shows the output automatically so you can visually compare
  assert_line "Usage:"
}

@test "Should print script name in help_menu" {
  SCRIPTNAME=my-script.sh
  run bash $SCRIPTNAME
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # echo '# output:' $output >&3
  # Should exit non-zero if no args
  [ "$status" -eq 1 ]
  # All these assert close to the same thing
  # This fails if the surrounding whitespace doesn't match
  [ "${lines[1]}" = "$SCRIPTNAME" ]
  # This passes with surrounding whitespace
  expected="$SCRIPTNAME"
  [[ "$output" =~ $expected ]]
  # This fails if the surrounding whitespace doesn't match
  # This at least shows the output automatically so you can visually compare
  assert_line "$SCRIPTNAME"
  # If the HEREDOC begin is quoted this shows up
  refute_line '${0##*/}'
}

@test "Should print argument passed" {
  run bash my-script.sh arg1
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # echo '# output:' $output >&3
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "arg1" ]
  [[ "$output" =~ arg1 ]]
  assert_line "arg1"
}
