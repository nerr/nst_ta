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

extern string 	TradeSetting 	= "---------Trade Setting--------";
extern bool 	EnableTrade 	= true;
extern bool 	Superaddition	= false;
extern double 	BaseLots    	= 0.5;
extern int 		MagicNumber 	= 99901;
extern string 	BrokerSetting 	= "---------Broker Setting--------";
extern int 		LotsDigit 		= 2;
extern string 	Currencies		= "EUR|USD|GBP|CAD|AUD|CHF|JPY|NZD|DKK|SEK|NOK|MXN|PLN|CZK|ZAR|SGD|HKD|TRY|RUB|LTL|LVL|HUF|HRK|CCK|RON|XAU|XAG|";



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
	checkCurrentOrder(RingOrd);

	getFPI(FPI);

	updateDubugInfo(FPI);

	updateRingInfo(RingOrd);

	updateSettingInfo();

	return(0);
}



/* 
 * Debug Funcs
 *
 */

//-- init debug info object on chart
void initDebugInfo(string _ring[][])
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

	//-- broker price table header
	y += 15;
	int realringnum = ringnum - 1;
	createTextObj("price_header", 25,	y, ">>>Ring(" + realringnum + ") & Price & FPI", titlecolor);
	y += 15;
	createTextObj("price_header_col_1", 25, y, "Serial");
	createTextObj("price_header_col_2", 75, y, "SymbolA");
	createTextObj("price_header_col_3", 145,y, "SymbolB");
	createTextObj("price_header_col_4", 215,y, "SymbolC");
	createTextObj("price_header_col_5", 285,y, "bFPI");
	createTextObj("price_header_col_6", 375,y, "bLowest");
	createTextObj("price_header_col_7", 465,y, "sFPI");
	createTextObj("price_header_col_8", 555,y, "sHighest");
	createTextObj("price_header_col_9", 645,y, "bThold");
	createTextObj("price_header_col_10",735,y, "sThold");

	//-- broker price table body
	for(i = 1; i < ringnum; i ++)
	{
		y += 15;
		for (j = 1; j < 4; j ++) 
		{
			createTextObj("price_body_row_" + i + "_col_1", 25, y, i, Gray);
			createTextObj("price_body_row_" + i + "_col_2", 75, y, _ring[i,1], White);
			createTextObj("price_body_row_" + i + "_col_3", 145,y, _ring[i,2], White);
			createTextObj("price_body_row_" + i + "_col_4", 215,y, _ring[i,3], White);
			createTextObj("price_body_row_" + i + "_col_5", 285,y);
			createTextObj("price_body_row_" + i + "_col_6", 375,y);
			createTextObj("price_body_row_" + i + "_col_7", 465,y);
			createTextObj("price_body_row_" + i + "_col_8", 555,y);
			createTextObj("price_body_row_" + i + "_col_9", 645,y);
			createTextObj("price_body_row_" + i + "_col_10",735,y);
		}
	}

	//-- settings info
	y += 15 * 2;
	createTextObj("setting_header", 25,	y, ">>>Settings", titlecolor);
	y += 15;
	createTextObj("setting_body_row_1_col_1", 25,	y, "Trade:");
	createTextObj("setting_body_row_1_col_2", 70,	y);
	createTextObj("setting_body_row_1_col_3", 125,	y, "Superaddition:");
	createTextObj("setting_body_row_1_col_4", 225,	y);
	createTextObj("setting_body_row_1_col_5", 285,	y, "BaseLots:");
	createTextObj("setting_body_row_1_col_6", 355,	y);

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

//-- create text object
void createTextObj(string objName, int xDistance, int yDistance, string objText="", color fontcolor=GreenYellow, string font="Courier New", int fontsize=9)
{
	if(ObjectFind(objName)<0)
	{
		ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
		ObjectSetText(objName, objText, fontsize, font, fontcolor);
		ObjectSet(objName, OBJPROP_XDISTANCE,	xDistance);
		ObjectSet(objName, OBJPROP_YDISTANCE, 	yDistance);
	}
}

