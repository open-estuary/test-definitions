#!/usr/bin/env python
# coding=utf-8

from pyspark import SparkConf , SparkContext
class spark_conf_test(object):
    def __init__(self):
        conf = SparkConf().setAppName("spark_conf_test").setMaster("local")
        self.sc = SparkContext(conf=conf)

    def appName(self):
        ret = false
        if ( sc.appName == "spark_conf_test"):
            ret = true 

        return ret 
    
 
if __name__ == '__main__':
    conf = spark_conf_test()
    if(conf.appName():
        print("SparkConfGetAppName")
