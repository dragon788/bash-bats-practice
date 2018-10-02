#!/bin/bash
set -EeTu -o pipefail
# https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html
# -E allows functions and subshells to inherit traps
#    this can cause trouble if you encounter an error inside your trap
# -e exits on the first failure after running any enabled trap functions
# -T If set, any trap on DEBUG and RETURN are inherited by shell functions, command substitutions, and commands executed in a subshell environment. The DEBUG and RETURN traps are normally not inherited in such cases.
# -u exits if any variables are unset (by the time they are referenced?)
# Testing for null/empty vars doesn't work if file isn't sourced in BATS setup() and has defaults declared for all allowed empty vars
# -o pipefail returns the exit code of commands on the left side of the pipe
#    rather than only the final command

# vars () {
# echo vars;
# }

# args () {
#   # This function assigns positional parameters to variables similar to parseargs/getopt
#   # Using a common prefix for required arguments so we can count them and
#   # then exit if not all required are passed, with list of required args and their order/positions
#   prefix=ARG
#   ARG_BUILD_ID=$1
#   ARG_AMI_TYPE=$2
#   ARG_AMI=$3
#   argvars=($(compgen -v "$prefix"))
#   declare -ga vars
#   for argvar in ${argvars[@]}; do vars+=(${argvar/ARG_/}=${!argvar}); done
#   echo $AMI_TYPE
#   echo $AMI
# }

#declare -fx help_menu
help_menu () {
  ## shopt -s extdebug
  ## # Location of the function
  ## # declare -F "$1"
  ## # Contents of the function
  ## declare -f "$1"
  ## shopt -u extdebug
	# For the HEREDOC to swallow whitespace it needs to be TABs, not mere spaces
  # If HEREDOC is quoted with " or ' it won't interpret variable correctly
  # Newline after Usage: is intentional and allows examining what name the script was called with to act accordingly
  # If expanded with all options avoid using subshells or variables as they will be executed/(un)resolved
  cat <<-ENDHELP
		Usage:
		${0##*/}
	ENDHELP
  exit 64
}

failwhale () {
  # Function accepts an exit code and optional message to print when triggering an early exit not due to abject failure caught by `set -e`
  errcode=$?
  # Unset trap otherwise errors within the trap function cause issues
  trap '' ERR
  # Set the failure message for trapping hard failures with a trace
  ERROR_MESSAGE="Attempted ${BASH_COMMAND} and exited with ${errcode} at line ${BASH_LINENO[0]}"
  MESSAGE=${ERROR_MESSAGE}
    # local frame=0
    # while caller $frame; do
    #   ((frame++));
    # done
    # echo "$*"
  # If forcefully triggering an exit take the first argument and override the errcode
  errcode=${1:-$errcode}
  # Replace ERROR_MESSAGE with passed in MESSAGE if present
  MESSAGE="${2:-$MESSAGE}"

  printf '%s' "${MESSAGE}"

  # This line allows the script to be sourced without killing the shell with `exit` on failure
  return $errcode 2> /dev/null || exit $errcode
}
# Don't trap EXIT, messes with sourcing?
trap failwhale ERR

where_am_i () {
  # readlink -e doesn't work on busybox but is WAY better than -f
  absolute_path=$(readlink -e -- "${BASH_SOURCE[0]}" && echo x) && absolute_path=${absolute_path%?x}
  dir=$(dirname -- "$absolute_path" && echo x) && dir=${dir%?x}
  file=$(basename -- "$absolute_path" && echo x) && file=${file%?x}
  ## All of the above operate on full/absolute paths
  # May want `readlink` on the `$BASH_SOURCE` to follow any symlinks
  # # Bash/POSIX parameter expansion alternative
  fullfile="${BASH_SOURCE[0]}"
  parent_dir="${fullfile%%/*}"
  filename="${fullfile##*/}"
  extension="${filename##*.}"
  filename_noextension="${filename%.*}"
}

# what_can_i_be () {
#   echo foo;
# }

check_args () {
  [ $# -ge "$required" ] || help_menu
}

what_am_i () {
  # If script is called via a symlink that expects a certain default action,
  # perform that action, otherwise show the usage menu
  CALLED_AS=${0##*/}
  case $CALLED_AS in
    $file) check_args "$@" ;;
    executable) echo $CALLED_AS; exit 2;;
    warn) echo $CALLED_AS; failwhale 2 "$CALLED_AS doesn't do anything" ;;
    fail) echo $CALLED_AS; cat not-a-file;;
    *) echo $CALLED_AS; failwhale 3 "$CALLED_AS isn't a known alias for this script";; # If this is false should trigger ERR exit
  esac
  if ! [ -z "${1}" ]; then echo $1; fi
  # RESULTX="$(help_menu; echo x$?)"
  # RETURNCODE=${RESULTX##*x}
  # RESULT="${RESULTX%x*}"
}

main () {
  where_am_i
  what_am_i $@
}

if [ "$BASH_SOURCE" == "$0" ]; then
  # Sourcing vs executing directly leads to different number of arguments
  required=1
  # We only want to execute automatically if run as a script, if included just set up the functions
  # This also makes testing via BATS much easier
  main "$@"
else
  required=0
fi
