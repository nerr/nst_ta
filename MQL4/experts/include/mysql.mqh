//+----------------------------------------------------------------------------+
//|                                                                  mysql.mqh |
//|                                          Copyright © 2009, Berkers Trading |
//|                                                          http://quotar.com |
//+----------------------------------------------------------------------------+
//|                                                  modified in 2012: vedroid |
//|                                                          begpoug@gmail.com |
//+----------------------------------------------------------------------------+
#property copyright "Copyright © 2009, Berkers Trading and vedroid"
#property link      "http://quotar.com"
/*
v2.0.3
------
- corrected initialization error (dbname)

v2.0.4
------

v2.0.5  modified by vedroid (begpoug@gmail.com)
------
- fixed infrastructural points
- deleted functions desired to be implemented
- connections many MySQL DBMS(s) are possible
*/
#import "mysql_wrapper.dll"
string  mt4_mysql_wrapper_version      ();
void    mt4_mysql_fetch_row            (int resultStruct, string& row[], int numFields);
void    mt4_mysql_fetch_fields_string  (int resultStruct, string& row[], int type);

#import "libmysql.dll"
int     mysql_init          (int dbConnectId);
int     mysql_errno         (int dbConnectId);
string  mysql_error         (int dbConnectId);
int     mysql_real_connect  (int dbConnectId, string host, string user, string password, string db, int port, int socket, int clientflag);
int     mysql_real_query    (int dbConnectId, string query, int length);
int     mysql_query         (int dbConnectId, string query);
void    mysql_close         (int dbConnectId);
int     mysql_store_result  (int dbConnectId);
int     mysql_use_result    (int dbConnectId);
int     mysql_insert_id     (int dbConnectId);

string  mysql_fetch_row     (int resultStruct);
int     mysql_num_fields    (int resultStruct);
string  mysql_fetch_field   (int resultStruct);
int     mysql_num_rows      (int resultStruct);
void    mysql_free_result   (int resultStruct);

#define FIELD_NAME      0
#define FIELD_ORGNAME   1
#define FIELD_TABLE     2
#define FIELD_ORGTABLE  3
#define FIELD_DB        4
#define FIELD_CATALOG   5
#define FIELD_DEF       6
//+----------------------------------------------------------------------------+
//|                                                                            |
//+----------------------------------------------------------------------------+
bool mysqlInit(int & dbConnectId, string host, string user, string pass, string dbName, int port, int socket, int client) {
    dbConnectId = mysql_init(dbConnectId);
    
    if ( dbConnectId == 0 ) {
        Print("mysqlInit: mysql_init failed. There was insufficient memory to allocate a new object");
        return (false);
    }
    
    int result = mysql_real_connect(dbConnectId, host, user, pass, dbName, port, socket, client); 
    
    if ( result != dbConnectId ) {
        Print("mysqlInit: mysql_errno: ", mysql_errno(dbConnectId),"; mysql_error: ", mysql_error(dbConnectId));
        return (false);
    }
    return (true);
}
//+----------------------------------------------------------------------------+
//|                                                                            |
//+----------------------------------------------------------------------------+
void mysqlDeinit(int dbConnectId){
    mysql_close(dbConnectId);
}
//+----------------------------------------------------------------------------+
//|                                                                            |
//+----------------------------------------------------------------------------+
bool mysqlNoError(int dbConnectId) {
    int error = mysql_errno(dbConnectId);
    
    if ( error > 0 ) {
        Print("mysqlNoError: mysql_errno: ", mysql_errno(dbConnectId),"; mysql_error: ", mysql_error(dbConnectId));
        return (false);
    }
    return (true);
}
//+----------------------------------------------------------------------------+
//| vedroid:           http://dev.mysql.com/doc/refman/5.0/en/mysql-query.html |
//| I use mysql_query() and NOT mysql_real_query() because                     |
//| inside it uses C version of strlen(), which in our case is better. And it  |
//| cannot pass binary data such as '\0'.                                      |
//| In other cases these functions are the same.                               |
//+----------------------------------------------------------------------------+
bool mysqlQuery(int dbConnectId, string query) {
    mysql_query(dbConnectId, query);
    if ( mysqlNoError(dbConnectId) ) {
        return (true);
    }
    return (false);
}
//+----------------------------------------------------------------------------+
//| vedroid                                                                    |
//| return (-1): error; (0): 0 rows selected; (1): some rows selected;         |
//+----------------------------------------------------------------------------+
int mysqlFetchArray(int dbConnectId, string query, string & resultSet[][]){
    if ( !mysqlQuery(dbConnectId, query) ) {
        return (-1);
    }
    int resultStruct = mysql_store_result(dbConnectId);
    
    if ( !mysqlNoError(dbConnectId) ) {
        Print("mysqlFetchArray: resultStruct: ", resultStruct);
        return (-1);
    }
    int rows   = mysql_num_rows(resultStruct);
    int fields = mysql_num_fields(resultStruct);
    
    if ( rows == 0 ) {  // 0 rows selected;
        return (0);
    }
    
    string resultRow[0];
    ArrayResize(resultRow, fields);
    ArrayResize(resultSet, rows);
    //+------------------------------------------------------------------------+
    //| Modification to get fields' names                                      |
    //+------------------------------------------------------------------------+
    // string fieldSet[7];
    // ArrayResize(fieldSet, fields);
    // mt4_mysql_fetch_fields_string(resultStruct, fieldSet, FIELD_NAME);
    //+------------------------------------------------------------------------+
    for ( int i = 0; i < rows; i++ ) {
        mt4_mysql_fetch_row(resultStruct, resultRow, fields);
        for ( int j = 0; j < fields; j++ ) {
            resultSet[i][j] = resultRow[j];
        }
    }
    mysql_free_result(resultStruct);
    
    if ( mysqlNoError(dbConnectId) ) {
        return (1);
    }    
    return (-1);
}
//+----------------------------------------------------------------------------+

