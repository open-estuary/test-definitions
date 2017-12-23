/*************************************************************************
	> File Name: test.c
	> Author:  tanliqing tanliqing2010@163.com
	> Mail: 
	> Created Time: 2017年12月22日 星期五 16时14分46秒
 ************************************************************************/

#include<stdio.h>


#include<stdio.h>
#include <stdio.h>
int func(int n)
{
    int sum=0,i;
    for(i=0; i<n; i++)
    {
        sum+=i;
    }
    return sum;
} 
int    main()
{
    int i;
    long result = 0;
    for(i=1; i<=100; i++)
    {
        result += i;
    }
    printf("result[1-100] = %d /n", result );
    printf("result[1-250] = %d /n", func(250) );
}
