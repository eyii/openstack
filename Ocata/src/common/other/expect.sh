#!/usr/bin/expect
# Change a login shell to tcsh
set user [lindex $argv 0]
spawn chsh $user
expect "]:"
send "/bin/tcsh "
expect eof
exit