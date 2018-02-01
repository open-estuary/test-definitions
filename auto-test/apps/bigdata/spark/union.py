#!/usr/bin/env python
# coding=utf-8


import os
from pyspark import SparkConf , SparkContext

conf = SparkConf().setAppName("unoin_test").setMaster("local")
sc = SparkContext(conf = conf)

path = os.path.join("." , "unoin_test.txt")
with open(path , "w") as testFile:
    _ = testFile.write("Hello")

testFile = sc.textFile(path)
ret = testFile.collect()
if ( ret == "Hello" ):
    print("testFile_test_ok")

para = sc.parallelize(["World"])
str2 = sorted(sc.union([testFile , para]).collect())
str1 = [u'Hello' , 'World']

if (str1 == str2):
    print("union_test_ok")
