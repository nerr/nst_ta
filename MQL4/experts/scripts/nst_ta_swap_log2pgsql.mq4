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

    //--
    logSwapRate(aid);
    
    //-- exit script and close pgsql connection
    pmql_disconnect();
    return(0);
}

/*
 * Main Funcs
 */
void checkOrderChange(int _aid, int _mg)
{
    //-- update new closed order to db
    update2db(1, _mg);
    //-- update new opened order to db
    update2db(0, _mg);
}

int logOrderInfo(int _aid, int _mg)
{
    string currtime = getTime(TimeLocal());
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

//-- log swap rate to database
int logSwapRate(int _aid)
{
    string _symbols[5];
    _symbols[0] = "USDMXN";
    _symbols[1] = "EURMXN";
    _symbols[2] = "USDJPY";
    _symbols[3] = "EURJPY";
    _symbols[4] = "MXNJPY";

    double _longswap, _shortswap;

    string currtime = getTime(TimeLocal());
    string currdate = StringSubstr(currtime, 0, 10);
    string query = "select id from nst_ta_swap_rate where accountid=" + _aid + " and logdatetime > '" + currdate + "'";
    string res = pmql_exec(query);
    if(StringLen(res)>0)
    {
        return(1);
    }

    query = "INSERT INTO nst_ta_swap_rate (accountid,symbol,longswap,shortswap,logdatetime) VALUES ";

    for(int i = 0; i < ArraySize(_symbols); i++)
    {
        _longswap  = MarketInfo(_symbols[i], MODE_SWAPLONG);
        _shortswap = MarketInfo(_symbols[i], MODE_SWAPSHORT);

        query = StringConcatenate(
            query,
            "(" + _aid + ", '" + _symbols[i] + "', " + _longswap + ", " + _shortswap + ", '" + currtime + "'),"
        );
    }

    query = StringSubstr(query, 0, StringLen(query) - 1);

    //outputLog(query, "PGSQL");

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

//-- get string time and format
string getTime(datetime _t)
{
    string strtime = TimeToStr(_t, TIME_DATE | TIME_SECONDS);
    strtime = StringSetChar(strtime, 4, '-');
    strtime = StringSetChar(strtime, 7, '-');

    return(strtime);
}


//-- check sql result has error or not
bool is_error(string _str)
{
    return(StringFind(_str, "error") != -1);
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

    if(itemnum > 0)
    {
        for(int i = 0; i < itemnum; i++)
        {
            _targetarr[i] = StrToInteger(_sourcearr[i][0]);
        }
    }
}

//--
void update2db(int _type, int _mg)
{
    int i;
    //-- load orders ticket from metatrader
    int ordertickets[]; //-- order ticket in metatrader
    int realticketnum = 0; //-- the real size of otinmt array
    int ordertotal; //-- order history total
    if(_type == 1)
        ordertotal = OrdersHistoryTotal();
    else if(_type == 0)
        ordertotal = OrdersTotal();

    //-- adjust otinmt array size but not final adjust
    ArrayResize(ordertickets, ordertotal);

    if(ordertotal > 0)
    {
        for(i = 0; i < ordertotal; i++)
        {
            
            if(_type == 1)
            {
                if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
                {
                    if(OrderMagicNumber() == _mg)
                    {
                        ordertickets[realticketnum] = OrderTicket();
                        realticketnum++;
                    }
                }
            }
            else if(_type == 0)
            {
                if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                {
                    if(OrderMagicNumber() == _mg)
                    {
                        ordertickets[realticketnum] = OrderTicket();
                        realticketnum++;
                    }
                }
            }
        }
        ArrayResize(ordertickets, realticketnum); //-- final resize
    }
    else
    {
        sendAlert("No order find, maybe there is no closed order yet or the history period was set wrong.","Notifi<" + account + ">log2pgsql");
    }

    //-- load closed orders info from db
    string sdata[,1];
    int idata[];
    int rows = 0;
    string query = "select orderticket from nst_ta_swap_order where orderstatus=" + _type;
    string res = pmql_exec(query);

    if(StringLen(res) > 0)
    {
        pmql_fetchArr(res, sdata);
        rows = ArraySize(sdata);
        //outputLog(rows, "Debug");
        formatOrderArr(sdata, idata);
    }

    if(rows == 0)
    {
        if(realticketnum > 0)
        {
            for(i = 0; i < realticketnum; i++)
            {
                if(_type == 1)
                    update2closed(ordertickets[i]);
                else if(_type == 0)
                    insert2opened(ordertickets[i]);
            }
        }
    }

    if(realticketnum > 0 && rows > 0)
    {
        for(i = 0; i < realticketnum; i++)
        {
            if(!in_array(ordertickets[i], idata))
            {
                for(i = 0; i < realticketnum; i++)
                {
                    if(_type == 1)
                        update2closed(ordertickets[i]);
                    else if(_type == 0)
                        insert2opened(ordertickets[i]);
                }
            }
        }
    }
}

//-- update order status to closed to db by order ticket
int update2closed(int _oid)
{
    if(!OrderSelect(_oid, SELECT_BY_TICKET, MODE_HISTORY))
    {
        outputLog("There was not find this history order [" + _oid + "], please check.", "Err");
        return(1);
    }

    string closetime = getTime(OrderCloseTime());

    string query = "UPDATE nst_ta_swap_order SET orderstatus=1, closedate='" + closetime + "', getswap=" + OrderSwap() + ", closeprice=" + OrderClosePrice() + ", endprofit=" + OrderProfit() + " WHERE orderticket=" + _oid;
    string res = pmql_exec(query);

    if(is_error(res))
    {
        outputLog("update history order status error [" + _oid + "], please check. " + query, "Err");
        insert2closed(_oid);
    }

    return(0);
}

//-- insert order status to closed to db by order ticket
int insert2closed(int _oid)
{
    if(!OrderSelect(_oid, SELECT_BY_TICKET, MODE_HISTORY))
    {
        outputLog("There was not find this history order [" + _oid + "], please check.", "Err");
        return(1);
    }

    string closetime = getTime(OrderCloseTime());
    string opentime = getTime(OrderOpenTime());

    string query = "INSERT INTO nst_ta_swap_order (userid,orderticket,usemargin,opendate,orderstatus,closedate,getswap,ordertype,openprice,commission,closeprice,endprofit) VALUES (1," + _oid + ",0,'" + opentime + "',1,'" + closetime + "'," + OrderSwap() + "," + OrderType() + "," + OrderOpenPrice() + "," + OrderCommission() + "," + OrderClosePrice() + "," + OrderProfit() + ")";
    string res = pmql_exec(query);

    if(is_error(res))
        outputLog("inster into closed order status error [" + _oid + "], please check. "+query, "Err");
    else
        outputLog("inster into closed order OK", "Status");

    return(0);
}

int insert2opened(int _oid)
{
    if(!OrderSelect(_oid, SELECT_BY_TICKET, MODE_TRADES))
    {
        outputLog("There was not find this opened order [" + _oid + "], please check.", "Err");
        return(1);
    }

    string opentime = getTime(OrderOpenTime());

    string query = "INSERT INTO nst_ta_swap_order (userid,orderticket,usemargin,opendate,orderstatus,ordertype,openprice,commission) VALUES (1," + _oid + ",0,'" + opentime + "',0," + OrderType() + "," + OrderOpenPrice() + "," + OrderCommission() + ")";
    string res = pmql_exec(query);

    if(is_error(res))
        outputLog("inster into opened order status error [" + _oid + "], please check. "+query, "Err");
    else
        outputLog("inster into opened order OK", "Status");

    return(0);
}


//-- Debug array - print per item of an array
void arrdebug(int _arr[])
{
    string debugstr = "";
    for(int i = 0; i < ArraySize(_arr); i++)
        debugstr = debugstr + _arr[i] + "|";

    outputLog(debugstr, "Debug-Array");
}