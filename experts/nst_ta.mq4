/* Nerr Smart Trader - Triangular Arbitrage Trading System
 *
 * By Leon Zhuang
 * Twitter @Nerrsoft
 * leon@nerrsoft.com
 * http://nerrsoft.com
 *  
 * @History
 * v0.0.2  [dev] 2012-05-01 add information on display chart. 
 * v0.0.3  [dev] 2012-05-03 recode information display format, fix some typo. 
 * v0.0.4  [dev] 2012-05-04 now can set the symbol team by user; add comment for program; slim code.
 * v0.0.5  [dev] 2012-05-14 re-calcu fpi and three symbol price (current).
 * v0.0.6  [dev] 2012-05-15 re-calcu order lot, base pair and hedge paris.
 * v0.0.7  [dev] 2012-05-18 display has order or not. display a ring trade high profit to low profit
 * v0.0.8  [dev] 2012-05-22 change openorder() and closeorder() fun name to openRing() and closeRing(), remove close fun's parama, and recode open and close ring fun.
 * v0.0.9  [dev] 2012-05-22 update openRing() fun.
 * v0.0.10 [dev] 2012-05-22 add three symbol spread summary check (), change comment text.
 * v0.0.11 [dev] 2012-05-23 add extern ver "MaxSpread" use to some special ring; remove "ProfitMargin".
 * v0.0.12 [dev] 2012-05-24 fix checkProfit() magic number bug, fix display bug, remove openRing() sleep.
 * v0.0.13 [dev] 2012-05-28 add open sell order when sellFPI to thold value.
 * v0.0.14 [dev] 2012-05-28 add play sound notification when open or close order.
 * v0.0.15 [dev] 2012-05-29 fix close bug.
 * v0.0.16 [dev] 2012-05-29 split ta fun with TAOpen() and TAClose().
 * v0.0.17 [dev] 2012-05-29 fix checkProfit() bug; add real ring FPI var.
 * v0.0.18 [dev] 2012-05-30 add margin level check.fix margin level cal bug.
 * v0.1.0  [dev] 2012-11-19 new begin;
 * v0.1.1  [dev] 2012-11-20 finished calcu fpi indicator and show it on chart;
 * v0.1.2  [dev] 2012-11-20 finished new openRing() func, if price change than open limit order;
 * v0.1.3  [dev] 2012-11-20 finished the open order and check trade chance, no grammar error but not test yet;
 * v0.1.4  [dev] 2012-11-21 fix a trade thold bug, add "get price without stop";
 * v0.1.5  [dev] 2012-11-21 add settings information to chart;
 * v0.1.6  [dev] 2012-11-21 add extern item "LotsDigit" default value is 2, but some account allow 1 digit only; fix third order log output text;
 * v0.1.7  [dev] 2012-11-21 change debug object style;
 * v0.1.8  [dev] 2012-11-21 add updateSettingInfo() func;
 * v0.1.9  [dev] 2012-11-22 add checkUnavailableSymbol() func use to self-adaption current support symbol; add 6 new ring;
 * v0.1.10 [dev] 2012-11-22 finished auto get all ring of current broker;
 * v0.1.11 [dev] 2012-11-22 add extern item "Currencies" use to custum currency whitch user want it;
 * v0.1.12 [dev] 2012-11-22 fix ring table header real ring number;
 * v0.1.13 [dev] 2012-11-22 add col name "sH-bL" in ring table;
 * v0.1.14 [dev] 2012-11-23 add errorDescription() func use to desc error code; add background;
 * v0.1.15 [dev] 2012-11-25 change extern Currencies default value;
 * v0.1.16 [dev] 2012-11-25 remove the while() int start() func; change order comment info format add symbol number behind ring index;
 * v0.1.17 [dev] 2012-11-25 add ringHaveOrder() func use to check a ring have order or not; add updateRingInfo() func; finished checkCurrentOrder() func;
 * v0.1.18 [dev] 2012-11-26 debug func updateRingInfo() and checkCurrentOrder() bug; change default extern Magicnumber value;
 * v0.1.19 [dev] 2012-11-26 fix some typo bug; ring info part can runable but not complete;
 * v0.1.20 [dev] 2012-11-26 finished auto get thold value and remove extern about thold item;
 * v0.1.21 [dev] 2012-11-28 fix special symbol name bug;
 * v0.1.22 [dev] 2012-11-29 fix a small bug but it deadly, revised ringHaveOrder() first param;
 * v0.1.23 [dev] 2012-11-29 simplify code and change extern item "Currencies" default value;
 * v0.1.24 [dev] 2012-11-29 add remove all object item in initDebugInfo() func;
 * v0.1.25 [dev] 2012-11-29 mv order management funcs to nst_ta_public.mq4;
 * v0.1.26 [dev] 2012-12-03 restructure "initDubugChart()" func;
 * v0.1.27 [dev] 2012-12-03 merge mq4 file nst_ta and nst_ta_om; remove nst_ta_om.mq4 file;
 * v0.1.28 [dev] 2012-12-04 adjuse the coordinate of display object;
 * v0.1.29 [dev] 2012-12-04 fix close order OrderSeclec() param error;
 * v0.1.30 [dev] 2012-12-04 adjuse the order display total item when display; remove RUB from default extern "Currencies";
 * v0.1.31 [dev] 2012-12-06 remove extern item Baselots, change to auto calcu use marketinfo(); change order status fpi with diff fpi value;
 * v0.1.32 [dev] 2012-12-06 adjuse the coordinate of display object; change thold calu value from 0.0005 to 0.001; change thold value display color;
 * v0.1.33 [dev] 2012-12-07 fix CloseRing() func select order bug (may be mt4 bug...);
 * v0.1.34 [dev] 2012-12-07 add repairRing() func use to repair problem ring;
 * v0.1.35 [dev] 2012-12-07 add delete limit order in closeRing() func;
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

extern string 	TradeSetting 	= "---------Trade Setting--------";
extern bool 	EnableTrade 	= true;
extern bool 	Superaddition	= false;
extern double 	BaseLots    	= 0.5;
extern int 		MagicNumber 	= 99901;
extern string 	BrokerSetting 	= "---------Broker Setting--------";
extern string 	Currencies		= "EUR|USD|GBP|CAD|AUD|CHF|JPY|NZD|DKK|SEK|NOK|MXN|PLN|CZK|ZAR|SGD|HKD|TRY|LTL|LVL|HUF|HRK|CCK|RON|";
								//"EUR|USD|GBP|CAD|AUD|CHF|JPY|NZD|DKK|SEK|NOK|MXN|PLN|CZK|ZAR|SGD|HKD|TRY|RUB|LTL|LVL|HUF|HRK|CCK|RON|XAU|XAG|"



/* 
 * Global variable
 *
 */

