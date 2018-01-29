# OpenBLAS
OpenBLAS is an optimized Basic Linear Algebra Subprograms library based on
GotoBLAS2 1.13 BSD version.

高性能计算涉及的领域很广泛，要模拟计算的问题也是千差万别，所以这个领域的软件跟一
般企业界使用的ERP、数据库、操作系统等不同，在数量上非常繁多。高性能计算涉及的领域
就包括EDA设计仿真、CAE、数值计算、计算化学、计算物理、材料设计、量子力学、分子动
力学、液体力学、工业设计、图像渲染、生物信息、生命科学、天文气象、金融、石油勘探、
工程计算、地震资料处理等应用。

Hardware platform: D05, DDR4 512G运行频率2133MHz Software Platform: CentOS
Author: Feng liang feng_liang@hoperun.com
Date: 2018-1-24 10:01
Categories: Estuary Documents
Remark:

# Dependency
在CentOS系统安装依赖包
```
$ yum install git
$ yum install gcc-gfortran.aarch64
$ yum install numactl.aarch64
```
在Debian/Ubuntu系统安装依赖包
```
$ apt install git
$ apt install gfortran
$ apt install numactl
$ apt install make
```
# Build
下载OpenBLAS源码
```
$ git clone https://github.com/xianyi/OpenBLAS.git
```

构建OpenBLAS库
```
$ cd OpenBLAS
$ make TARGET=ARMV8 BINARY=64
```

构建OpenBLAS性能测试组建
```
$ cd OpenBLAS/benchmark
$ make TARGET=ARMV8 BINARY=64
```
# Test
```
$ OPENBLAS_NUM_THREADS=2
$ ./sblat1
 Real BLAS Test Program Results
 Test of subprogram number  1             SDOT
                                    ----- PASS -----
 Test of subprogram number  2            SAXPY
                                    ----- PASS -----
 Test of subprogram number  3            SROTG
                                    ----- PASS -----
 Test of subprogram number  4             SROT
                                    ----- PASS -----
 Test of subprogram number  5            SCOPY
                                    ----- PASS -----
 Test of subprogram number  6            SSWAP
                                    ----- PASS -----
 Test of subprogram number  7            SNRM2
                                    ----- PASS -----
 Test of subprogram number  8            SASUM
                                    ----- PASS -----
 Test of subprogram number  9            SSCAL
                                    ----- PASS -----
 Test of subprogram number 10            ISAMAX
                                    ----- PASS -----
```

```
$ OPENBLAS_NUM_THREADS=2 ./dblat1
 Real BLAS Test Program Results
 Test of subprogram number  1             DDOT
                                    ----- PASS -----
 Test of subprogram number  2            DAXPY
                                    ----- PASS -----
 Test of subprogram number  3            DROTG
                                    ----- PASS -----
 Test of subprogram number  4             DROT
                                    ----- PASS -----
 Test of subprogram number  5            DCOPY
                                    ----- PASS -----
 Test of subprogram number  6            DSWAP
                                    ----- PASS -----
 Test of subprogram number  7            DNRM2
                                    ----- PASS -----
 Test of subprogram number  8            DASUM
                                    ----- PASS -----
 Test of subprogram number  9            DSCAL
                                    ----- PASS -----
 Test of subprogram number 10            IDAMAX
                                    ----- PASS -----
```

```
$ OPENBLAS_NUM_THREADS=2 ./cblat1
 Complex BLAS Test Program Results
 Test of subprogram number  1            CDOTC
                                    ----- PASS -----
 Test of subprogram number  2            CDOTU
                                    ----- PASS -----
 Test of subprogram number  3            CAXPY
                                    ----- PASS -----
 Test of subprogram number  4            CCOPY
                                    ----- PASS -----
 Test of subprogram number  5            CSWAP
                                    ----- PASS -----
 Test of subprogram number  6            SCNRM2
                                    ----- PASS -----
 Test of subprogram number  7            SCASUM
                                    ----- PASS -----
 Test of subprogram number  8            CSCAL
                                    ----- PASS -----
 Test of subprogram number  9            CSSCAL
                                    ----- PASS -----
 Test of subprogram number 10            ICAMAX
                                    ----- PASS -----
```

```
$ OPENBLAS_NUM_THREADS=2 ./zblat1
 Complex BLAS Test Program Results
 Test of subprogram number  1            ZDOTC
                                    ----- PASS -----
 Test of subprogram number  2            ZDOTU
                                    ----- PASS -----
 Test of subprogram number  3            ZAXPY
                                    ----- PASS -----
 Test of subprogram number  4            ZCOPY
                                    ----- PASS -----
 Test of subprogram number  5            ZSWAP
                                    ----- PASS -----
 Test of subprogram number  6            DZNRM2
                                    ----- PASS -----
 Test of subprogram number  7            DZASUM
                                    ----- PASS -----
 Test of subprogram number  8            ZSCAL
                                    ----- PASS -----
 Test of subprogram number  9            ZDSCAL
                                    ----- PASS -----
 Test of subprogram number 10            IZAMAX
                                    ----- PASS -----
```

