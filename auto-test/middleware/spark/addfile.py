#!/usr/bin/env python
# coding=utf-8

import os
from pyspark import SparkFiles , SparkConf , SparkContext

conf = SparkConf().setAppName("addfile_test").setMaster("local")
sc = SparkContext(conf = conf)

path = os.path.join("." , "test.txt")
with open(path , "w") as testFile:
    _ = testFile.write("100")

sc.addFile(path)
def func(iterator):
    with open(SparkFiles.get("test.txt")) as testFile:
        fileVal = int(testFile.readline())
        return [x * fileVal for x in iterator]

lst = sc.parallelize([1 , 2 , 3 ,4 ]).mapPartitions(func).collect()
lst2 = [ 100 ,200 ,300 ,400 ]
if ( lst == lst2 ):
    print("addfile_test_ok")