//-- set text object new value
void setTextObj(string objName, string objText="", color fontcolor=White, string font="Courier New", int fontsize=9)
{
	if(ObjectFind(objName)>-1)
	{
		ObjectSetText(objName, objText, fontsize, font, fontcolor);
	}
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
		if(_fpi[i][1] <= _fpi[i][5] && EnableTrade == true && (ringHaveOrder(i, RingOrd) == false || (Superaddition == true && _fpi[i][1] <= RingOrd[i][1] - 0.0005)))
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
		if(_fpi[i][6] > 0 && _fpi[i][3] >= _fpi[i][6] && EnableTrade == true && (ringHaveOrder(i, RingOrd) == false || (Superaddition == true && _fpi[i][3] >= RingOrd[i][3] + 0.0005)))
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
		if(_fpi[i][7] >= 0.0005 && _fpi[i][5] == 0 && _fpi[i][6] == 0)
		{
			_fpi[i][5] = _fpi[i][2]; //-- 
			_fpi[i][6] = _fpi[i][4]; //--
		}
	}
}



/*
 * Order management funcs
 *
 */

//-- check current order
/* array RingOrd format
 * RingOrd[x, ]
 * [0] ring index
 * [1] a order ticket
 * [2] b order ticket
 * [3] c order ticket
 * [4] a order real profit
 * [5] b order real profit
 * [6] c order real profit
 * [7] ring summary profit
 * [8] fpi
 * [9] 
 */
void checkCurrentOrder(double &_ringord[][])
{
	//-- init ring order array
	ArrayResize(_ringord, 0);
	ArrayResize(_ringord, 100);


	double ringfpi;
	int i, j, ringindex, ringdirection, symbolindex, arridx, n;
	int total = OrdersTotal();
	//string 

	if(total == 0)
	{
		ArrayResize(_ringord, 0);
	}
	else
	{
		for(i = 0; i <= total; i++)
		{
			if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
			{
				if(OrderMagicNumber() == MagicNumber)
				{
					
					getInfoByComment(OrderComment(), ringindex, symbolindex, ringdirection, ringfpi);
					

					//--
					arridx = findRingOrdIdx(_ringord, ringindex, ringfpi);
					if(arridx == -1)
					{
						
						_ringord[n][0] = ringindex;
						_ringord[n][8] = ringfpi;
						_ringord[n][symbolindex] = OrderTicket();
						_ringord[n][symbolindex+3] = OrderProfit() + OrderSwap() + OrderCommission();
						n++;
					}
					else
					{
						_ringord[arridx][symbolindex] = OrderTicket();
						_ringord[arridx][symbolindex+3] = OrderProfit() + OrderSwap() + OrderCommission();
					}
				}
			}
		}

		ArrayResize(_ringord, n);
		for(i = 0; i < n; i++)
		{
			_ringord[i][7] = _ringord[i][4] + _ringord[i][5] + _ringord[i][6];
		}
	}
}

//-- check ring order have ring index or not
int findRingOrdIdx(double _ringord[][], int _ringindex, double _fpi)
{
	int size = ArrayRange(_ringord, 0);
	for(int i = 0; i < size; i++)
	{
		if(_ringord[i][0] == _ringindex && _ringord[i][8] == _fpi)
			return(i);
	}
	return(-1);
}

//-- check ring have order or not by ring index number
bool ringHaveOrder(int _ringindex, double _ringord[][])
{
	int numberofring = ArrayRange(_ringord, 0);

	for(int i = 0; i < numberofring; i++)
	{
		if(_ringord[i][0] == _ringindex)
			return(true);
	}

	return(false);
}

//-- get order information by order comment string
void getInfoByComment(string _comment, int &_ringindex, int &_symbolindex, int &_direction, double &_fpi)
{
	int verticalchart = StringFind(_comment, "|", 0);
	int atchart = StringFind(_comment, "@", verticalchart);
	int sharpchart = StringFind(_comment, "#", 0);

	_fpi = StrToDouble(StringSubstr(_comment, atchart+1, 0));
	_direction = StrToDouble(StringSubstr(_comment, verticalchart+1, 1));
	_ringindex = StrToInteger(StringSubstr(_comment, 0, sharpchart));
	_symbolindex = StrToInteger(StringSubstr(_comment, sharpchart+1, 1));
}