在不同数量CPU核心下进行 OpenBLAS/benchmark 测试。当前的主流深度学习框架中(如
Caffe、Caffe2、Tensorflow、MXNet、Theano等)的卷积分层(conv)和全连接层(fc)均通过
调用BLAS库的GEMM (GEneral Matrix to Matirx Multiplication)函数实现。

## 1个CPU核心
```
$ numactl -C 0 --localalloc ./sgemm.goto 200 4000 200
```

## 10个CPU核心
```
$ export OPENBLAS_NUM_THREADS=10
$ taskset -c 0-9 ./sgemm.goto 200 4000 200
```

## 32个CPU核心
```
$ export OPENBLAS_NUM_THREADS=32
$ taskset -c 0-31 ./sgemm.goto 200 4000 200
```

## 64个CPU核心
```
$ export OPENBLAS_NUM_THREADS=64
$ taskset -c 0-64 ./sgemm.goto 200 4000 200
```

# Result
```
[root@D03-142 benchmark]# export OPENBLAS_NUM_THREADS=1
[root@D03-142 benchmark]# numactl -C 0 --localalloc ./sgemm.goto 200 4000 200
From : 200  To : 4000 Step=200 : Transa=N : Transb=N
          SIZE                   Flops             Time
M= 200, N= 200, K= 200 :    13008.13 MFlops   0.001230 sec
M= 400, N= 400, K= 400 :    14576.93 MFlops   0.008781 sec
M= 600, N= 600, K= 600 :    15404.36 MFlops   0.028044 sec
M= 800, N= 800, K= 800 :    15509.98 MFlops   0.066022 sec
M=1000, N=1000, K=1000 :    13479.00 MFlops   0.148379 sec
M=1200, N=1200, K=1200 :    15095.59 MFlops   0.228941 sec
M=1400, N=1400, K=1400 :    15363.17 MFlops   0.357218 sec
M=1600, N=1600, K=1600 :    15493.55 MFlops   0.528736 sec
M=1800, N=1800, K=1800 :    15072.51 MFlops   0.773859 sec
M=2000, N=2000, K=2000 :    14916.09 MFlops   1.072667 sec
M=2200, N=2200, K=2200 :    14903.37 MFlops   1.428939 sec
M=2400, N=2400, K=2400 :    15241.87 MFlops   1.813951 sec
M=2600, N=2600, K=2600 :    15033.31 MFlops   2.338274 sec
M=2800, N=2800, K=2800 :    14998.70 MFlops   2.927187 sec
M=3000, N=3000, K=3000 :    14914.12 MFlops   3.620731 sec
M=3200, N=3200, K=3200 :    15247.14 MFlops   4.298249 sec
M=3400, N=3400, K=3400 :    14806.03 MFlops   5.309189 sec
M=3600, N=3600, K=3600 :    14864.76 MFlops   6.277398 sec
M=3800, N=3800, K=3800 :    14992.41 MFlops   7.319972 sec
M=4000, N=4000, K=4000 :    15298.37 MFlops   8.366907 sec

[root@D03-142 benchmark]# export OPENBLAS_NUM_THREADS=10
[root@D03-142 benchmark]# numactl -C 0-9 --localalloc ./sgemm.goto 200 4000 200
From : 200  To : 4000 Step=200 : Transa=N : Transb=N
         SIZE                   Flops             Time
M= 200, N= 200, K= 200 :      417.13 MFlops   0.038357 sec
M= 400, N= 400, K= 400 :     1970.23 MFlops   0.064967 sec
M= 600, N= 600, K= 600 :     4749.18 MFlops   0.090963 sec
M= 800, N= 800, K= 800 :     8754.83 MFlops   0.116964 sec
M=1000, N=1000, K=1000 :    13796.62 MFlops   0.144963 sec
M=1200, N=1200, K=1200 :    24172.23 MFlops   0.142974 sec
M=1400, N=1400, K=1400 :    32482.60 MFlops   0.168952 sec
M=1600, N=1600, K=1600 :    42019.95 MFlops   0.194955 sec
M=1800, N=1800, K=1800 :    52790.22 MFlops   0.220950 sec
M=2000, N=2000, K=2000 :    56347.95 MFlops   0.283950 sec
M=2200, N=2200, K=2200 :    56408.46 MFlops   0.377532 sec
M=2400, N=2400, K=2400 :    59156.68 MFlops   0.467369 sec
M=2600, N=2600, K=2600 :    60403.81 MFlops   0.581950 sec
M=2800, N=2800, K=2800 :    60483.41 MFlops   0.725885 sec
M=3000, N=3000, K=3000 :    62148.76 MFlops   0.868883 sec
M=3200, N=3200, K=3200 :    64677.28 MFlops   1.013277 sec
M=3400, N=3400, K=3400 :    62510.29 MFlops   1.257521 sec
M=3600, N=3600, K=3600 :    65925.40 MFlops   1.415418 sec
M=3800, N=3800, K=3800 :   109381.73 MFlops   1.003312 sec
M=4000, N=4000, K=4000 :   107717.00 MFlops   1.188299 sec

[root@D03-142 benchmark]# export OPENBLAS_NUM_THREADS=32
[root@D03-142 benchmark]# numactl --cpunodebind=0 --localalloc ./sgemm.goto 200 4000 200
From : 200  To : 4000 Step=200 : Transa=N : Transb=N
         SIZE                   Flops             Time
M= 200, N= 200, K= 200 :      414.85 MFlops   0.038568 sec
M= 400, N= 400, K= 400 :     1970.17 MFlops   0.064969 sec
M= 600, N= 600, K= 600 :     4748.71 MFlops   0.090972 sec
M= 800, N= 800, K= 800 :     8142.30 MFlops   0.125763 sec
M=1000, N=1000, K=1000 :    14307.28 MFlops   0.139789 sec
M=1200, N=1200, K=1200 :    51426.28 MFlops   0.067203 sec
M=1400, N=1400, K=1400 :   163275.02 MFlops   0.033612 sec
M=1600, N=1600, K=1600 :   165157.96 MFlops   0.049601 sec
M=1800, N=1800, K=1800 :   169680.39 MFlops   0.068741 sec
M=2000, N=2000, K=2000 :   159613.73 MFlops   0.100242 sec
M=2200, N=2200, K=2200 :   159577.98 MFlops   0.133452 sec
M=2400, N=2400, K=2400 :   152980.43 MFlops   0.180729 sec
M=2600, N=2600, K=2600 :   158195.55 MFlops   0.222206 sec
M=2800, N=2800, K=2800 :   161431.35 MFlops   0.271967 sec
M=3000, N=3000, K=3000 :   163220.89 MFlops   0.330840 sec
M=3200, N=3200, K=3200 :   168916.36 MFlops   0.387979 sec
M=3400, N=3400, K=3400 :   162515.97 MFlops   0.483694 sec
M=3600, N=3600, K=3600 :   171546.44 MFlops   0.543946 sec
M=3800, N=3800, K=3800 :   167386.84 MFlops   0.655631 sec
M=4000, N=4000, K=4000 :   167991.57 MFlops   0.761943 sec

[root@D03-142 benchmark]# export OPENBLAS_NUM_THREADS=64
[root@D03-142 benchmark]# numactl --cpunodebind=0-3 --localalloc ./sgemm.goto 200 4000 200
From : 200  To : 4000 Step=200 : Transa=N : Transb=N
          SIZE                   Flops             Time
M= 200, N= 200, K= 200 :      201.58 MFlops   0.079372 sec
M= 400, N= 400, K= 400 :     1333.82 MFlops   0.095965 sec
M= 600, N= 600, K= 600 :     3485.25 MFlops   0.123951 sec
M= 800, N= 800, K= 800 :     6401.32 MFlops   0.159967 sec
M=1000, N=1000, K=1000 :    11642.46 MFlops   0.171785 sec
M=1200, N=1200, K=1200 :   100465.12 MFlops   0.034400 sec
M=1400, N=1400, K=1400 :   414407.61 MFlops   0.013243 sec
M=1600, N=1600, K=1600 :   477417.10 MFlops   0.017159 sec
M=1800, N=1800, K=1800 :   509567.50 MFlops   0.022890 sec
M=2000, N=2000, K=2000 :   536480.69 MFlops   0.029824 sec
M=2200, N=2200, K=2200 :   528344.95 MFlops   0.040307 sec
M=2400, N=2400, K=2400 :   534932.77 MFlops   0.051685 sec
M=2600, N=2600, K=2600 :   537903.60 MFlops   0.065350 sec
M=2800, N=2800, K=2800 :   543003.44 MFlops   0.080854 sec
M=3000, N=3000, K=3000 :   530045.74 MFlops   0.101878 sec
M=3200, N=3200, K=3200 :   546269.90 MFlops   0.119970 sec
M=3400, N=3400, K=3400 :   523924.10 MFlops   0.150037 sec
M=3600, N=3600, K=3600 :   547034.20 MFlops   0.170578 sec
M=3800, N=3800, K=3800 :   546571.97 MFlops   0.200786 sec
M=4000, N=4000, K=4000 :   245704.96 MFlops   0.520950 sec

```

# 参考文献
[OpenBlas库](http://blog.csdn.net/sunshine_in_moon/article/details/51728246)
