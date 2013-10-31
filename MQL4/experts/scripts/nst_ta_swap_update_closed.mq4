/* 
 * Nerr Smart Trader - Triangular Arbitrage Trading System -> Swap
 *
 * By Leon Zhuang
 * Twitter @Nerrsoft
 * leon@nerrsoft.com
 * http://nerrsoft.com
 * 
 */

#property copyright "Copyright ? 2013 Nerrsoft.com"
#property link      "http://nerrsoft.com"
#property indicator_chart_window



/* 
 * include library
 *
 */

#include <nst_lib_all.mqh>
#include <postgremql4.mqh>



/* 
 * define global var
 *
 */

int MagicNumber = 701;
int account;


//-- start
int start()
{
    //-- begin script and connect to pgsql
    string res = pmql_connect("localhost", "5432", "postgres", "911911", "nst");
    if((res != "ok") && (res != "already connected"))
    {
        libDebugOutputLog("DB not connected!", "PGSQL-ERR");
        return (-1);
    }

    //-- get account id
    account = AccountNumber();

    //--
    logOrderInfo(account, MagicNumber);

    return(0);
}


int logOrderInfo(int _an, int _mg)
{
    int ordertotal = OrdersTotal();
    string query = "INSERT INTO nst_ta_swap_order_ending (userid, orderticket, opendate, closedate, swap, ordertype, openprice, closeprice, profit, commission, accountid, ordercomment) VALUES ";

    //-- order log
    for(int i = 0; i < ordertotal; i++)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
            if(OrderMagicNumber() == _mg)
            {
                query = StringConcatenate(
                    query,
                    "(5, " + OrderTicket() + ", '" + OrderOpenTime() + "', '" + OrderCloseTime() + "', " + OrderSwap() + ", " + OrderType() + ", " + OrderOpenPrice() + ", " + OrderClosePrice() + ", " + OrderProfit() + "," + OrderCommission() + ", " + _an + ", '" + OrderComment() + "'),"
                );
            }
        }
    }
    query = StringSubstr(query, 0, StringLen(query) - 1);
    string res = pmql_exec(query);

    return(0);
}