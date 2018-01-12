#!/usr/bin/env python
# coding=utf-8

from pyspark import SparkConf , SparkContext
import os
class rdd_test(object):
    def __init__(self):
        conf = SparkConf().setAppName("rdd_test_parallelize").setMaster("local")
        self.sc = SparkContext(conf=conf)

    def rdd_test_parallelize(self):
        data = [ 1 ,3 ,4  ,6 ]
        distData = self.sc.parallelize(data)
        list = distData.collect()
        print(list)

    def rdd_test_file(self):
        os.system("echo 'aaa\nbbb' > file.tmp")
        lines = self.sc.textFile("file.tmp")
        lineLengths = lines.map(lambda a : len(a))
        total = lineLengths.reduce(lambda  a , b : a + b)
        if(total == 6):
            print("rdd_test_file is ok")
        print(total)
     

if __name__ == '__main__':
    
    rdd = rdd_test()
    
    rdd.rdd_test_parallelize()
    rdd.rdd_test_file
