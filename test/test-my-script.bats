#!./test/libs/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

# setup() {
#   source my-script.sh
# }

@test "Should print help_menu if passed no arguments" {
  run bash my-script.sh
  echo '# status:' $status >&3
  echo '# output:' $output >&3
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
  echo '# status:' $status >&3
  echo '# output:' $output >&3
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
  echo '# status:' $status >&3
  echo '# output:' $output >&3
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "arg1" ]
  [[ "$output" =~ arg1 ]]
  assert_line "arg1"
}
