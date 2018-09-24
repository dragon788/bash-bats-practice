#!./test/libs/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'
load 'libs/bats-file/load'

# setup and teardown are global and run before/after each test
# only use them if you have something needed for every test,
# otherwise do your setup and run call and teardown BEFORE your assertions

# Use source if your script is just an 'include' in other scripts
# and doesn't call the functions itself
# or include this around your `main` function
#
# if [ "$BASH_SOURCE" == "$0" ]; then
# # do script-y things here
# else
# # do include things here like calling an `init_vars` function
# fi

declare -g script_under_test="src/my-script.sh"

setup() {
  source $script_under_test
}

: <<-'ENDNOTES' # Keep quoted to avoid subshell comments from running
  # status/output are only applicable to `run` tests
  # These pollute the pretty output stream, but are fine in `--tap` mode
  # echo '# status:' $status >&3
  # echo '# output:' $output >&3
  # [ "$status" -eq 1 ]
  # assert_line "$script_under_test"
  # [ "${lines[1]}" = "$SCRIPTNAME" ]
  # Some failures in sourced commands result in no detected failure but no check mark so it isn't really passing
ENDNOTES

@test "Should detect directory name of script" {
  # Need to pre-declare all variables to avoid `set -u` failure
  # [ -z "$dir" ]
  where_am_i
  # echo '# dir: ' $dir >&3
  # $dir prints absolute path, we just care about the parent directory
  # echo '# parent_dir: ' $parent_dir >&3
  [[ "${dir##*/}" == "src" ]]
  [[ "${parent_dir}" == "src" ]]
  # [[ "$parent_dir" == "$script_under_test" ]]
  # [ "${lines[0]}" = "src" ]
}

