#include<iostream>    

#include "mysql_driver.h"    
#include "mysql_connection.h"    

#include <cppconn/driver.h>    
#include <cppconn/exception.h>
#include <cppconn/resultset.h>
#include <cppconn/statement.h>
#include <cppconn/prepared_statement.h>

using namespace std;    

void RunConnectMySQL()    
{    

try {
    sql::mysql::MySQL_Driver *driver;    
    sql::Connection *con;   
    sql::Statement *stmt;
    sql::ResultSet *res;
    sql::PreparedStatement *pstmt; 
        
    /* Connect to the MySQL */
    driver = sql::mysql::get_mysql_driver_instance();    
    con = driver->connect("tcp://127.0.0.1:3306", "root", "root");    
    cout << "success connect mysql" << endl;

    /* Connect to the MySQL test database */
    con->setSchema("test");
    cout << "success use test database" << endl;

    /* Create test TABLE */
    stmt = con->createStatement();
    stmt->execute("DROP TABLE IF EXISTS test");
    stmt->execute("CREATE TABLE test(id INT)");
    delete stmt;
    cout << "success create test table" << endl;

    /* '?' is the supported placeholder syntax */
    pstmt = con->prepareStatement("INSERT INTO test(id) VALUES (?)");
    for (int i = 1; i <= 10; i++) {
       pstmt->setInt(1, i);
       pstmt->executeUpdate();
    }
    delete pstmt;
    cout << "success insert data into test table" << endl;

    /* Select in ascending order */
    pstmt = con->prepareStatement("SELECT id FROM test ORDER BY id ASC");
    res = pstmt->executeQuery();

    /* Fetch in reverse = descending order! */
    res->afterLast();
    while (res->previous())
      cout << "\t... MySQL counts: " << res->getInt("id") << endl;
    delete res;
    delete pstmt;
    cout << "success select data from test table" << endl;

    /* Update test order */
    pstmt = con->prepareStatement("UPDATE test SET id=100 WHERE id=10");
    pstmt->executeUpdate();
    delete pstmt;
    cout << "success update data for test table" << endl;

    /* Delete test data */
    pstmt = con->prepareStatement("DELETE from test WHERE id<100");
    pstmt->executeUpdate();
    delete pstmt;
    cout << "success delete data from test table" << endl;
    
    /* Drop test TABLE */
    stmt = con->createStatement();
    stmt->execute("DROP TABLE test");
    delete stmt;
    cout << "success drop test table" << endl;

    delete con;    

} catch (sql::SQLException &e) {
  cout << "# ERR: SQLException in " << __FILE__;
  cout << "(" << __FUNCTION__ << ") on line " 
     << __LINE__ << endl;
  cout << "# ERR: " << e.what();
  cout << " (MySQL error code: " << e.getErrorCode();
  cout << ", SQLState: " << e.getSQLState() << " )" << endl;
}

cout << endl;

}    
        
int main(void)    
{    
    RunConnectMySQL();    
    return 0;    
}

