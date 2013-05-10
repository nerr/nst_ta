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
 * TODO
 * 1. check order status - dose account has opened new order or closed some orders?
 * [Done]2. log active order information to pgsql database
*/

int start()
{
    //-- begin script and connect to pgsql
    string res = pmql_connect(g_db_ip_setting, g_db_port_setting, g_db_user_setting, g_db_password_setting, g_db_name_setting);
    if((res != "ok") && (res != "already connected"))
    {
        outputLog("DB not connected!", "PGSQL-ERR");
        return (-1);
    }

    //-- get account id
    account = AccountNumber();
    aid = getAccountIdByAccountNum(account);

    //--
    checkOrderChange(aid, magicnumber);

    //--
    logOrderInfo(aid, magicnumber);
    
    //-- exit script and close pgsql connection
    pmql_disconnect();
    return(0);
}

/*
 * Main Funcs
 */
void checkOrderChange(int _aid, int _mg)
{
    int i,j;

    //-- load history orders info in metatrader
    int otinmt[]; //-- order ticket in metatrader
    int n; //-- the real size of otinmt array
    int oht = OrdersHistoryTotal(); //-- order history total
    ArrayResize(otinmt, oht); //-- adjust otinmt array size but not final adjust
    
    for(i = 0; i < oht; i++)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
            if(OrderMagicNumber() == _mg)
            {
                otinmt[n] = OrderTicket();
                n++;
            }
        }
    }
    ArrayResize(otinmt, n-1); //-- final resize

    //--load available orders info in db
    string sdata[,1];
    int idata[];
    string query = "select orderticket from nst_ta_swap_order where orderstatus=0";
    string res = pmql_exec(query);
    pmql_fetchArr(res, sdata);
    int rows = ArraySize(sdata);

    formatOrderArr(sdata, idata);

    for(i = 0; i < rows; i++)
    {
        //outputLog(idata[i], "Debug");
    }


    /*int ticket_cache;
    for(j = 0; j < n; j++)
    {
        for(i = 0; i < rows; i++)
        {
            ticket_cache = StrToInteger(data[i][0]);

            if(ticket_cache == otinmt[j])
                break;

            if(i+1==rows)
                outputLog(ticket_cache + "is not in list", "Debug");
        }
    }*/

    //-- log new opened order information to database

    //-- log new closed order information to database
}

void logOrderInfo(int _aid, int _mg)
{
    string currtime = getCurrTime();
    string currdate = StringSubstr(currtime, 0, 10);
    string query = "select id from nst_ta_swap_order_daily_settlement where accountid=" + _aid + " and logdatetime > '" + currdate + "'";
    string res = pmql_exec(query);
    if(StringLen(res)>0)
    {
        return(1);
    }

    int ordertotal = OrdersTotal();
    query = "INSERT INTO nst_ta_swap_order_daily_settlement (accountid,orderticket,logdatetime,currentprice,profit,swap) VALUES ";

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

    res = pmql_exec(query);

    return(0);
}

/*
 * 
 */

//-- get the account id in db
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


/*
 * sub funcs of checkOrderChange() 
 */

//-- check _needle in _array or not
bool in_array(int _needle, int _array[])
{
    for(int i = 0; i < ArraySize(_array); i++)
    {
        if(_array[i] == _needle)
            return(true);
    }

    return(false);
}

//-- format order array from 2 range to 1 range which query from pgsql and trans data type from string to int
void formatOrderArr(string _sourcearr[][], int &_targetarr[])
{
    int itemnum = ArraySize(_sourcearr);
    ArrayResize(_targetarr, itemnum);

    outputLog(itemnum, "Debug");

    if(itemnum > 0)
    {
        for(int i = 0; i < itemnum; i++)
        {
            _targetarr[i] = StrToInteger(_sourcearr[i][0]);
        }
    }
}