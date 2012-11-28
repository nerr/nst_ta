/* Nerr Smart Trader - Triangular Arbitrage Trading System
 *
 * By Leon Zhuang
 * Twitter @Nerrsoft
 * leon@nerrsoft.com
 * http://nerrsoft.com
 *  
 * @History
 * v0.0.1  [dev] 2012-11-27 
 *
 *
 * @Todo
 */



#property copyright "Copyright ? 2012 Nerrsoft.com"
#property link      "http://nerrsoft.com"



/* 
 * define extern
 *
 */

extern int 		MagicNumber 	= 99901;



/* 
 * Global variable
 *
 */

string Ring[200, 4], SymExt;
double FPI[1, 8], RingOrd[1, 10], Thold[1, 2], RingM[1, 4];
int ringnum;



/* 
 * System Funcs
 *
 */

//-- init
int init()
{
	return(0);
}

//-- deinit
int deinit()
{
	return(0);
}

//-- start
int start()
{
	return(0);
}



//-- 
int closeRing()
{
	int total = OrdersTotal();
	for(int i=total-1; i>=0; i--)
	{
		OrderSelect(i, SELECT_BY_POS);
		int type   = OrderType();

		bool result = false;

		if(OrderMagicNumber() == MagicNumber)
		{
			switch(type)
			{
				//Close opened long positions
				case OP_BUY       : result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3, Red );
				break;
				//Close opened short positions
				case OP_SELL      : result = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 3, Red );
			}
		}

		if(result == false)
		{
			Alert("Order " , OrderTicket() , " failed to close. Error:" , GetLastError() );
			closeRing();
			Sleep(300);
		}
	}

	return(0);
}