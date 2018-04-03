/*************************************************************************
	> File Name: connect.c
	> Author: 
	> Mail: 
	> Created Time: 2017年12月26日 星期二 09时57分09秒
 ************************************************************************/

#include<stdio.h>
#include <cassandra.h>
#include <stdio.h>

int main() {
      /* Setup and connect to cluster */
      CassCluster* cluster = cass_cluster_new();
      CassSession* session = cass_session_new();
    
      /* Add contact points */
      cass_cluster_set_contact_points(cluster, "127.0.0.1");

      /* Provide the cluster object as configuration to connect the session */
      CassFuture* connect_future = cass_session_connect(session, cluster);

      /* This operation will block until the result is ready */
      CassError rc = cass_future_error_code(connect_future);

      printf("Connect result: %s\n", cass_error_desc(rc));

      /* Run queries... */
    CassStatement* statement = cass_statement_new("select * from system.schema_keyspaces" , 0 );
//      = cass_statement_new("INSERT INTO example (key, value) VALUES ('abc', 123)", 0);

    CassFuture* query_future = cass_session_execute(session, statement);

  //   Statement objects can be freed immediately after being executed 
    cass_statement_free(statement);

    // This will block until the query has finished 
    CassError rc1 = cass_future_error_code(query_future);

    printf("Query result: %s\n", cass_error_desc(rc1));

    cass_future_free(query_future);
      cass_future_free(connect_future);
      cass_session_free(session);
      cass_cluster_free(cluster);

      return 0;

}

