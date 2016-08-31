#!/usr/bin/expect

set timeout 600
set mysql_password [lindex $argv 0]

spawn mysqladmin -uroot password

expect {
    "error" { expect eof }
    "New password"
    {
        send "$mysql_password\r"
        expect "Confirm new password"
        send "$mysql_password\r"
        expect eof
    }
}
