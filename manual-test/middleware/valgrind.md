---
Valgrind，是一套Linux下，开放源代码（GPL V2）的仿真调试工具的集合

Hardware platform: D03 D05  
Software Platform: CentOS Ubuntu Debian 
Author: Vasily Fang <fangyuanzheng3@huawei.com>  
Date: 2018-01-12
Categories: Estuary Documents  
Remark:
---

# Dependency
```
  1. 单板启动正常
  2. 系统启动正常
```

# Test Procedure
```
  1. install valgrind : yum install -y valgrind
  2. 查看内核版本：valgrind --version
  3. 检测内存泄露
     a. 创建memleak.c
        #include <stdlib.h>
        #include <stdio.h>
         int main(void)
      {
       char *ptr;
       ptr = (char *)malloc(10);
       return 0;
      }
     b. 编译memleak.c
       $ gcc -o memleak memleak.c
     c. 用valgrind检测
       $ valgrind --leak-check=full ./memleak
   4. 检测其它内存问题
      a. 创建memcheck.c
         #include <stdlib.h>
         #include <stdio.h>
          int main(void)
        {
         char *ptr = malloc(10);
         ptr[12] = 'a'; // 内存越界
         memcpy(ptr +1, ptr, 5); // 踩内存
         char a[10];
         a[12] = 'i'; // 数组越界
         free(ptr); // 重复释放
         free(ptr);
         char *p1;
         *p1 = '1'; // 非法指针
         return 0;
        }
       b. 编译memcheck.c
         $ gcc -o memcheck memcheck.c -g
       c. valgrind --leak-check=full ./memcheck
    5. 卸载安装包
       $ yum remove -y valgrind
```

# Expected Result
```
  1. 能正常安装和卸载安装包
  2. 能正常检测到内存泄露
```
