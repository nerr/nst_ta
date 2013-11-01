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

int start()
{
    int num, ticketnum;
    string symbols[];
    double lots = 1;
    int magicnum = 100;

    num = libSymbolsList(symbols, true);
    for(int i = 0; i < num; i++)
    {
        ticketnum = OrderSend(symbols[i], OP_BUY,  lots, MarketInfo(symbols[i], MODE_ASK), 0, 0, 0, NULL, magicnum);
        Print(symbols[i] + " buy order ticket is " + ticketnum);
        ticketnum = OrderSend(symbols[i], OP_SELL, lots, MarketInfo(symbols[i], MODE_BID), 0, 0, 0, NULL, magicnum);
        Print(symbols[i] + " sell order ticket is " + ticketnum);
    }
}