#!/usr/bin/env python
# coding=utf-8


import os
from pyspark import SparkConf , SparkContext 

conf = SparkConf().setAppName("wholeTextFiles_test").setMaster("local")
sc = SparkContext(conf = conf)



dirpath = os.path.join("." , "files")
if (not os.path.exists(dirpath)):
    os.mkdir(dirpath)

with open(os.path.join(dirpath,"1.txt") , 'w') as file1:
    _ = file1.write("1")
with open(os.path.join(dirpath , "2.txt") , "w") as file2:
    _ = file2.write("2")

testFiles = sc.wholeTextFiles(dirpath)

ret = sorted(testFiles.collect())
if ( len(ret) == 2 ):
    print("wholeTextFiles_test_ok")



