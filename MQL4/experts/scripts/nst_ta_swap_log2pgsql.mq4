#property copyright "Copyright ? 2013 Nerrsoft.com"
#property link      "http://nerrsoft.com"
//--
#include <nst_ta_public.mqh>


//-- include public funcs
#include <nst_ta_public.mqh>
//-- include pgsql wrapper
#include <postgremql4.mqh>
string g_db_ip_setting          = "localhost";
string g_db_port_setting        = "5432";
string g_db_user_setting        = "postgres";
string g_db_password_setting    = "911911";
string g_db_name_setting        = "nst";

//-- account - mt4 account number; accountid - the account id in database;
int account, aid;
int magicnumber = 701;

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

    //--
    //checkOrderChange(aid, magicnumber);

    //--
    //logOrderInfo(aid, magicnumber);
    
    //-- exit script and close pgsql connection
    pmql_disconnect();
    return(0);
}

/*
 * Main Funcs
 */
void checkOrderChange(int _aid, int _mg)
{
    //-- load order status in database (from `nst_ta_swap_order`)
    //string query = "SELECT * FROM nst_ta_swap_order WHERE accountnumber=" + _an;
    //string res = pmql_exec(query);

    //-- load order info in metatrader
    for(int i = 0; i < OrdersHistoryTotal(); i++)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
            if(OrderMagicNumber() == _mg)
            {
                outputLog(OrderTicket(),"Debug");
            }
        }
    }

    //-- log new opened order information to database

    //-- log new closed order information to database
}

void logOrderInfo(int _aid, int _mg)
{
    string currtime = getCurrTime();
    int ordertotal = OrdersTotal();
    string query = "INSERT INTO nst_ta_swap_order_daily_settlement (accountid,orderticket,logdatetime,currentprice,profit,swap) VALUES ";

    //-- order log
    for(int i = 0; i < ordertotal; i++)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderMagicNumber() == _mg)
            {
                query = StringConcatenate(
                    query,
                    "(" + _aid + ", " + OrderTicket() + ", '" + currtime + "', " + OrderClosePrice() + ", " + OrderProfit() + ", " + OrderSwap() + "),"
                );
            }
        }
    }

    query = StringSubstr(query, 0, StringLen(query) - 1);

    string res = pmql_exec(query);

    outputLog(res);
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

//-- check sql result has error or not
bool is_error(string str)
{
    return(StringFind(str, "error") != -1);
}

//-- trans string query result to an array
void pmql_fetchArr(string _pgres, string &_data[][])
{
    int es, vs; //equalsign, verticalsing
    int size = ArrayRange(_data, 1);
    int i = 0;
    int ii = 0;
    int digi;

    ArrayResize(_data, pmql_fetchRows(_pgres));
    string res;
    _pgres = "*" + _pgres;

    while(StringFind(_pgres, "*", 0) == 0)
    {
        res = StringSubstr(_pgres, 0, StringFind(_pgres, "*", 1));

        for(ii = 0; ii < size; ii++)
        {
            //outputLog(i + "->" + ii);

            es = StringFind(res, "=", vs);
            vs = StringFind(res, "|", es);

            if(es+1==vs)
                _data[i,ii] = "";
            else if(es>0 && vs==-1)
                _data[i,ii] = StringSubstr(res, es+1, -1);
            else
                _data[i,ii] = StringSubstr(res, es+1, vs-es-1);
        }

        digi = StringFind(_pgres, "*", 1);

        if(digi == -1)
            break;
        else
        {
            _pgres = StringSubstr(_pgres, digi, StringLen(_pgres)-1);
            i++;
        }
    }
}

//-- fetch rows of a query
int pmql_fetchRows(string _pgres)
{
    int i = 0;
    int digi = 0;
    _pgres = "*" + _pgres;

    while(StringFind(_pgres, "*", 0) == 0)
    {
        i++;
        digi = StringFind(_pgres, "*", 1);

        if(digi == -1)
            break;
        else
            _pgres = StringSubstr(_pgres, digi, StringLen(_pgres)-1);
    }

    return(i);
}