string Ring[200, 4], SymExt;
double FPI[1, 8], RingOrd[1, 10], Thold[1, 2], RingM[1, 4];
int    ringnum;
int    orderTableHeaderX[10]    = {760, 790, 855, 920, 985, 1060, 1130, 1200, 1270, 1330};
int    ROTicket[100, 5]; //-- ringindex， a, b, c, direction
double ROProfit[100, 6]; //-- total, a, b, c, target, ringfpi
double LotsDigit;



/* 
 * System Funcs
 *
 */

//-- init
int init()
{
	if(MarketInfo(Symbol(), MODE_LOTSTEP) < 0.1)
		LotsDigit = 2;
	else if(MarketInfo(Symbol(), MODE_LOTSTEP) < 1)
		LotsDigit = 1;

	if(StringLen(Symbol()) > 6)
		SymExt = StringSubstr(Symbol(),6);

	int i, j;

	//-- get rings
	findAvailableRing(Ring, Currencies, SymExt);

	//-- adjust real array size
	ringnum = ArrayRange(Ring, 0);
	ArrayResize(FPI, ringnum);
	ArrayResize(RingOrd, ringnum);
	ArrayResize(Thold, ringnum);
	ArrayResize(RingM, ringnum);

	//-- initDebugInfo
	initDebugInfo(Ring);
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
	getFPI(FPI);

	updateDubugInfo(FPI);

	updateSettingInfo();

	checkCurrentOrder(MagicNumber, ROTicket, ROProfit);

	updateRingInfo(ROTicket, ROProfit);

	return(0);
}



