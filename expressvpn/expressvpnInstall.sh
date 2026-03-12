#!/usr/bin/expect -f
set timeout 30
spawn /usr/bin/sh /tmp/$env(APP)
expect -re "Is this ok.*"
send "y\r"
expect eof
