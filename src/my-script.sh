#!/bin/bash
set -Eeu -o pipefail
# -E allows functions and subshells to inherit traps
# -e exits on the first failure after running any enabled trap functions
# -u exits if any variables are unset (by the time they are referenced?)
# Testing for null/empty vars doesn't work if file isn't sourced in BATS setup() and has defaults declared for all allowed empty vars
# -o pipefail returns the exit code of commands on the left side of the pipe
#    rather than only the final command

help_menu () {
	# For the HEREDOC to swallow whitespace it needs to be TABs, not mere spaces
  # If HEREDOC is quoted with " or ' it won't interpret the variable correctly
  # Newline after Usage: is intentional and allows examining what name the script
  #   was called with to act accordingly
  cat <<-ENDHELP
		Usage:
		${0##*/}
	ENDHELP
}

where_am_i () {
  # readlink -f doesn't work on all platforms but this invocation should
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

what_am_i () {
  # Sourcing vs executing directly leads to different numbers of arguments
  [[ "$0" != "$BASH_SOURCE" ]] && required=0 || required=1
  CALLED_AS=${0##*/}
  case $CALLED_AS in
    executable) echo $0; exit 2 ;;
    *) [ $# -ge "$required" ] ;; # If this is false should trigger ERR exit
  esac
}

failwhale () {
  # Function accepts a message to print when triggering an early exit not due to failure
  errcode=$?
  # No sense trapping ourselves
  trap - EXIT
  MESSAGE=${1:-}
  # ERROR_MESSAGE="Attempted ${BASH_COMMAND} and exited with ${errcode} at line ${BASH_LINENO[0]}"
  #[ ! $errcode -eq 0 ] && MESSAGE=${ERROR_MESSAGE}
  echo "${MESSAGE}"

  help_menu
  # This line allows the script to be sourced without killing the shell with `exit` on failure
  return $errcode 2> /dev/null || exit $errcode
}
# Don't trap EXIT, messes with sourcing?
trap failwhale ERR

main () {
  where_am_i
  what_am_i $@
  # If script is called via a symlink that expects a certain default action,
  # perform that action, otherwise show the usage menu
  if [ -n "$1" ]; then echo $1; fi
}

if [ "$BASH_SOURCE" == "$0" ]; then
  # We only want to execute automatically if run as a script, if included just set up the functions
  # This also makes testing via BATS much easier
  main "$@"
fi