/*
 * Trade funcs
 *
 */

//-- get FPI indicator
void getFPI(double &_fpi[][])
{
	double _price[4];

	for(int i = 1; i < ringnum; i ++)
	{
		RefreshRates();

		_price[1] = MarketInfo(Ring[i][1], MODE_ASK);
		_price[2] = MarketInfo(Ring[i][2], MODE_BID);
		_price[3] = MarketInfo(Ring[i][3], MODE_BID);
		//-- buy fpi
		_fpi[i][1] = _price[1] / (_price[2] * _price[3]);
		//-- check buy chance
		if(_fpi[i][1] <= _fpi[i][5] && EnableTrade == true && (ringHaveOrder(i) == false || (Superaddition == true && _fpi[i][1] <= RingOrd[i][1] - 0.0005)))
		{
			openRing(0, i, _price, _fpi[i][1], Ring, MagicNumber, BaseLots, LotsDigit);
		}
		//-- buy FPI history
		if(_fpi[i][2]==0 || _fpi[i][1]<_fpi[i][2]) 
			_fpi[i][2] = _fpi[i][1];

		_price[1] = MarketInfo(Ring[i][1], MODE_BID);
		_price[2] = MarketInfo(Ring[i][2], MODE_ASK);
		_price[3] = MarketInfo(Ring[i][3], MODE_ASK);
		//-- sell fpi
		_fpi[i][3] = _price[1] / (_price[2] * _price[3]);
		//-- check sell chance
		if(_fpi[i][6] > 0 && _fpi[i][3] >= _fpi[i][6] && EnableTrade == true && (ringHaveOrder(i) == false || (Superaddition == true && _fpi[i][3] >= RingOrd[i][3] + 0.0005)))
		{
			openRing(1, i, _price, _fpi[i][3], Ring, MagicNumber, BaseLots, LotsDigit);
		}
		//-- sell FPI history
		if(_fpi[i][4]==0 || _fpi[i][3]>_fpi[i][4]) 
			_fpi[i][4] = _fpi[i][3];

		//-- sH-bL
		if(_fpi[i][7]==0 || _fpi[i][4] - _fpi[i][2] > _fpi[i][7])
			_fpi[i][7] = _fpi[i][4] - _fpi[i][2];

		//-- auto set fpi thold
		if(_fpi[i][7] >= 0.001 && _fpi[i][5] == 0 && _fpi[i][6] == 0)
		{
			_fpi[i][5] = _fpi[i][2]; //-- 
			_fpi[i][6] = _fpi[i][4]; //--
		}
	}
}

//-- check ring have order or not by ring index number
bool ringHaveOrder(int _ringindex)
{
	int total = OrdersTotal();
	int ringidx = 0;
	string comm = "";

	if(total == 0)
		return(false);
	else
	{
		for(int i = 0; i < total; i++)
		{
			comm = "";
			if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
			{
				if(OrderMagicNumber() == MagicNumber)
				{
					comm = OrderComment();
					
					ringidx = StrToInteger(StringSubstr(comm, 0, StringFind(comm, "#", 0)));
					if(ringidx == _ringindex)
						return(true);
				}
			}
		}
	}

	return(false);
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
			//-- calculate total profit and diff fpi
			_roprofit[i][4] *= 40;
			_roprofit[i][5] = getCurrFpi(_roticket[i][0], _roticket[i][4], _roprofit[i][5]);

			if(_roprofit[i][0] >= _roprofit[i][4])
				closeRing(_roticket, i);

			//-- check problem ring
			if(_roticket[i][1] == 0 || _roticket[i][2] == 0 || _roticket[i][3] == 0)
			{
				//-- 
				if(_roprofit[i][0] >= 0)
					closeRing(_roticket, i);
				else
					repairRing(_roticket, i);
			}
		}
	}
}

