#!/usr/bin/env python
# coding=utf-8

from pyspark import SparkConf , SparkContext
import os

def aggregate(sc):
    seqOp = (lambda x , y : ( x[0] + y , x[1] + 1 ))
    comOp = (lambda x , y : ( x[0] + y[0] , x[1] + y[1] ))
    ret = sc.parallelize([1 ,2 ,3 ,4]).aggregate((0,0) , seqOp , comOp)
    if (ret == (10,4)):
        print("aggregate_test_ok")

def cartesian(sc):
    rdd = sc.parallelize([1 ,2])
    ret = sorted(rdd.cartesian(rdd).collect())
    if (ret[0] == (1,1)):
        print("cartesian_test_ok")

def glom(sc):
    rdd = sc.parallelize([1 ,2 ,3 ,4] , 2)
    ret = sorted(rdd.glom().collect())
    if(len(ret) == 2):
        print("glom_test_ok")

def coalesce(sc):

    rdd = sc.parallelize([1,2,3,4,5],3)
    ret1 = rdd.glom().collect()
    ret2 = rdd.coalesce(1).glom().collect()
    if( len(ret1) == 3  and len(ret2) == 1):
        print("coalesce_test_ok")

def cogroup(sc):
    x = sc.parallelize([ ("a" , 1) , ("b" , 4) ])
    y = sc.parallelize([ ("a" , 2) ])
    lst = sorted(list(x.cogroup(y).collect()))
    ret = [(x , tuple(map(list, y)))  for x,y in lst]
    if (ret[0][1][0] == [1]):
        print("cogroup_test_ok")

def collectAsMap(sc):
    m = sc.parallelize([(1,2), (3,4)]).collectAsMap()
    if(m[1] == 2 and m[3] == 4):
        print("collectAsMap_test_ok")

def combineByKey(sc):
    x = sc.parallelize([("a" , 1) , ("b" , 1) , ("a" , 2)])
    def to_list(a):
        return [a]
    def append(a, b):
        a.append(b)
        return a
    def extend(a, b):
        a.extend(b)
        return a
    ret = sorted(x.combineByKey(to_list , append , extend).collect())
    if (ret[0][1] == [1,2]):
        print("combineByKey_test_ok")

def countByKey(sc):
    rdd = sc.parallelize([("a" , 1) , ("b" , 1) , ("a" , 1)])
    ret = sorted(rdd.countByKey().items())
    if (ret[0][1] == 2):
        print("countByKey_test_ok")

def countByValue(sc):
    ret = sorted(sc.parallelize( [1,2,1,2,2] ,2  ).countByValue().items())
    if(ret[0][1] == 2):
        print("countByValue_test_ok")

def distinct(sc):
    ret = sorted( sc.parallelize( [1,2, 2, 2,1 ,3] ).distinct().collect() )
    if (len(ret) == 3):
        print("distinct_test_ok")

def filter(sc):
    rdd = sc.parallelize([1,2,3,4,5])
    ret = rdd.filter(lambda x : x % 2 == 0).collect()
    if (ret == [2, 4]):
        print("filter_test_ok")

def first(sc):
    ret = sc.parallelize([2,3]).first()
    if(ret == 2):
        print("first_test_ok")

def flatMap(sc):
    rdd = sc.parallelize([2,3,4])
    ret = sorted(rdd.flatMap( lambda x : range(1, x) ).collect())
    if (len(ret) == 6):
        print("flatMap_test_ok")

def flatMapValue(sc):
    rdd = sc.parallelize( [ ("a" , ["x" , "y" , "x"]) , ("b" , ["p" , "r"]) ] )
    def f(x) : return x
    ret = rdd.flatMapValue(f).collect()
    if (len(ret) == 6):
        print("flatMapValue_test_ok")

def fold(sc):
    from operator import add
    ret = sc.parallelize([1,2,3,4,5]).fold(0,add)
    if(ret == 15):
        print("fold_test_ok")

def foldByKey(sc):
    from operator import add
    rdd = sc.parallelize([ ("a" , 1) , ("b" , 1) , ("a" , 1) ])
    ret = sorted(rdd.foldByKey(0 ,add).collect())
    if ( ret[0][1] ==2 ):
        print("foldByKey_test_ok")

def getNumPartitions(sc):
    num = 3
    rdd = sc.parallelize([1,2,3,4,5,6] , num)
    ret = rdd.getNumPartitions()
    if(ret == num):
        print("getNumPartitions_test_ok")



if __name__ == '__main__':
    conf = SparkConf().setAppName("rdd_test_parallelize").setMaster("local")
    sc = SparkContext(conf=conf)
    aggregate(sc)
    cartesian(sc)
    cogroup(sc)
    collectAsMap(sc)
    combineByKey(sc) 
    countByKey(sc)
    countByValue(sc)
    distinct(sc)
    filter(sc)
    first(sc)
    flatMap(sc)
    flatMapValue(sc)
    fold(sc)
    foldByKey(sc)
    getNumPartitions(sc)

