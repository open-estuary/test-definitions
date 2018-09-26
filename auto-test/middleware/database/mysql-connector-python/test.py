#import MySQLdb
import mysql.connector
config={'host':'127.0.0.1',
        'user':'root',
        'password':'root',
        'port':3306 ,
        'database':'mysql',
        'charset':'utf8'
}

try:
   cnn = mysql.connector.connect(**config)
   #cnn=MySQLdb.connect(**config)
   print('success connect mysql') 
except mysql.connector.Error as e:
   print('connect fails!{}'.format(e))

cursor = cnn.cursor()
 
sql_create_db="create database test"
try:
   cursor.execute(sql_create_db)
   print('success create test database')  
except mysql.connector.Error as e:
   print('use test database fails!{}'.format(e))  


sql_choose_db="use test"
try:
    cursor.execute(sql_choose_db)
    print('success choose database')
except mysql.connector.Error as e:
    print('choose database fails!{}'.format(e))


sql_create_table="CREATE TABLE student( \
id int(10) NOT NULL AUTO_INCREMENT, \
name varchar(10) DEFAULT NULL, \
age int(3) DEFAULT NULL, \
PRIMARY KEY (id))ENGINE=InnoDB DEFAULT CHARSET=utf8"
try:
   cursor.execute(sql_create_table)
   print('success create test table')  
except mysql.connector.Error as e:
   print('create test table fails!{}'.format(e))  


try:
   sql_insert1="insert into student (name, age) values ('orange', 20);"
   cursor.execute(sql_insert1)
   sql_insert2="insert into student (name, age) values (%s, %s);"
   data=('shiki',25)
   cursor.execute(sql_insert2,data)
   sql_insert3="insert into student (name, age) values (%(name)s, %(age)s);"
   data={'name':'mumu','age':30}
   cursor.execute(sql_insert3,data)
   print('success insert data')
except mysql.connector.Error as e:
   print('insert datas error!{}'.format(e))


try:
  sql_query='select id,name,age from student'
  cursor.execute(sql_query)
  for id,name,age in cursor:
    print ("%s's id is %d,age is %d"%(name,id,age))
  print('success select data')
except mysql.connector.Error as e:
  print('query error!{}'.format(e))


try:
  sql_query="update student set age=29 where name='mumu'"
  cursor.execute(sql_query)
  print('success update data')
except mysql.connector.Error as e:
  print('query error!{}'.format(e))


try:
  sql_delete='delete from student where name = %(name)s and age < %(age)s'
  data={'name':'orange','age':24}
  cursor.execute(sql_delete,data)
  print('success delete data')
except mysql.connector.Error as e:
  print('delete error!{}'.format(e))

#try:
#  sql_query='select id,name,age from student'
#  cursor.execute(sql_query)
#  for id,name,age in cursor:
#    print ("%s's id is %d,age is %d"%(name,id,age))
#except mysql.connector.Error as e:
#  print('query error!{}'.format(e))
sql_drop_table="drop table student"
try:
   cursor.execute(sql_drop_table)
   print('success drop test table')
except mysql.connector.Error as e:
   print('drop table fails!{}'.format(e))  


cursor.close()
cnn.close() 

