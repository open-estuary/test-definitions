#!/usr/bin/python
# -*- coding: UTF-8 -*-

#访问元组
tup1 = ('physics', 'chemistry', 1997, 2000);
tup2 = (1, 2, 3, 4, 5, 6, 7 );
print "tup1[0]: ", tup1[0]
print "tup2[1:5]: ", tup2[1:5]

#修改元组
tup1 = (12, 34.56);
tup2 = ('abc', 'xyz');
tup3 = tup1 + tup2;
print tup3;

#删除元组
tup = ('physics', 'chemistry', 1997, 2000);
print tup;
del tup;
print "Deleted tup "
#print tup;

#无关闭分隔符
print 'abc', -4.24e93, 18+6.6j, 'xyz';
x, y = 1, 2;
print "Value of x , y : ", x,y;
