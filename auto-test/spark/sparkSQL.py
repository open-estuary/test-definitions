#!/usr/bin/env python
# coding=utf-8

import os
from pyspark import SparkConf , SparkContext
from pyspark.sql import SparkSession ,Row , SQLContext 
from pyspark.sql.types import * 


def createDataFrame(session):
    lst = [("alice" , 1)]
    ret = session.createDataFrame(lst).collect()
    if(ret == [Row(_1=u"alice" , _2=1)]):
        print("createDataFrameFromList_test_ok")

    rdd = session.sparkContext.parallelize(lst)
    ret = session.createDataFrame(rdd).collect()
    if(ret == [Row(_1=u"alice" , _2=1)]):
        print("createDataFrameFromRDD_test_ok")

    ret = session.createDataFrame(rdd , ["name" , "age"]).collect()
    if(ret[0].name == u"alice"):
        print("createDataFrameListSchema_test_ok")

    Person = Row("name" , "age")
    person = rdd.map(lambda x : Person(*x))
    ret = session.createDataFrame(person).collect()
    if(ret[0].name == u"alice"):
        print("createDataFrameUseRowSchema_test_ok")

    schema = StructType([
        StructField("name" , StringType() , True),
        StructField("age" , StringType() , True)
    ])
    ret = session.createDataFrame(rdd,schema).collect()
    if(ret[0].name == u"alice" ):
        print("createDataFrameUseStructType_test_ok")

def range(session):
    ret = session.range(1,7,2).collect()
    if(ret[0] == Row(id=1)):
        print("range_test_ok")

def registerFunction(session):
    sc = session.sparkContext 
    sqlContext = SQLContext.getOrCreate(sc) 
    sqlContext.registerFunction("strLen" , lambda x : len(x))
    ret = sqlContext.sql("select strLen('test')").collect()
    if ( ret[0].asDict().values() == ['4'] ):
        print("registerFunction_test_ok")

if __name__ == '__main__':
    session = SparkSession.builder \
            .appName("sparksql") \
            .getOrCreate()
    if (isinstance(session , SparkSession)):
        print("SparkSession_test_ok")

    createDataFrame(session) 
    range(session)
    registerFunction(session)
