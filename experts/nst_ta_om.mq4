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

extern int 	MagicNumber = 99901;



/* 
 * Global variable
 *
 */

int 	ROTicket[100, 5]; //-- ringindex， a, b, c, direction
double 	ROProfit[100, 6]; //-- total, a, b, c, target, ringfpi



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
	checkCurrentOrder(MagicNumber, ROTicket, ROProfit);
	updateRingInfo(ROTicket, ROProfit);

	return(0);
}

//-- check current order
void checkCurrentOrder(int _magicnumber, int &_roticket[][], double &_roprofit[][])
{
	//-- init ring order array
	ArrayResize(_roticket, 0);
	ArrayResize(_roticket, 100);

	ArrayResize(_roprofit, 0);
	ArrayResize(_roprofit, 100);

	double ringfpi;
	int i, j, ringindex, ringdirection, symbolindex, arridx, n = 0;
	int total = OrdersTotal();

	//-- begin
	if(total == 0)
	{
		ArrayResize(_roprofit, 0);
		ArrayResize(_roticket, 0);
	}
	else
	{
		for(i = 0; i < total; i++)
		{
			if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
			{
				if(OrderMagicNumber() == _magicnumber)
				{
					//-- analytic comment information
					getInfoByComment(OrderComment(), ringindex, symbolindex, ringdirection, ringfpi);
					//Alert(" ri:"+ringindex+" si:"+symbolindex+" rd:"+ringdirection+" rf:"+ringfpi);
					//--
					arridx = findRingOrdIdx(_roticket, _roprofit, ringindex, ringfpi);
					//Alert(arridx);

					if(arridx == -1)
					{
						_roticket[n][0] = ringindex;
						_roticket[n][4] = ringdirection;
						_roticket[n][symbolindex] = OrderTicket();

						_roprofit[n][5] = ringfpi;
						_roprofit[n][symbolindex] = OrderProfit() + OrderSwap() + OrderCommission();
						_roprofit[n][0] += _roprofit[n][symbolindex];

						if(symbolindex==1)
							_roprofit[n][4] = OrderLots();

						n++;
					}
					else
					{
						_roticket[arridx][symbolindex] = OrderTicket();

						_roprofit[arridx][symbolindex] = OrderProfit() + OrderSwap() + OrderCommission();
						_roprofit[arridx][0] += _roprofit[arridx][symbolindex];

						if(symbolindex==1)
							_roprofit[arridx][4] = OrderLots();
					}
				}
			}
		}

		ArrayResize(_roticket, n);
		ArrayResize(_roprofit, n);

		for(i = 0; i < n; i++)
		{
			_roprofit[i][4] *= 40;

			if(_roprofit[i][0] >= _roprofit[i][4])
				closeRing(_roticket, i);
		}
	}
}

//-- init debug info object on chart
void initDebugInfo()
{
	ObjectsDeleteAll();

	color bgcolor = C'0x27,0x28,0x22';
	color titlecolor = C'0xd9,0x26,0x59';
	int y, i, j;

	//-- background
	for(int bgnum = 0; bgnum < 4; bgnum++)
	{
		ObjectCreate("bg_"+bgnum, OBJ_LABEL, 0, 0, 0);
		ObjectSetText("bg_"+bgnum, "g", 300, "Webdings", bgcolor);
		ObjectSet("bg_"+bgnum, OBJPROP_BACK, false);
		ObjectSet("bg_"+bgnum, OBJPROP_XDISTANCE, 20 + bgnum % 2 * 400);
		ObjectSet("bg_"+bgnum, OBJPROP_YDISTANCE, 13 + bgnum / 2 * 387);
	}

	//-- ring info
	y += 15;
	createTextObj("ring_header", 25,	y, ">>>Ring", titlecolor);
	y += 15;
	createTextObj("order_header_col_0", 25, y, "RingId");
	createTextObj("order_header_col_1", 90,y, "OrderA");
	createTextObj("order_header_col_2", 180,y, "OrderB");
	createTextObj("order_header_col_3", 270,y, "OrderC");
	createTextObj("order_header_col_4", 350,y, "ProfitA");
	createTextObj("order_header_col_5", 425,y, "ProfitB");
	createTextObj("order_header_col_6", 500,y, "ProfitC");
	createTextObj("order_header_col_7", 575,y, "Summary");
	createTextObj("order_header_col_8", 650,y, "Target");
	createTextObj("order_header_col_9", 740,y, "FPI");
}

//-- update ring order information to chart
void updateRingInfo(int _roticket[][], double _roprofit[][])
{
	int i, j, y = 30;
	int row = ArrayRange(_roticket, 0);
	double total = 0;

	for(i = 0; i < 200; i ++)
	{
		for(j = 0; j < 10; j ++)
			ObjectDelete("order_body_row_" + i + "_col_" + j);
	}

	for(i = 0; i < row; i ++)
	{
		y += 15;
		createTextObj("order_body_row_" + i + "_col_0", 25, y, _roticket[i][0], Gray);
		createTextObj("order_body_row_" + i + "_col_1", 90,y, _roticket[i][1], White);
		createTextObj("order_body_row_" + i + "_col_2", 180,y, _roticket[i][2], White);
		createTextObj("order_body_row_" + i + "_col_3", 270,y, _roticket[i][3], White);
		createTextObj("order_body_row_" + i + "_col_4", 350,y, DoubleToStr(_roprofit[i][1], 2), White);
		createTextObj("order_body_row_" + i + "_col_5", 425,y, DoubleToStr(_roprofit[i][2], 2), White);
		createTextObj("order_body_row_" + i + "_col_6", 500,y, DoubleToStr(_roprofit[i][3], 2), White);
		createTextObj("order_body_row_" + i + "_col_7", 575,y, DoubleToStr(_roprofit[i][0], 2), DeepSkyBlue);
		createTextObj("order_body_row_" + i + "_col_8", 650,y, DoubleToStr(_roprofit[i][4], 2), Magenta);
		createTextObj("order_body_row_" + i + "_col_9", 740,y, DoubleToStr(_roprofit[i][5], 8), White);

		total += _roprofit[i][0];
	}

	y += 15;
	i++;
	createTextObj("order_body_row_" + i + "_col_0", 25, y, "Total");
	createTextObj("order_body_row_" + i + "_col_7", 575,y, DoubleToStr(total, 2), Crimson);
}

//-- 
void closeRing(int _roticket[][], int _ringindex)
{
	for(int i = 1; i < 4; i++)
		closeOrder(_roticket[_ringindex][i]);
}

void closeOrder(int _ticket, int _timer = 0)
{
	bool status = false;
	if(_timer > 5)
		sendAlert("Order:[" + _ticket + "] can not be close, please check it as soon as possible.", "Close Order Error");

	if(OrderSelect(_ticket, SELECT_BY_TICKET))
	{
		if(OrderType() == OP_BUY)  
			status = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3);
		else if(OrderType() == OP_SELL) 
			status = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 3);

		if(status == false)
			_timer++;
			closeOrder(_ticket, _timer);
	}
}