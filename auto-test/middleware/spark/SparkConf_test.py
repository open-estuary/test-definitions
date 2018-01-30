#!/usr/bin/env python
# coding=utf-8

from pyspark import SparkConf , SparkContext
    
 
if __name__ == '__main__':
    conf = SparkConf().setAppName("spark_conf_test").setMaster("local")
    sc = SparkContext(conf=conf)

    rdd1 = sc.para
