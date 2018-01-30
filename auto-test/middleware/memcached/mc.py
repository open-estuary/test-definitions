#! /usr/bin/python
import memcache
import sys
import os
def set_operater(mc):
	res=mc.set("key" , "testConn")
	if res:
		os.system("lava-test-case 'memcache_connect' --result pass")
	else:
		os.system("lava-test-case 'memcache_connect' --result fail")

	res=mc.add("addkey" , "addvalue")
	if res:
		os.system("lava-test-case 'memcache_add' --result pass")
	else:
		os.system("lava-test-case 'memcache_add' --result fail  ")
	
	res=mc.append("addkey" ,"append")
	res1=mc.append("notexist" , "false")
	if res and (not res1):
		os.system("lava-test-case 'memcache_append' --result pass")
	else:
		os.system("lava-test-case 'memcache_append' --result fail  ")

	res=mc.set_multi({"key1":"value1", "key2":"value2"})
	if res:
		os.system("lava-test-case 'memcache_set_multi' --result fail")
	else:
		os.system("lava-test-case 'memcache_set_multi' --result pass")

def get_operater(mc):
	res=mc.get('key')		
	if res == "testConn":
		os.system("lava-test-case 'memcache_get' --result pass")
	else:
		os.system("lava-test-case 'memcache_get' --result fail")

	res=mc.gets("key")
	res1=mc.gets("keynotexist")
	if (res =="testConn") and (not res1):
		os.system("lava-test-case 'memcache_gets' --result pass")
	else:
		os.system("lava-test-case 'memcache_gets' --result fail")
	
	res=mc.get_multi(['key1','key'])
	if res == { 'key1':'value1' , 'key':'testConn' }:
		os.system("lava-test-case 'memcache_get_multi' --result pass")
	else:
		os.system("lava-test-case 'memcache_get_multi' --result fail")
def incr_operater(mc):
	mc.set("inc",1)
	mc.set("dec",10)
	res=mc.incr("inc")
	if res == 2:
		os.system("lava-test-case 'memcache_incr' --result pass")
	else:
		os.system("lava-test-case 'memcache_incr' --result fail")
	res=mc.decr("dec")
	if res == 9:
		os.system("lava-test-case 'memcache_decr' --result pass")
	else:
		os.system("lava-test-case 'memcaceh_decr' --result fail")

def delete_operater(mc):
	mc.delete("inc")
	res=mc.get("inc")
	if res:
		os.system("lava-test-case 'memcache_delete' --result fail")
	else:
		os.system("lava-test-case 'memcache_delete' --result pass")
	mc.delete_multi(['key','dec'])
	res1=mc.get("key")
	res2=mc.get("dec")
	if (not res1) and (not res2):
		os.system("lava-test-case 'memcache_delete_multi' --result pass " )
	else:
		os.system("lava-test-case 'memcache_delete_multi' --result fail")	
	
def flush_operater(mc):
	mc.flush_all()
	res=mc.get("key")
	if res:
		os.system("lava-test-case 'memcache_flush_all' --result fail")
	else:
		os.system("lava-test-case 'memcache_flush_all' --result pass")

if __name__=='__main__':    
	mc=memcache.Client(['localhost:11211'] , debug=0)
	flush_operater(mc)
	set_operater(mc)
	get_operater(mc)
	incr_operater(mc)
	delete_operater(mc)

