/*************************************************************************
	> File Name: delete.c
	> Author: 
	> Mail: 
	> Created Time: 2017年11月21日 星期二 14时34分37秒
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
       bson_oid_t oid;
       bson_t *doc;

       mongoc_init ();

       client =
          mongoc_client_new ("mongodb://localhost:27017/?appname=delete-example");
       collection = mongoc_client_get_collection (client, "test", "test");

       doc = bson_new ();
       bson_oid_init (&oid, NULL);
       BSON_APPEND_OID (doc, "_id", &oid);
       BSON_APPEND_UTF8 (doc, "hello", "world");

    if (!mongoc_collection_insert (
                  collection, MONGOC_INSERT_NONE, doc, NULL, &error
        )) {
                  fprintf (stderr, "Insert failed: %s\n", error.message);
               
        }

       bson_destroy (doc);

       doc = bson_new ();
       BSON_APPEND_OID (doc, "_id", &oid);

    if (!mongoc_collection_remove (
                  collection, MONGOC_REMOVE_SINGLE_REMOVE, doc, NULL, &error
        )) {
                  fprintf (stderr, "Delete failed: %s\n", error.message);
               
        }

       bson_destroy (doc);
       mongoc_collection_destroy (collection);
       mongoc_client_destroy (client);
       mongoc_cleanup ();

       return 0;

}

