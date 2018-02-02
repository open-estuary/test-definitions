/*************************************************************************
> File Name: hello_mongoc.c
> Author: 
> Mail: 
> Created Time: 2017年11月21日 星期二 09时40分50秒
************************************************************************/

#include <mongoc.h>

int main (int argc, char *argv[])
{
    const char *uri_str = "mongodb://localhost:27017";
    mongoc_client_t *client;
    mongoc_database_t *database;
    mongoc_collection_t *collection;
    bson_t *command, reply, *insert;
    bson_error_t error;
    char *str;
    bool retval;

    /*
    *     * Required to initialize libmongoc's internals
    *         */
    mongoc_init ();
    system("lava-test-case 'mongoCDriver initialize' --result pass");
    /*
    *     * Optionally get MongoDB URI from command line
    *         */
    if (argc > 1) {
        uri_str = argv[1];

    }

    /*
    *     * Create a new client instance
    *         */
    client = mongoc_client_new (uri_str);
    if (client == 0)
        system("lava-test-case 'mongoCDriver create a new client instance' --result fail");
    else
        system("lava-test-case 'mongoCDriver create a new client instance' --result pass");
    
    /*
    *     * Register the application name so we can track it in the profile logs
    *         * on the server. This can also be done from the URI (see other examples).
    *             */
    bool ret =  mongoc_client_set_appname (client, "connect-example");
    if (ret)
    {
        system("lava-test-case 'mongoCDriver resister application' --result pass");
    }else
    {
        system("lava-test-case 'mongoCDriver resister application' --result fail");
    }
    
    /*
    *     * Get a handle on the database "db_name" and collection "coll_name"
    *         */
    database = mongoc_client_get_database (client, "db_name");
    if(database == 0)
        system("lava-test-case 'mongoCDriver get database' --result fail");
    else
        system("lava-test-case 'mongoCDriver get database' --result pass");

    collection = mongoc_client_get_collection (client, "db_name", "coll_name");
    if(collection == 0)
        system("lava-test-case 'mongoCDriver get collection' --result fail");
    else
        system("lava-test-case 'mongoCDriver get collection' --result pass");

    /*
    *     * Do work. This example pings the database, prints the result as JSON and
    *         * performs an insert
    *             */
    command = BCON_NEW ("ping", BCON_INT32 (1));
    
    retval = mongoc_client_command_simple (
        client, "admin", command, NULL, &reply, &error
        );

    if (!retval) {
        fprintf (stderr, "%s\n", error.message);
        system("lava-test-case 'mongoCDriver ping mongodb server' --result fail");
        return EXIT_FAILURE;

    }
    system("lava-test-case 'mongoCDriver ping mongodb server' --result pass");
    
    str = bson_as_json (&reply, NULL);
    if( str != 0  )
        system("lava-test-case 'mongoCDriver bson to JSON' --result pass");
    else
        system("lava-test-case 'mongoCDriver bson to json' --result fail");
    printf ("%s\n", str);

    insert = BCON_NEW ("hello", BCON_UTF8 ("world"));
    if(insert != 0)
    {
        system("lava-test-case 'mongoCDriver create BSON object' --result pass");
    }else{
        system("lava-test-case 'mongoCDriver create BSON object' --result fail");
    }
    if (!mongoc_collection_insert (collection, MONGOC_INSERT_NONE, insert, NULL, &error )) 
    {
        fprintf (stderr, "%s\n", error.message);
        system("lava-test-case 'mongoCDriver insert' --result fail");  
    }
    
    bson_destroy (insert);
    bson_destroy (&reply);
    bson_destroy (command);
    bson_free (str);
    system("lava-test-case 'mongoCDriver destroy bson' --result pass");
    /*
    *     * Release our handles and clean up libmongoc
    *         */
    mongoc_collection_destroy (collection);
    mongoc_database_destroy (database);
    mongoc_client_destroy (client);
    mongoc_cleanup ();
    system("lava-test-case 'mongoCDriver release and clean up libmongc' --result pass");
    return 0;

}
