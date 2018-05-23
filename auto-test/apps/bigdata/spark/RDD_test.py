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
    import __builtin__ 
    ret = [(x , tuple(__builtin__.map(list, y)))  for x,y in lst]
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

def f(x) : return x
def flatMapValue(sc):
    rdd = sc.parallelize( [ ("a" , ["x" , "y" , "x"]) , ("b" , ["p" , "r"]) ] )
    ret = rdd.flatMapValues(f).collect()
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


def groupBy(sc):
    rdd = sc.parallelize([1,1,2,3,5,8])
    result = rdd.groupBy(lambda x : x % 2 ).collect()
    ret = sorted( [ (x , sorted(y))    for x , y in result])
    if ( ret[0][1] == [2,8] ):
        print("groupBy_test_ok")

def groupByKey(sc):
    rdd = sc.parallelize([ ("a" , 1) , ("b" , 1) , ("a" , 1) ])
    ret = sorted(rdd.groupByKey().mapValues(len).collect())
    if (len(ret) == 2 and ret[0][1] == 2):
        print("groupByKey_test_ok")

def groupWith(sc):
    w = sc.parallelize([ ("a" , 5) , ("b" , 6) ])
    x = sc.parallelize([ ("a" , 1) , ("b" , 4) ])
    y = sc.parallelize([ ("a" , 2) ])
    z = sc.parallelize([ ("b" , 42) ])
    import __builtin__
    ret = [ (x , tuple(__builtin__.map(list , y))) for x , y in sorted(list(w.groupWith(x,y,z).collect() )) ]
    if (len(ret) == 2 and len(ret[0][1]) == 4):
        print("groupWith_test_ok")

def intersection(sc):
    rdd1 = sc.parallelize([1 , 10 ,2, 3, 4, 5])
    rdd2 = sc.parallelize([1 , 6, 2 ,3 ,7 ,8])
    ret = sorted(rdd1.intersection(rdd2).collect())
    if (ret == [1 ,2 ,3]):
        print("intersection_test_ok")

def keyBy(sc):
    x = sc.parallelize(range(0 ,3)).keyBy(lambda x : x * x )
    ret = x.collect()
    if(ret == [(0,0) , (1 ,1 ) , (4,2)]):
        print("keyBy_test_ok")

def keys(sc):
    m = sc.parallelize([(1,2) , (3,4)]).keys()
    ret = m.collect()
    if(ret == [1,3]):
        print("keys_test_ok")

def map(sc):
    rdd = sc.parallelize(["a" , "b" , "c"])
    ret = sorted(rdd.map(lambda x : (x , 1)).collect())
    if (ret[0] == ("a" , 1)):
        print("map_test_ok")

def mapPartitions(sc):
    rdd = sc.parallelize([1,2,3,4] , 2)
    def f(iter) : yield sum(iter)
    ret = rdd.mapPartitions(f).collect()
    if (len(ret) == 2):
        print("mapPartitions_test_ok")

def mapValues(sc):
    x = sc.parallelize([ ("a" , ["apple" , "banana" , "lemon"]) , ("b" , ["grapes"]) ])
    def f(x) : return len(x)
    ret = sorted(x.mapValues(f).collect())
    if ( ret[0] == ("a" , 3) ):
        print("mapValues_test_ok")

def partitionBy(sc):
    pairs = sc.parallelize([1,2,3,4,2,4,1]).map(lambda x : (x , x))
    sets = pairs.partitionBy(2).glom().collect()
    if (len(sets) == 2):
        print("partitionBy_test_ok")

def reduce(sc):
    from operator import add 
    rdd = sc.parallelize([1,2,3,4,5])
    ret = rdd.reduce(add)
    if( ret == 15 ):
        print("reduce_test_ok")

def reduceByKey(sc):
    from operator import add
    rdd = sc.parallelize([ ("a" , 1) , ("a" , 1) ])
    ret = rdd.reduceByKey(add).collect()
    if ( ret[0] == ("a" , 2)):
        print("reduceByKey_test_ok")

def repartition(sc):
    num = 2
    rdd1 = sc.parallelize([1,2,3,4,5,6] , num)
    rdd2 = rdd1.repartition(4)
    num2 = rdd2.getNumPartitions()
    if ( num2 == 4 ):
        print("repartition_test_ok")

def sortBy(sc):
    tmp = [('a', 1), ('b', 2), ('1', 3), ('d', 4), ('2', 5)]
    rdd = sc.parallelize(tmp)
    ret = rdd.sortBy(lambda x : x[0]).collect()
    ret2 = sorted(tmp)
    if (ret == ret2):
        print("sortBy_test_ok")
   

def take(sc):
    rdd = sc.parallelize([2,3,4,5,6])
    ret = rdd.take(1)
    if ( ret == [2] ):
        print("take_test_ok")

def zip(sc):
    x = sc.parallelize(range(0,5))
    y = sc.parallelize(range(1000,1005))
    ret = x.zip(y).collect()
    if( ret[0] == (0,1000) and len(ret) == 5):
        print("zip_test_ok")

def zipWithIndex(sc):
    rdd = sc.parallelize(["a" , "b"  , "c"])
    ret = rdd.zipWithIndex().collect()
    if( ret[0] == ("a" , 1) ):
        print("zipWithIndex_test_ok")

def boardcast(sc):
    bc = sc.boardcase([1,2,3,4])
    if(bc.value == [1,2,3,4]):
        print("boardcast_test_case")
    bc.unpersist()
    


if __name__ == '__main__':
    conf = SparkConf().setAppName("rdd_test_parallelize").setMaster("local")
    sc = SparkContext(conf=conf)
    aggregate(sc)
    glom(sc)
    coalesce(sc)
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
    groupBy(sc)
    groupByKey(sc)
    groupWith(sc)
    intersection(sc)
    keys(sc)
    keyBy(sc)
    map(sc)
    mapPartitions(sc)
    mapValues(sc)
    
    partitionBy(sc)


    reduce(sc)
    reduceByKey(sc)
    repartition(sc)
    sortBy(sc)
    take(sc)
    zip(sc)
    zipWithIndex(sc)
    boardcast(sc)
