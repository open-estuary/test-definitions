#!/usr/bin/python
# -*- coding: UTF-8 -*-

i = 1
while i < 10:
    i += 1
    if i%2 > 0:
        continue
    print i
else:
    print i, " is not less than 10"

if i < 10:
    print "error"
print "Good bye!"
