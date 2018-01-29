#!/usr/bin/python
# -*- coding: UTF-8 -*-
import json

# dump
data = [ { 'a' : 1, 'b' : 2, 'c' : 3, 'd' : 4, 'e' : 5  }  ]
djson = json.dumps(data)
print djson

#load
jsonData = '{"a":5,"b":4,"c":3,"d":2,"e":1}';
text = json.loads(jsonData)
print text


