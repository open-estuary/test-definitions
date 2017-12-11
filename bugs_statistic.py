#!/usr/bin/env python
# coding=utf-8
import pandas as pd
#import matplotlib.pyplot
lcolumns=[u'测试项目',u'能否自动化',u'是否完成',u'责任人']
dbugs_guy={u'刘彩丽':0,u'房元政':0,u'谭礼清':0,u'陈双胜':0,u'马红新':0}
dautobugs_guy={u'刘彩丽':0,u'房元政':0,u'谭礼清':0,u'陈双胜':0,u'马红新':0}
lsheetlist=[u'Website',u'build',u'UEFI',u'Deploy',u'Kernel',u'Kernel_package',u'Distro',u'App',u'App_package',u'Stress',u'PCIe SSD',u'82599网卡',u'raidl卡',u'内存条',u'HNS']
for sheetname in lsheetlist:
    #print sheetname
    df=pd.read_excel('OpenEstuary_TestCases.xls',sheetname=sheetname,skiprows=0)
    df=df[lcolumns]
    #用例总数
    df1=df[df[u'是否完成']==u'是']
    dft=df1.groupby(u'责任人').count()

    for name in dft.index:
        #print name
        dbugs_guy[name]=dbugs_guy[name]+dft.loc[name][u'是否完成']

    #自动化数量
    df2=df[(df[u'能否自动化']==u'是') & (df[u'是否完成']==u'是')] 
    dft=df2.groupby(u'责任人').count()
    for name in dft.index:
        dautobugs_guy[name]=dautobugs_guy[name]+dft.loc[name][u'是否完成']
print ("%10s%10s%10s"%(u"责任人",u"个人总用例数",u"自动化用例数"))
sumbugs=0
sumautobugs=0
for name in dbugs_guy.keys():
    print ("%10s%10i%14i"%(name,dbugs_guy[name],dautobugs_guy[name],))
    sumbugs+=dbugs_guy[name]
    sumautobugs+=dautobugs_guy[name]
print ("%10s%10i%10s%10i"%(u"总用例数",sumbugs,u"自动化用例总数",sumautobugs))
