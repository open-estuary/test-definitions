#!/usr/bin/expect

# generate the public key fot itself
spawn ssh-keygen
expect "*id_rsa):"
send "\r"
expect "*passphrase):"
send "\r"
expect "*again:"
send "\r"
expect eof
