#!/usr/bin/env python
# coding=utf-8


import plyvel
import os
db = plyvel.DB('/tmp/testdb/', create_if_missing=True)
os.system("l")
