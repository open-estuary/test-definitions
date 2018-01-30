/*************************************************************************
	> File Name: count.c
	> Author: 
	> Mail: 
	> Created Time: 2017年11月21日 星期二 14时35分15秒
 ************************************************************************/

#include<stdio.h>
#include <bson.h>
#include <mongoc.h>
#include <stdio.h>

int
main (int argc, char *argv[])
{
       mongoc_client_t *client;
       mongoc_collection_t *collection;
       bson_error_t error;
       bson_t *doc;
       int64_t count;

       mongoc_init ();

       client =
          mongoc_client_new ("mongodb://localhost:27017/?appname=count-example");
       collection = mongoc_client_get_collection (client, "mydb", "mycoll");
    doc = bson_new_from_json (
              (const uint8_t *) "{\"hello\" : \"world\"}", -1, &error
        );

    count = mongoc_collection_count (
              collection, MONGOC_QUERY_NONE, doc, 0, 0, NULL, &error
        );

    if (count < 0) {
              fprintf (stderr, "%s\n", error.message);
           
    } else {
              printf ("%" PRId64 "\n", count);
           
    }

       bson_destroy (doc);
       mongoc_collection_destroy (collection);
       mongoc_client_destroy (client);
       mongoc_cleanup ();

       return 0;

}
