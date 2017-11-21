---
Strace.md - Strace 用来看某个进程的系统调用以及所接收到的信号
 
Hardware platform: D05 D03  
Software Platform: CentOS Ubuntu Debian 
Author: Chen Shuangsheng <chenshuangsheng@huawei.com>  
Date: 2017-10-31 14:38:05  
Categories: Estuary Documents  
Remark:
---
#语法
```
    strace  [  -dffhiqrtttTvxx  ] [ -acolumn ] [ -eexpr ] ...
        [ -ofile ] [-ppid ] ...  [ -sstrsize ] [ -uusername ]
        [ -Evar=val ] ...  [ -Evar  ]...
        [ command [ arg ...  ] ]

    strace  -c  [ -eexpr ] ...  [ -Ooverhead ] [ -Ssortby ]
        [ command [ arg...  ] ]

```
#选项
---
    -c 统计每一系统调用的所执行的时间,次数和出错的次数等.
    -d 输出strace关于标准错误的调试信息.
    -f 跟踪由fork调用所产生的子进程.
    -ff 如果提供-o filename,则所有进程的跟踪结果输出到相应的filename.pid中,pid是各进程的进程号.
    -F 尝试跟踪vfork调用.在-f时,vfork不被跟踪.
    -h 输出简要的帮助信息.
    -i 输出系统调用的入口指针.
    -q 禁止输出关于脱离的消息.
    -r 打印出相对时间关于,,每一个系统调用.
    -t 在输出中的每一行前加上时间信息.
    -tt 在输出中的每一行前加上时间信息,微秒级.
    -ttt 微秒级输出,以秒了表示时间.
    -T 显示每一调用所耗的时间.
    -v 输出所有的系统调用.一些调用关于环境变量,状态,输入输出等调用由于使用频繁,默认不输出.
    -V 输出strace的版本信息.
    -x 以十六进制形式输出非标准字符串
    -xx 所有字符串以十六进制形式输出.
    -a column 设置返回值的输出位置.默认 为40.
    -e expr 指定一个表达式,用来控制如何跟踪.格式：[qualifier=][!]value1[,value2]...
    qualifier只能是 trace,abbrev,verbose,raw,signal,read,write其中之一.value是用来限定的符号或数字.默认的 qualifier是 trace.感叹号是否定符号.例如:-eopen等价于 -e trace=open,表示只跟踪open调用.而-etrace!=open 表示跟踪除了open以外的其他调用.有两个特殊的符号 all 和 none. 注意有些shell使用!来执行历史记录里的命令,所以要使用\\.
    -e trace=set 只跟踪指定的系统 调用.例如:-e trace=open,close,rean,write表示只跟踪这四个系统调用.默认的为set=all.
    -e trace=file 只跟踪有关文件操作的系统调用.
    -e trace=process 只跟踪有关进程控制的系统调用.
    -e trace=network 跟踪与网络有关的所有系统调用.
    -e strace=signal 跟踪所有与系统信号有关的 系统调用
    -e trace=ipc 跟踪所有与进程通讯有关的系统调用
    -e abbrev=set 设定strace输出的系统调用的结果集.-v 等与 abbrev=none.默认为abbrev=all.
    -e raw=set 将指定的系统调用的参数以十六进制显示.
    -e signal=set 指定跟踪的系统信号.默认为all.如 signal=!SIGIO(或者signal=!io),表示不跟踪SIGIO信号.
    -e read=set 输出从指定文件中读出 的数据.例如: -e read=3,5
    -e write=set 输出写入到指定文件中的数据.
    -o filename 将strace的输出写入文件filename
    -p pid 跟踪指定的进程pid.
    -s strsize 指定输出的字符串的最大长度.默认为32.文件名一直全部输出.
    -u username 以username的UID和GID执行被跟踪的命令
