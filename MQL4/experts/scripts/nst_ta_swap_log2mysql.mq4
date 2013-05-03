#property copyright "Copyright ? 2013 Nerrsoft.com"
#property link      "http://nerrsoft.com"
//--
#include <nst_ta_public.mqh>


//-- include public funcs
#include <nst_ta_public.mqh>
//-- include mysql wrapper
#include <mysql.mqh>
int     socket      = 0;
int     client      = 0;
int     dbConnectId = 0;
bool    goodConnect = false;
string  fpitable    = "nst_ta_fpi_";
string  tholdtable  = "nst_ta_thold_";

extern string   DBSetting       = "---------MySQL Setting---------";
extern bool     LogFpiToDB      = true;
extern string   host            = "127.0.0.1";
extern string   user            = "root";
extern string   pass            = "911911";
extern string   dbName          = "nst";
extern int      port            = 3306;

//-- account - mt account number; accountid - the id in mysql db;
int account, accountid;

/*
plan
1. check order status - dose account has opened new order or closed some orders?
2. log active order information to mysql database

*/

void start()
{
    //-- connect mysql and create table if none
    goodConnect = DB_connectdb();
    if(!goodConnect)
    {
        outputLog("Connect db failed", "MySQL Error");
        return (1);
    }

    //-- get information
    account = AccountNumber();
    accountid = getAccountIdByAccountNum(dbConnectId, account);

    //-- check order change
    checkOrder(dbConnectId, accountid);


    //-- close mysql connect
    DB_close(dbConnectId);
}

/*
 * Main Funcs
 */
void checkOrder(int _dbconnid, int _aid)
{
    //-- load order info in database

    //-- load order info in metatrader

    //-- log new opened order information to database

    //-- log new closed order information to database

    Alert(_aid);

}

void logInfo(int _dbconnid, int _aid)
{
    /*db_name = db_name + AccountNumber() + ".db";

    string currtime = TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS);
    DB_logOrderInfo(db_name, db_ordertable, currtime, magicnum);
    DB_logAccountInfo(db_name, db_accounttable, currtime);*/
}

/*
 * 
 */
int getAccountIdByAccountNum(int _dbconnid, int _an)
{
    string data[][1];
    string query = "SELECT id FROM nst_sys_account WHERE accountnumber=" + _an;
    int result = mysqlFetchArray(_dbconnid, query, data);

    return(StrToInteger(data[0][0]));
}


/* 
 * MySQL Funcs
 *
 */

//-- connect to database
int DB_connectdb()
{
    //-- close connection if exists
    if(dbConnectId>0)
        mysqlDeinit(dbConnectId);

    //-- connect mysql
    bool result = mysqlInit(dbConnectId, host, user, pass, dbName, port, socket, client);

    return (result);
}

void DB_close(int _dbconnid)
{
    mysqlDeinit(_dbconnid);
}