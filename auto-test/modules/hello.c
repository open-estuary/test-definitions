/*************************************************************************
	> File Name: hello.c
	> Author: 
	> Mail: 
	> Created Time: 2017年11月23日 星期四 14时16分11秒
 ************************************************************************/

#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/module.h>
MODULE_LICENSE("GPL");
static int __init hello_init(void)
{
    printk(KERN_ALERT "Hello, world!from kernel space....\n");
    return 0;
}
static void __exit hello_exit(void)
{
    printk(KERN_ALERT "Goodbye,world! Leaving kernel space....\n");
}
module_init(hello_init);
module_exit(hello_exit);
