/*************************************************************************
	> File Name: hello_bson.c
	> Author: shuangchenchen
	> Mail: shuangshengchen@qq.com
	> Created Time: 2017年10月27日 星期五 11时47分24秒
 ************************************************************************/

#include<stdio.h>
#include<bson.h>

int main ()
{
   bson_t bson;
   char *str;

   bson_init(&bson);
   BSON_APPEND_UTF8(&bson, "0", "hello");
   BSON_APPEND_UTF8(&bson, "1", "bson");

   str = bson_as_json(&bson, NULL);
   /* Prints
    * { "0" : "foo", "1" : "bar" }
    */
   printf("%s\n", str);
   bson_free(str);

   bson_destroy(&bson);
}