//--
double getCurrFpi(int _ringidx, int _ringdirection, double _openfpi)
{
	double fpi;

	if(_ringdirection==1)
		fpi = _openfpi - FPI[_ringidx][1];
	else if(_ringdirection==0)
		fpi = FPI[_ringidx][3] - _openfpi;

	return(fpi);
}

//-- 
void closeRing(int _roticket[][], int _ringindex)
{
	int n;

	while(n != 3)
	{
		n = 0;
		for(int i = 1; i < 4; i++)
		{
			if(OrderSelect(_roticket[_ringindex][i], SELECT_BY_TICKET, MODE_TRADES) && OrderCloseTime()==0)
			{
				if(OrderType() == OP_BUY)  
					OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3);
				else if(OrderType() == OP_SELL) 
					OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 3);
				else if(OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT) 
					OrderDelete(ticket);
			}
			else
			{
				n++;
			}
		}
	}
}

//--
void repairRing(int _roticket[][], int _ringindex)
{
	double lots, ringfpi, price[4];
	int limit_direction = 2, magicnumber, ringindex, ticketno, ringdirection, symbolindex;
	string commentText, symext, sym[4];

	if(StringLen(Symbol()) > 6)
		symext = StringSubstr(Symbol(),6);

	if(_roticket[_ringindex][1] > 0 && _roticket[_ringindex][2] == 0 && _roticket[_ringindex][3] > 0)
	{
		if(OrderSelect(_roticket[_ringindex][1], SELECT_BY_TICKET, MODE_TRADES))
		{
			sym[1] = OrderSymbol();
			price[1] = OrderOpenPrice();
			lots = OrderLots();
			magicnumber = OrderMagicNumber();

			getInfoByComment(OrderComment(), ringindex, symbolindex, ringdirection, ringfpi);
		}

		if(OrderSelect(_roticket[_ringindex][3], SELECT_BY_TICKET, MODE_TRADES))
		{
			sym[3] = OrderSymbol();
			price[3] = OrderOpenPrice();
			limit_direction += OrderType();
		}

		commentText = "|" + ringdirection + "@" + ringfpi;
		sym[2] = StringSubstr(sym[1], 0, 3) + StringSubstr(sym[3], 0, 3) + symext;
		price[2] = NormalizeDouble(price[1] / ringfpi / price[3], MarketInfo(sym[2], MODE_DIGITS));

		ticketno = OrderSend(sym[2], limit_direction, lots, price[2], 0, 0, 0, ringindex + "#2" + commentText, magicnumber);
	}
	else if(_roticket[_ringindex][1] > 0 && _roticket[_ringindex][2] > 0 && _roticket[_ringindex][3] == 0)
	{
		if(OrderSelect(_roticket[_ringindex][1], SELECT_BY_TICKET, MODE_TRADES))
		{
			sym[1] = OrderSymbol();
			price[1] = OrderOpenPrice();
			lots = OrderLots();
			magicnumber = OrderMagicNumber();

			getInfoByComment(OrderComment(), ringindex, symbolindex, ringdirection, ringfpi);
		}

		if(OrderSelect(_roticket[_ringindex][2], SELECT_BY_TICKET, MODE_TRADES))
		{
			sym[2] = OrderSymbol();
			price[2] = OrderOpenPrice();
			limit_direction += OrderType();
			lots *= price[2];
		}

		commentText = "|" + ringdirection + "@" + ringfpi;
		sym[3] = StringSubstr(sym[2], 3, 3) + StringSubstr(sym[1], 3, 3) + symext;
		price[3] = NormalizeDouble(price[1] / ringfpi / price[2], MarketInfo(sym[3], MODE_DIGITS));
		lots = NormalizeDouble(lots, LotsDigit);
		//Alert(commentText + "|" + sym[3] + "|" + price[3] + "|" + limit_direction + "|" +lots);
		ticketno = OrderSend(sym[3], limit_direction, lots, price[3], 0, 0, 0, ringindex + "#3" + commentText, magicnumber);
	}
	else if(_roticket[_ringindex][1] > 0 && _roticket[_ringindex][2] == 0 && _roticket[_ringindex][3] == 0)
	{
		if(OrderSelect(_roticket[_ringindex][1], SELECT_BY_TICKET, MODE_TRADES))
		{
			if(OrderTakeProfit() == 0 || OrderStopLoss() == 0)
			{
				//OrderModify(OrderTicket(),OrderOpenPrice(), Bid-Point*TrailingStop, OrderTakeProfit(), 0);
			}
		}
	}
}