---
# Test
```bash
    追踪某个命令
    会输出很多系统调用命令， 如下面，  =左边是系统调用，右边是系统调用结果
    $strace ls -l      能看到ls -l命令整个的系统调用情况
    stat("/etc/localtime", {st_mode=S_IFREG|0644, st_size=388, ...}) = 0
    
    -p 追踪某个进程，需要带上-f来追踪所有子进程
    
    $strace -f -p 5926 -o /home/***/5926.strace.log
    
    -c 参数，输出统计结果
    
    -c  可以输出系统调用的统计结果，也就是每个命令的占比
    $strace -c -f -p 5926 -o /home/***/5926.strace.log
    
    #less  /home/***/5926.strace.log
    % time     seconds  usecs/call     calls    errors syscall
    ------ ----------- ----------- --------- --------- ----------------
     60.47   19.181735        7429      2582      1258 futex
     23.42    7.429387      212268        35        35 restart_syscall
     11.14    3.533856         983      3596           epoll_wait
      1.50    0.475396          51      9368           setsockopt
      0.79    0.250978          54      4684           fcntl
      0.72    0.227007          48      4684      2342 epoll_ctl
      0.42    0.132211          56      2342      2342 connect
      0.40    0.127517          54      2342           getsockopt
      0.39    0.123448          53      2342           close
      0.38    0.119249          51      2342           dup2
      0.37    0.117744          50      2342           socket
      0.00    0.000432          15        29           recvfrom
      0.00    0.000210           7        29           poll
      0.00    0.000000           0        10           write
      0.00    0.000000           0        29           sendto
    ------ ----------- ----------- --------- --------- ----------------
    100.00   31.719170                 36756      5977 total
    
    -T 输出系统调用花费时间
    
    -T  表示记录各个系统调用花费的时间，精确到微妙，结果中的 <0.000020> 为时间
    $strace -T -f -e trace=network  -p 9618 -o /home/A/desc.trace.9618
    $cat /home/A/desc.trace.9618
    9700  getsockopt(76, SOL_SOCKET, SO_ERROR, [111], [4]) = 0 <0.000020>
    
    -t 打印系统调用的发生时间
    
    $strace -f -t   -p 9618 -o /home/A/9618.strace
    $cat /home/A/9618.strace
    9705  21:57:09 getsockopt(54, SOL_SOCKET, SO_ERROR, [111], [4]) = 0
    
    -e expr, 可以指定某个系统调用
    
    下面为追踪read的系统调用
    $strace -f -e read -p 9618   -o 9618.read.log
    
    -e trace=network  追踪网络调用情况
    
    $strace -f -t  -e trace=network  -p 9618 -o /home/A/desc.trace.9618.withouti
    $cat /home/A/desc.trace.9618.withouti
    9705  21:57:09 getsockopt(54, SOL_SOCKET, SO_ERROR, [111], [4]) = 0
    ...
    
    -e trace=open 追踪open系统调用
    
    也可以trace=open,close,read,write
    $strace -e trace=open  -o a.txt.log
    
    $less a.txt.log
    open("/etc/ld.so.cache", O_RDONLY)      = 3
    open("/lib64/libtinfo.so.5", O_RDONLY)  = 3
    open("/lib64/libpcre.so.0", O_RDONLY)   = 3
    ...
    
    -e trace=file, 记录文件操作
    
    把5926对文件的操作记录下来，相当于trace=open.stat,chmod,unlink...
    $strace -f -e trace=file -p 5926 -o 5926.file.trace.log
    
    -e trace=process, 把关于进程的系统调用记录下来
    
    把6259对process系统调用的操作记录下来，相当于trace=
    $strace -f -e trace=process -p 6259 -o 6259.file.process.log
    
    -e trace=network, 把关于进程的系统调用记录下来
    
    把5926对网络的系统调用记录下来
    $strace -f -e trace=network -p 5926  -o 5926.network.log
    
    -e trace=ipc  把进程间通讯记录下来
    
    把5926对进程间通讯的系统调用记录下来
    $strace -f -e trace=ipc -p 5926  -o 5926.ipc.log
```
