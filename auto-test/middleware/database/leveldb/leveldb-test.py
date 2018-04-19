#!/usr/bin/env python
# coding=utf-8


import plyvel
import os

try:
    db = plyvel.DB('/tmp/testdb/', create_if_missing=True)
except Exception:
    ret="fail"
else:
    ret="pass"
if(ret == "pass"):
    os.system("lava-test-case 'leveldb_create_database' --result pass")
else:
    os.system("lava-test-case 'leveldb_create_database' --result fail")
try:
    db.put(b'key' , b'value')
    db.put(b'another-key' , b'another-value')
except Exception:
    os.system("lava-test-case 'leveldb_set_value' --result fail")
else:
    os.system("lava-test-case 'leveldb_set_value' --result pass")

key=db.get('key')
if (key == 'value'):
    os.system("lava-test-case 'leveldb_get_value' --result pass")
else:
    os.system("lava-test-case 'leveldb_get_value' --result fail")

db.delete(b'key')
db.delete(b'another-key')
key=db.get(b'key',"empty")
if (key == "empty"):
    os.system("lava-test-case 'leveldb_delete_key' --result pass")
else:
    os.system("lava-test-case 'leveldb_delete_key' --result fail")

try:
    wb=db.write_batch()
    for i in xrange(1000):
        wb.put(bytes(i) , bytes(i) * 1000)
    wb.write()
except Exception:
    os.system("lava-test-case 'leveldb_write_batch_op' --result fail")
else:
    os.system("lava-test-case 'leveldb_write_batch_op' --result pass")

db.put(b'key' , b'first-value')
sn = db.snapshot()
snkey = sn.get(b'key')
db.put(b'key' , b'second-value')
snkey2 = sn.get(b'key')
if (snkey == snkey2):
    os.system("lava-test-case 'leveldb_snapshot_op' --result pass")
else :
    os.system("lava-test-case 'leveldb_snapshot_op' --result fail")

try :
    sn.close()
except Exception:
    os.system("lava-test-case 'leveldb_close_snapshot_op' --result fail")
else :
    os.system("lava-test-case 'leveldb_close_snapshot_op' --result pass")

db.put(b'key-1', b'value-1')
db.put(b'key-2', b'value-2')
db.put(b'key-3', b'value-3')
db.put(b'key-4', b'value-4')
db.put(b'key-5', b'value-5')
db.put(b'key-6', b'value-6')
db.put(b'key-7', b'value-7')

try :
    for key,value in db:
        print(value)
        pass
except Exception:
    os.system("lava-test-case 'leveldb_iteration_op' --result fail")
else :
    os.system("lava-test-case 'leveldb_iteration_op' --result pass")

db.close()
if(db.closed):
    os.system("lava-test-case 'leveldb_close_database' --result pass")
else :
    os.system("lava-test-case 'leveldb_close_database' --result fail")



