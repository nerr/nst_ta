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

double baselot = 1;

string broker;


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
    broker  = AccountCompany();
    
    //--
    openRingFromDb(account, broker, MagicNumber, baselot);

    return(0);
}

void openRingFromDb(int _an, string _bn, int _mn, double _bl)
{
    string sdata[,3];
    int rows = 0;
    string query = "select symbol_a, symbol_b, symbol_c from test_profitable_rings where broker='" + _bn + "' and accountnum='" + _an + "' and expected>30";
    string res = pmql_exec(query);

    Print(res);

    if(StringLen(res)>0)
    {
        libPgsqlFetchArr(res, sdata);
        rows = ArraySize(sdata);

        for(int i = 0; i < rows; i++)
        {
            Print(sdata[i,0] + " | " + sdata[i,1] + " | " + sdata[i,2]);
        }
    }




}