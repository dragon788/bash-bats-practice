#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

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

get_funcky () {
  # Bash 4+ hella magic!
  # mapfile -t my_array < <( my_command )
  # otherwise loop
  # my_array=()
  # while IFS= read -r line; do
  #   my_array+=( "$line" )
  # done < <( my_command )
  # I call this, find_functions!
  mapfile -t FUNCTIONS < <(grep -v '^#' $script_under_test | grep '.*()' | awk '{print $1}')
  echo "# ${FUNCTIONS[@]}" >&3
}

setup() {
  source $script_under_test
}

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

