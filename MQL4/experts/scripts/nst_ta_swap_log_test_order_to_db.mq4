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
int account;
string brokername;

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

    //-- get account id
    account = AccountNumber();
    brokername = AccountCompany();
    
    //-- run
    log2db(account, brokername, MagicNumber);

    return(0);
}



//-- log order information to database
int log2db(int _an, string _bn, int _mn)
{
    string query = "INSERT INTO test_order_info (orderticket, opendate, symbol, lots, commission, swap, ordertype, openprice, sl, tp, profit, ordercomment, broker, accountnum, longswap, shortswap) VALUES ";
    string opendt = "";

    double longswap, shortswap;

    int ordernum = OrdersTotal();

    //-- order log
    for(int i = 0; i < ordernum; i++)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderMagicNumber() == _mn)
            {
                opendt = libDatetimeTm2str(OrderOpenTime());
                longswap = MarketInfo(OrderSymbol(), MODE_SWAPLONG);
                shortswap= MarketInfo(OrderSymbol(), MODE_SWAPSHORT);
                query = StringConcatenate(
                    query,
                    "(" + OrderTicket() + ", '" + opendt + "', '" + OrderSymbol() + "', " + OrderLots() + ", " + OrderCommission() + ", " + OrderSwap() + ", " + OrderType() + ", " + OrderOpenPrice() + ", " + OrderStopLoss() + ", " + OrderTakeProfit() + ", " + OrderProfit() + ", '" + OrderComment() + "', '" + _bn + "', '" + _an + "'),"
                );
            }
            //Print(OrderTicket());
        }
    }
    query = StringSubstr(query, 0, StringLen(query) - 1);
    string res = pmql_exec(query);

    return(0);
}