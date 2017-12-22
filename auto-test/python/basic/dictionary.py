#!/usr/bin/python
# -*- coding: UTF-8 -*-

# 访问字典里的值
dict = {'Name': 'Zara', 'Age': 7, 'Class': 'First'};
print "dict['Name']: ", dict['Name'];
print "dict['Age']: ", dict['Age'];

# 修改字典
dict['Age'] = 8; # update existing entry
dict['School'] = "DPS School"; # Add new entry
print "dict['Age']: ", dict['Age'];
print "dict['School']: ", dict['School'];


# 比较字典
dict1 = {'Name': 'Zara', 'Age': 7};
dict2 = {'Name': 'Mahnaz', 'Age': 27};
dict3 = {'Name': 'Abid', 'Age': 27};
dict4 = {'Name': 'Zara', 'Age': 7};
print "Return Value : %d" %  cmp (dict1, dict2)
print "Return Value : %d" %  cmp (dict2, dict3)
print "Return Value : %d" %  cmp (dict1, dict4)

# 字典元素个数
print "Length : %d" % len (dict)

# 打印字符串
print "Equivalent String : %s" % str (dict)

# 返回变量类型
print "Variable Type : %s" %  type (dict)

# 字典的浅复制
dict5 = dict1.copy()
print "New Dictinary : %s" %  str(dict5)

# 返回字典中所有值
print "Value : %s" %  dict.values()

# 删除字典中所有元素
dict.clear();     # 清空词典所有条目
print "Length : %d" % len (dict)

# 删除词典
del dict ;
