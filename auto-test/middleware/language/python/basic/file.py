#!/usr/bin/python
# -*- coding: UTF-8 -*-

# 打开一个文件
fo = open("foo.txt", "rb+")
fo.write( "www.runoob.com!\nVery good site!\n" );

str = fo.read(10);
print "读取的字符串是 : ", str

# 查找当前位置
position = fo.tell();
print "当前文件位置 : ", position

# 把指针再次重新定位到文件开头
position = fo.seek(0, 0);
str = fo.read(10);
print "重新读取字符串 : ", str

# 关闭打开的文件
fo.close()

import os;

document = open("testfile.txt", "w+");
print "文件名: ", document.name;
document.write("这是我创建的第一个测试文件！\nwelcome!");
print document.tell();
#输出当前指针位置
document.seek(os.SEEK_SET);
#设置指针回到文件最初
context = document.read();
print context;
document.close();


