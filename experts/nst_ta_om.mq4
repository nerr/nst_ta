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



//--
#include <nst_ta_public.mqh>



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
	initDebugInfo();
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




//-- init debug info object on chart
void initDebugInfo()
{
	color bgcolor = C'0x27,0x28,0x22';
	color titlecolor = C'0xd9,0x26,0x59';
	int y, i, j;

	//-- background
	for(int bgnum = 0; bgnum < 8; bgnum++)
	{
		ObjectCreate("bg_"+bgnum, OBJ_LABEL, 0, 0, 0);
		ObjectSetText("bg_"+bgnum, "g", 300, "Webdings", bgcolor);
		ObjectSet("bg_"+bgnum, OBJPROP_BACK, false);
		ObjectSet("bg_"+bgnum, OBJPROP_XDISTANCE, 20 + bgnum % 2 * 400);
		ObjectSet("bg_"+bgnum, OBJPROP_YDISTANCE, 13 + bgnum / 2 * 387);
	}

	//-- ring info
	y += 15 * 2;
	createTextObj("ring_header", 25,	y, ">>>Ring", titlecolor);
	y += 15;
	createTextObj("order_header_col_0", 25, y, "RingId");
	createTextObj("order_header_col_1", 100,y, "OrderA");
	createTextObj("order_header_col_2", 200,y, "OrderB");
	createTextObj("order_header_col_3", 300,y, "OrderC");
	createTextObj("order_header_col_4", 400,y, "ProfitA");
	createTextObj("order_header_col_5", 475,y, "ProfitB");
	createTextObj("order_header_col_6", 550,y, "ProfitC");
	createTextObj("order_header_col_7", 625,y, "Summary");
	createTextObj("order_header_col_8", 700,y, "FPI");

	for(i = 0; i < 50; i ++)
	{
		y += 15;
		createTextObj("order_body_row_" + i + "_col_0", 25, y);
		createTextObj("order_body_row_" + i + "_col_1", 100,y);
		createTextObj("order_body_row_" + i + "_col_2", 200,y);
		createTextObj("order_body_row_" + i + "_col_3", 300,y);
		createTextObj("order_body_row_" + i + "_col_4", 400,y);
		createTextObj("order_body_row_" + i + "_col_5", 475,y);
		createTextObj("order_body_row_" + i + "_col_6", 550,y);
		createTextObj("order_body_row_" + i + "_col_7", 625,y);
		createTextObj("order_body_row_" + i + "_col_8", 700,y);
	}
}

//-- update ring order information to chart
void updateRingInfo(double _ringord[][])
{
	int i, j;
	int row = ArrayRange(_ringord, 0);
	int col= ArrayRange(_ringord, 1);

	for(i = 0; i < row; i ++)
	{
		if(_ringord[i][0] > 0)
		{
			setTextObj("order_body_row_" + i + "_col_0", DoubleToStr(_ringord[i][0], 0));
			setTextObj("order_body_row_" + i + "_col_1", DoubleToStr(_ringord[i][1], 0));
			setTextObj("order_body_row_" + i + "_col_2", DoubleToStr(_ringord[i][2], 0));
			setTextObj("order_body_row_" + i + "_col_3", DoubleToStr(_ringord[i][3], 0));
			setTextObj("order_body_row_" + i + "_col_4", DoubleToStr(_ringord[i][4], 2));
			setTextObj("order_body_row_" + i + "_col_5", DoubleToStr(_ringord[i][5], 2));
			setTextObj("order_body_row_" + i + "_col_6", DoubleToStr(_ringord[i][6], 2));
			setTextObj("order_body_row_" + i + "_col_7", DoubleToStr(_ringord[i][7], 2), DeepSkyBlue);
			setTextObj("order_body_row_" + i + "_col_8", DoubleToStr(_ringord[i][8], 8));
		}
		else
		{
			for(j = 0; j < col; j++)
			{
				setTextObj("order_body_row_" + i + "_col_" + j, "");
			}
		}
	}
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