ODP - Open Data Plane

*DESCRIPTION*
provides a data plane application programming environment that is easy to use,
high performance, and portable between networking SoCs.

Hardware platform: D03, D05
Software Platform: CentOS, Debian, Ubuntu
Author: Feng liang feng_liang@hoperun.com
Date: 2018-01-12 16:40
Categories: Testing manual
Remark: 由于输出结果不规范，需要人工参与分析测试结果。

# On Debian/Ubuntu systems
```
$ apt install libcunit1-dev
```

## testing
```
$ ../debian_ubuntu/run-test.sh > result
```

# CentOS/RedHat/Fedora systems
```
$ yum install CUnit-devel.aarch64
$ yum install libatomic.aarch64
```

## testing
```
$ ../centos_redhat_fedora/run-test.sh > result
```

# Analysis of the results
After executing the testing action, open the result document and we can find the
result for each test iterms.
```
Suite: Packet I/O Unsegmented
  Test: pktio_test_open ...passed
  Test: pktio_test_lookup ...passed
  Test: pktio_test_index ...passed
  Test: pktio_test_print ...passed
```

# reference
- [ODP简介](https://www.jianshu.com/p/9def3737cf34)
- [ODP (Open Data Plane)官网](https://www.opendataplane.org/)
- [API Reference Manual](https://www.opendataplane.org/api-documentation/master/api/index.html)
