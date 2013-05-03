#property copyright "Copyright ? 2013 Nerrsoft.com"
#property link      "http://nerrsoft.com"
//--
#include <nst_ta_public.mqh>


//-- include public funcs
#include <nst_ta_public.mqh>
//-- include pgsql wrapper
#include <postgremql4.mqh>
string g_db_ip_setting 			= "localhost";
string g_db_port_setting 		= "5432";
string g_db_user_setting 		= "postgres";
string g_db_password_setting 	= "911911";
string g_db_name_setting 		= "nst";

//-- account - mt account number; accountid - the id in mysql db;
int account, aid;

/*
plan
1. check order status - dose account has opened new order or closed some orders?
2. log active order information to mysql database

*/

int start()
{
    //-- begin script and connect to pgsql
    string res = pmql_connect(g_db_ip_setting, g_db_port_setting, g_db_user_setting, g_db_password_setting, g_db_name_setting);
    if((res != "ok") && (res != "already connected"))
    {
        outputLog("DB not connected!", "PostgreSQL ERROR");
        return (-1);
    }

    //-- get account id
    account = AccountNumber();
    aid = getAccountIdByAccountNum(account);






    

    //-- exit script and close pgsql connection
    pmql_disconnect();
    return(0);
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

void logInfo(int _aid)
{
    /*db_name = db_name + AccountNumber() + ".db";

    string currtime = TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS);
    DB_logOrderInfo(db_name, db_ordertable, currtime, magicnum);
    DB_logAccountInfo(db_name, db_accounttable, currtime);*/
}

/*
 * 
 */
int getAccountIdByAccountNum(int _an)
{
    string query = "SELECT id FROM nst_sys_account WHERE accountnumber=" + _an;
    string res = pmql_exec(query);
    int id = StrToInteger(StringSubstr(res, 3, 1));

    return(id);
}

//-- get local time
string getCurrTime()
{
    string currtime = TimeToStr(TimeLocal(), TIME_DATE | TIME_SECONDS);
    currtime = StringSetChar(currtime, 4, '-');
    currtime = StringSetChar(currtime, 7, '-');

    return(currtime);
}

//--
bool is_error(string str)
{
    return(StringFind(str, "error") != -1);
}