/* 
 * Debug Funcs
 *
 */

//-- init debug info object on chart
void initDebugInfo(string _ring[][])
{
	ObjectsDeleteAll();

	color bgcolor = C'0x27,0x28,0x22';
	color titlecolor = C'0xd9,0x26,0x59';
	int y, i, j;

	//-- background
	for(int bgnum = 0; bgnum < 16; bgnum++)
	{
		ObjectCreate("bg_"+bgnum, OBJ_LABEL, 0, 0, 0);
		ObjectSetText("bg_"+bgnum, "g", 300, "Webdings", bgcolor);
		ObjectSet("bg_"+bgnum, OBJPROP_BACK, false);
		ObjectSet("bg_"+bgnum, OBJPROP_XDISTANCE, 20 + bgnum % 4 * 400);
		ObjectSet("bg_"+bgnum, OBJPROP_YDISTANCE, 13 + bgnum / 4 * 387);
	}

	//-- left side
	//-- broker price table header
	string priceTableHeaderName[11] = {"", "Id", "SymbolA", "SymbolB", "SymbolC", "lFPI", "lLowest", "sFPI", "sHighest", "lThold", "sThold"};
	int    priceTableHeaderX[11]    = {0, 25, 50, 115, 181, 250, 325, 400, 475, 550, 625};
	y += 15;
	int realringnum = ringnum - 1;
	createTextObj("price_header", 25,	y, ">>>Rings(" + realringnum + ") & Price & FPI", titlecolor);
	y += 15;
	for(i = 1; i < 12; i++)
		createTextObj("price_header_col_" + i, priceTableHeaderX[i], y, priceTableHeaderName[i]);
	//-- broker price table body
	for(i = 1; i < ringnum; i ++)
	{
		y += 15;
		for (j = 1; j < 4; j ++) 
		{
			createTextObj("price_body_row_" + i + "_col_1", 25, y, i, Gray);
			createTextObj("price_body_row_" + i + "_col_2", 50, y, _ring[i,1], White);
			createTextObj("price_body_row_" + i + "_col_3", 115,y, _ring[i,2], White);
			createTextObj("price_body_row_" + i + "_col_4", 181,y, _ring[i,3], White);
		}
		for(j = 5; j < 11; j++)
			createTextObj("price_body_row_" + i + "_col_" + j, priceTableHeaderX[j], y);
	}


	//-- right side
	//-- settings info
	y = 15;
	string settingTableHeaderName[7] = {"", "Trade", "", "Superaddition:", "",  "BaseLots:", ""};
	int    settingTableHeaderX[7]    = {0, 760, 805, 860, 960, 1020, 1090};
	createTextObj("setting_header", 760,	y, ">>>Settings", titlecolor);
	y += 15;
	for(i = 1; i < 7; i++)
		createTextObj("setting_body_row_1_col_" + i, settingTableHeaderX[i], y, settingTableHeaderName[i]);

	//-- orders info
	y += 15 * 2;
	string orderTableHeaderName[10] = {"Id", "OrderA", "OrderB", "OrderC", "ProfitA",  "ProfitB", "ProfitC", "Summary", "Target", "FPI"};
	createTextObj("order_header", 760,	y, ">>>Orders", titlecolor);
	y += 15;
	for(i = 0; i < 10; i++)
		createTextObj("order_header_col_" + i, orderTableHeaderX[i], y, orderTableHeaderName[i]);
}

