#!/usr/bin/env python
# coding=utf-8


import threading
from time import sleep
from pyspark import SparkConf , SparkContext 

conf = SparkConf().setAppName("cancelJobGroup").setMaster("local")
sc = SparkContext(conf = conf)

result = "Not_Set"
lock = threading.Lock()
def map_func(x):
    sleep(200)
    raise Exception("Task_should hacve been cancelled")
def start_job(x):
    global result
    try:
        sc.setJobGroup("job_to_cancel" , "some description")
        result = sc.parallelize(range(x)).map(map_func).collect()
    except Exception as e:
        result = "cancelJobGroup_test_ok"
    lock.release()

def stop_job():
    sleep(5)
    sc.cancelJobGroup("job_to_cancel")

supress = lock.acquire()
supress = threading.Thread(target = start_job , args = (10,)).start()
supress = threading.Thread(target = stop_job).start()

supress = lock.acquire()
print(result)




        
