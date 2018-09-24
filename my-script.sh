#!/bin/bash
set -Eeu -o pipefail
# -E allows functions and subshells to inherit traps
# -e exits on the first failure after running any enabled trap functions
# -u exits if any variables are unset (by the time they are referenced?)
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


main () {
[ $# -gt 0 ] || { help_menu; exit 1; }

echo $1
}

main "$@"