//--  update new debug info to chart
void updateDubugInfo(double _fpi[][])
{
	int digit = Digits;

	for(int i = 1; i < ringnum; i++)	//-- row 5 to row 10
	{
		for(int j = 5; j < 11; j++)
		{
			if(j==5 || j==7)
				setTextObj("price_body_row_" + i + "_col_" + j, _fpi[i][j-4], DeepSkyBlue);
			else if(j==9 || j==10)
				if(_fpi[i][j-4]==0)
					setTextObj("price_body_row_" + i + "_col_" + j, _fpi[i][j-4]);
				else
					setTextObj("price_body_row_" + i + "_col_" + j, _fpi[i][j-4], C'0xe6,0xdb,0x74');
			else
				setTextObj("price_body_row_" + i + "_col_" + j, _fpi[i][j-4]);
		}
	}
}

//--  update Setting info to chart
void updateSettingInfo()
{
	string settingstatus = "Disable";
	if(EnableTrade==true)
		settingstatus = "Enable";
	setTextObj("setting_body_row_1_col_2", settingstatus);
	
	settingstatus = "Disable";
	if(Superaddition==true)
		settingstatus = "Enable";
	setTextObj("setting_body_row_1_col_4", settingstatus);
	
	setTextObj("setting_body_row_1_col_6", DoubleToStr(BaseLots, LotsDigit));
}

//-- update ring order information to chart
void updateRingInfo(int _roticket[][], double _roprofit[][])
{
	int i, j, y = 75;
	int row = ArrayRange(_roticket, 0);
	double total = 0;

	for(i = 0; i < 20; i ++)
	{
		for(j = 0; j < 10; j ++)
			ObjectDelete("order_body_row_" + i + "_col_" + j);
	}

	for(i = 0; i < row; i ++)
	{
		y += 15;
		createTextObj("order_body_row_" + i + "_col_0", orderTableHeaderX[0],y, _roticket[i][0], Gray);
		createTextObj("order_body_row_" + i + "_col_1", orderTableHeaderX[1],y, _roticket[i][1], White);
		createTextObj("order_body_row_" + i + "_col_2", orderTableHeaderX[2],y, _roticket[i][2], White);
		createTextObj("order_body_row_" + i + "_col_3", orderTableHeaderX[3],y, _roticket[i][3], White);
		createTextObj("order_body_row_" + i + "_col_4", orderTableHeaderX[4],y, DoubleToStr(_roprofit[i][1], 2), White);
		createTextObj("order_body_row_" + i + "_col_5", orderTableHeaderX[5],y, DoubleToStr(_roprofit[i][2], 2), White);
		createTextObj("order_body_row_" + i + "_col_6", orderTableHeaderX[6],y, DoubleToStr(_roprofit[i][3], 2), White);
		createTextObj("order_body_row_" + i + "_col_7", orderTableHeaderX[7],y, DoubleToStr(_roprofit[i][0], 2), DeepSkyBlue);
		createTextObj("order_body_row_" + i + "_col_8", orderTableHeaderX[8],y, DoubleToStr(_roprofit[i][4], 2), Magenta);
		createTextObj("order_body_row_" + i + "_col_9", orderTableHeaderX[9],y, DoubleToStr(_roprofit[i][5], 5), White);

		total += _roprofit[i][0];
	}

	if(row > 0)
	{
		y += 15;
		i++;
		createTextObj("order_body_row_" + i + "_col_0", orderTableHeaderX[0],y, "Total");
		createTextObj("order_body_row_" + i + "_col_7", orderTableHeaderX[7],y, DoubleToStr(total, 2), Crimson);
	}
}