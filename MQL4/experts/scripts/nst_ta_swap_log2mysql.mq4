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



void start()
{
    //-- connect mysql and create table if none
    goodConnect = DB_connectdb();
    if(!goodConnect)
    {
        outputLog("Connect db failed", "MySQL Error");
        return (1);
    }




    /*db_name = db_name + AccountNumber() + ".db";

    string currtime = TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS);
    DB_logOrderInfo(db_name, db_ordertable, currtime, magicnum);
    DB_logAccountInfo(db_name, db_accounttable, currtime);*/
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

void DB_logFpi2DB(int _dbconnid, string _table, double _fpi[][8])
{
    string query = "INSERT INTO `" + _table + "` (ringidx, lfpi, sfpi, marketdate) VALUES ";
    string marketdate = TimeToStr(TimeCurrent(), TIME_DATE|TIME_SECONDS);

    for(int i = 1; i < ringnum; i++)
    {
        query = query + "(" + i + ", " + _fpi[i][1] + ", " + _fpi[i][3] + ", '" + marketdate + "'),";
        
    }
    query = StringSubstr(query, 0, StringLen(query) - 1);
    mysqlQuery(_dbconnid, query);
}

void DB_close()
{
    mysqlDeinit(dbConnectId);
}