#!/usr/bin/python
# -*- coding: UTF-8 -*-

list01 = ['runoob', 786, 2.23, 'john', 70.2]
list02 = [123, 'john']

print list01
print list02

# 列表截取
print list01[0]
print list01[-1]
print list01[0:3]

# 列表重复
print list01 * 2

# 列表组合
print list01 + list02

# 获取列表长度
print len(list01)

# 删除列表元素
del list02[0]
print list02

# 元素是否存在于列表中
print 'john' in list02  # True

# 迭代
for i in list01:
    print i

# 比较两个列表的元素
print cmp(list01, list02)

# 列表最大/最小值
print max([0, 1, 2, 3, 4])
print min([0, 1])

# 将元组转换为列表
aTuple = (1,2,3,4)
list03 = list(aTuple)
print list03

# 在列表末尾添加新的元素
list03.append(5)
print list03

# 在列表末尾一次性追加另一个序列中的多个值（用新列表扩展原来的列表）
list03.extend(list01)
print list03

# 统计某个元素在列表中出现的次数
print list03.count(1)

# 从列表中找出某个值第一个匹配项的索引位置
print list03.index('john')

# 将对象插入列表
list03.insert(0, 'hello')
print list03

# 移除列表中的一个元素（默认最后一个元素），并且返回该元素的值
print list03.pop(0)
print list03

# 移除列表中某个值的第一个匹配项
list03.remove(1)
print list03

# 反向列表中元素
list03.reverse()
print list03

# 对原列表进行排序
list03.sort()
print list03
