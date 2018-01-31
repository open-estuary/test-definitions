---
siege.md - siege 开源的压力测试工具,可以根据配置对一个WEB站点进行多用户的并发访问
Hardware platform: D05 D03
Software Platform: CentOS Ubuntu Debian
Author: mahongxin <hongxin_228@163.com>
Date: 2018-1-27 15:38:05
Categories: Estuary Documents
Remark:
---
#命令说明
```
 siege是一款开源的压力测试工具,可以根据配置对一个WEB站点进行多用户的并发访问,记录每个用户所有的请求过程的相应时间，并在一定数量的并发访问下重复进行
     　　 siege报表解析以下举例说明:
    　　　　Transactions:                 10 hits    ：服务器接收的请求数
    　　　　Availability:                 100.00 %       ：有效情况的比例
    　　　　Elapsed time:                 1.06 secs    :  测试所用的时间
    　　　　Data transferred:             0.04 MB    ：每个模拟用户的数据传输量
   　　　　 Response time:                0.03 secs    ：响应每个模拟用户请求的平均时间
    　　　　Transaction rate:             9.43 trans/sec    ：服务器每秒处理事务的平均数
    　　　　Throughput:                   0.04 MB/sec    ：服务器每秒跟所有模拟用户的数据传输量
    　　　　Concurrency:                  0.25    ：每秒的模拟连接
    　　　　Successful transactions:      10    ：处理成功的事务数（code<400）
    　　　　Failed transactions:           0    ： 处理失败的事务数（code>400）
    　　　　Longest transaction:           0.04    ：最长的事务处理时间
    　　　　Shortest transaction:          0.02    ：最短的事务处理时间
        注意:按ctrl+c结束命令的打印结果按以上说明来分析结果

```
#选项
---
　　　　
  -V, --version             VERSION, prints the version number.
  -h, --help                HELP, prints this section.
  -C, --config              CONFIGURATION, show the current config.
  -v, --verbose             VERBOSE, prints notification to screen.
  -q, --quiet               QUIET turns verbose off and suppresses output.
  -g, --get                 GET, pull down HTTP headers and display the
                            transaction. Great for application debugging.
  -c, --concurrent=NUM      CONCURRENT users, default is 10
  -r, --reps=NUM            REPS, number of times to run the test.
  -t, --time=NUMm           TIMED testing where "m" is modifier S, M, or H
                            ex: --time=1H, one hour test.
  -d, --delay=NUM           Time DELAY, random delay before each requst
  -b, --benchmark           BENCHMARK: no delays between requests.
  -i, --internet            INTERNET user simulation, hits URLs randomly.
  -f, --file=FILE           FILE, select a specific URLS FILE.
  -R, --rc=FILE             RC, specify an siegerc file
  -l, --log[=FILE]          LOG to FILE. If FILE is not specified, the
                            default is used: PREFIX/var/siege.log
  -m, --mark="text"         MARK, mark the log file with a string.
                            between .001 and NUM. (NOT COUNTED IN STATS)
  -H, --header="text"       Add a header to request (can be many)
  -A, --user-agent="text"   Sets User-Agent in request
  -T, --content-type="text" Sets Content-Type in request


---
# Test
```bash
    　(1)安装siege:
        centos:yum install siege.aarch64 -y

     (2)查找到安装路径
　　 　rpm -ql siege.aarch64
      /etc/siege
      /etc/siege/siegerc
      /etc/siege/urls.txt
      /usr/bin/bombardment
      /usr/bin/siege
      /usr/bin/siege.config
      /usr/bin/siege2csv.pl
      /usr/share/doc/siege-4.0.2
      /usr/share/doc/siege-4.0.2/AUTHORS
      /usr/share/doc/siege-4.0.2/ChangeLog
      /usr/share/doc/siege-4.0.2/README.md
      /usr/share/man/man1/bombardment.1.gz
      /usr/share/man/man1/siege.1.gz
      /usr/share/man/man1/siege.config.1.gz
      /usr/share/man/man1/siege2csv.1.gz

    (3)50个用户重复100次共产生50*100个请求
       /usr/bin/siege -c 50 -r 100 www.baidu.com

    (4)50个请求重复100次发送get参数
       /usr/bin/siege -c 50 -r 100  http://www.baidu.com/s?   wd=siege&rsv_spt=1&issp=1&rsv_bp=0&ie=utf-8&tn=baiduhome_pg&rsv_sug3=4&rsv_sug=2&rsv_sug1=4&rsv_sug4=60
　　　
　　　(5)5.50个用户 重复100次 发送POST参数 (注意引号)
         /usr/bin/siege -c 50 -r 100  "https://www.abc.com/a.php POST name=zhangsan"

   (6)50个用户 重复100次 发送POST参数(从文件中读取)
    　/usr/bin/siege -c 50 -r 100  "https://www.baidu.com/a.php POST < /root/ab_test/post.xml"

   (7)siege -c 200 -r 10 -f example.url
      -c是并发量,-r是重复次数. url文件就是一个文本，每行都是一个url,它会从里面随机访问的。
     example.url内容:
     http://www.licess.cn
     http://www.vpser.net
     http://soft.vpser.net

  (8)模拟50个用户，web请求间隔时间10秒
　 　siege -d10 -c50 http://www.cnphp.info/blog/index.php

　(9)卸载安装包
　　yum remove siege.aarch64 -y

```

