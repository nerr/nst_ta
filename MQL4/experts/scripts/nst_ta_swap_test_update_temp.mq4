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

int MagicNumber = 100;

//-- start
int start()
{
    //-- begin script and connect to pgsql
    string res = pmql_connect("192.168.11.6", "5432", "postgres", "911911", "nst");
    if((res != "ok") && (res != "already connected"))
    {
        libDebugOutputLog("DB not connected!", "PGSQL-ERR");
        return (-1);
    }
    
    //-- run
    log2db(MagicNumber);

    return(0);
}



//-- log order information to database
int log2db(int _mn)
{
    string query = "";

    double longswap, shortswap;

    int ordernum = OrdersTotal();

    //-- order log
    for(int i = 0; i < ordernum; i++)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderMagicNumber() == _mn)
            {

                longswap = MarketInfo(OrderSymbol(), MODE_SWAPLONG);
                shortswap= MarketInfo(OrderSymbol(), MODE_SWAPSHORT);
                
                query = "update test_order_info set longswap=" + longswap + ", shortswap=" + shortswap + " where orderticket=" + OrderTicket();
                pmql_exec(query);
            }
            //Print(OrderTicket());
        }
    }

    return(0);
}