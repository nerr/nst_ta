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
 * v0.1.9  [dev] 2012-11-22 add checkUnavailableSymbol() func use to self-adaption current support symbol;
 * 
 * @Todo
 */



#property copyright "Copyright ? 2012 Nerrsoft.com"
#property link      "http://nerrsoft.com"



/* 
 * define extern
 *
 */

extern string 	TradeSetting 	= "---------Trade Setting--------";
extern bool 	EnableTrade 	= true;
extern bool 	Superaddition	= false;
extern double 	BaseLots    	= 0.5;
extern int 		MagicNumber 	= 99901;
extern double 	BuyThold		= 0.9999;
extern double 	SellThold 		= 1.0001;
extern string 	BrokerSetting 	= "---------Broker Setting--------";
extern int 		LotsDigit 		= 2;



/* 
 * Global variable
 *
 */

string Ring[1,4], SymExt;
double FPI[1,5], RingOrd[1, 3];
int ringnum;



/* 
 * System Funcs
 *
 */

//-- init
int init()
{
	
	int i, j, n;

	//-- Set up rings
	string ring[21, 4];
	ring[ 1,1] = "EURCHF"; ring[ 1,2] = "EURUSD"; ring[ 1,3] = "USDCHF";
	ring[ 2,1] = "EURCHF"; ring[ 2,2] = "EURGBP"; ring[ 2,3] = "GBPCHF";
	ring[ 3,1] = "EURJPY"; ring[ 3,2] = "EURAUD"; ring[ 3,3] = "AUDJPY";
	ring[ 4,1] = "EURJPY"; ring[ 4,2] = "EURCHF"; ring[ 4,3] = "CHFJPY";
	ring[ 5,1] = "EURJPY"; ring[ 5,2] = "EURGBP"; ring[ 5,3] = "GBPJPY";
	ring[ 6,1] = "EURJPY"; ring[ 6,2] = "EURUSD"; ring[ 6,3] = "USDJPY";
	ring[ 7,1] = "EURCAD"; ring[ 7,2] = "EURUSD"; ring[ 7,3] = "USDCAD";
	ring[ 8,1] = "EURUSD"; ring[ 8,2] = "EURAUD"; ring[ 8,3] = "AUDUSD";
	ring[ 9,1] = "EURUSD"; ring[ 9,2] = "EURGBP"; ring[ 9,3] = "GBPUSD";
	ring[10,1] = "GBPJPY"; ring[10,2] = "GBPCHF"; ring[10,3] = "CHFJPY";
	ring[11,1] = "GBPJPY"; ring[11,2] = "GBPUSD"; ring[11,3] = "USDJPY";
	ring[12,1] = "GBPCHF"; ring[12,2] = "GBPUSD"; ring[12,3] = "USDCHF";
	ring[13,1] = "AUDJPY"; ring[13,2] = "AUDUSD"; ring[13,3] = "USDJPY";
	ring[14,1] = "USDJPY"; ring[14,2] = "USDCHF"; ring[14,3] = "CHFJPY";
	ring[15,1] = "EURUSD"; ring[15,2] = "EURNZD"; ring[15,3] = "NZDUSD";
	ring[16,1] = "EURCHF"; ring[16,2] = "EURNZD"; ring[16,3] = "NZDCHF";
	ring[17,1] = "EURSGD"; ring[17,2] = "EURGBP"; ring[17,3] = "GBPSGD";
	ring[18,1] = "NZDCAD"; ring[18,2] = "NZDUSD"; ring[18,3] = "USDCAD";
	ring[19,1] = "EURNZD"; ring[19,2] = "EURGBP"; ring[19,3] = "GBPNZD";
	ring[20,1] = "AUDUSD"; ring[20,2] = "AUDNZD"; ring[20,3] = "NZDUSD";

	checkUnavailableSymbol(ring, Ring, ringnum);

	//-- adjust real array size
	ringnum = ArrayRange(Ring, 0);
	ArrayResize(FPI, ringnum);
	ArrayResize(RingOrd, ringnum);

	//-- Fix Symbol Names for all Brokers
	if(StringLen(Symbol()) > 6)                                               
	{
		SymExt = StringSubstr(Symbol(),6);
		for(i = 1; i < ringnum; i ++)
		{
			for(j = 1; j < 4; j ++) 
				Ring[i,j] = Ring[i,j] + SymExt;
		}
	}

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

	int i = 0;
	while(i<20)
	{
		getFPI(FPI);

		updateDubugInfo(FPI);

		i++;
	}

	updateSettingInfo();

	return(0);
}



/* 
 * Debug Funcs
 *
 */

//-- output log
void outputLog(string _logtext, string _type="Information")
{
	string text = ">>>" + _type + ":" + _logtext;
	Print (text);
}

//-- send alert
void sendAlert(string _text = "null")
{
	outputLog(_text);
	PlaySound("alert.wav");
	Alert(_text);
}

//-- init debug info object on chart
void initDebugInfo(string _ring[][])
{
	color bgcolor = C'0x27,0x28,0x22';
	color titlecolor = C'0xd9,0x26,0x59';
	int y = 0;

	//-- background
	ObjectCreate("background_1", OBJ_LABEL, 0, 0, 0);
	ObjectSetText("background_1", "g", 300, "Webdings", bgcolor);
	ObjectSet("background_1", OBJPROP_BACK, false);
	ObjectSet("background_1", OBJPROP_XDISTANCE, 20);
	ObjectSet("background_1", OBJPROP_YDISTANCE, 13);

	ObjectCreate("background_2", OBJ_LABEL, 0, 0, 0);
	ObjectSetText("background_2", "g", 300, "Webdings", bgcolor);
	ObjectSet("background_2", OBJPROP_BACK, false);
	ObjectSet("background_2", OBJPROP_XDISTANCE, 420);
	ObjectSet("background_2", OBJPROP_YDISTANCE, 13);

	ObjectCreate("background_3", OBJ_LABEL, 0, 0, 0);
	ObjectSetText("background_3", "g", 300, "Webdings", bgcolor);
	ObjectSet("background_3", OBJPROP_BACK, false);
	ObjectSet("background_3", OBJPROP_XDISTANCE, 20);
	ObjectSet("background_3", OBJPROP_YDISTANCE, 410);

	ObjectCreate("background_4", OBJ_LABEL, 0, 0, 0);
	ObjectSetText("background_4", "g", 300, "Webdings", bgcolor);
	ObjectSet("background_4", OBJPROP_BACK, false);
	ObjectSet("background_4", OBJPROP_XDISTANCE, 420);
	ObjectSet("background_4", OBJPROP_YDISTANCE, 410);

	//-- broker price table header
	y += 15;
	createTextObj("price_header", 25,	y, ">>>Price", titlecolor);
	y += 15;
	createTextObj("price_header_col_1", 25,	y, "Serial");
	createTextObj("price_header_col_2", 75, y, "SymbolA");
	createTextObj("price_header_col_3", 145,y, "SymbolB");
	createTextObj("price_header_col_4", 215,y, "SymbolC");
	createTextObj("price_header_col_5", 285,y, "bFPI");
	createTextObj("price_header_col_6", 375,y, "bLowest");
	createTextObj("price_header_col_7", 465,y, "sFPI");
	createTextObj("price_header_col_8", 555,y, "sHighest");

	//-- broker price table body
	for(int i = 1; i < ringnum; i ++)
	{
		y += 15;
		for (int j = 1; j < 4; j ++) 
		{
			createTextObj("price_body_row_" + i + "_col_1", 25,	y, i, Gray);
			createTextObj("price_body_row_" + i + "_col_2", 75,	y, _ring[i,1], White);
			createTextObj("price_body_row_" + i + "_col_3", 145,y, _ring[i,2], White);
			createTextObj("price_body_row_" + i + "_col_4", 215,y, _ring[i,3], White);
			createTextObj("price_body_row_" + i + "_col_5", 285,y);
			createTextObj("price_body_row_" + i + "_col_6", 375,y);
			createTextObj("price_body_row_" + i + "_col_7", 465,y);
			createTextObj("price_body_row_" + i + "_col_8", 555,y);
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
	createTextObj("setting_body_row_1_col_7", 405,	y, "bThold:");
	createTextObj("setting_body_row_1_col_8", 455,	y);
	createTextObj("setting_body_row_1_col_9", 525,	y, "sThold:");
	createTextObj("setting_body_row_1_col_10",575,	y);

	//-- ring info
	y += 15 * 2;
	createTextObj("ring_header", 25,	y, ">>>Ring", titlecolor);
}

//--  update new debug info to chart
void updateDubugInfo(double _fpi[][])
{
	int digit = Digits;

	for(int i = 1; i < ringnum; i++)	//-- row 5 to row 10
	{
		for(int j = 5; j < 9; j++)
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
	setTextObj("setting_body_row_1_col_8", DoubleToStr(BuyThold, 4));
	setTextObj("setting_body_row_1_col_10",DoubleToStr(SellThold, 4));
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

//-- check unavailable symbol of current broker
void checkUnavailableSymbol(string _ring[][], string &_Ring[][], int _ringnum)
{
	int range = ArrayRange(_ring, 0);
	ArrayResize(_Ring, range);
	_ringnum = 0;

	//-- check unavailable symbol
	for(int i = 1; i < range; i ++)
	{
		for(int j = 1; j < 4; j ++)
		{
			MarketInfo(_ring[i][j], MODE_ASK);
			if(GetLastError() == 4106)
			{
				outputLog("This broker do not support symbol [" + _ring[i][j] + "]", "Information");
				break;
			}
			if(j==3) 
			{
				_ringnum++;
				_Ring[_ringnum][1] = _ring[i][1];
				_Ring[_ringnum][2] = _ring[i][2];
				_Ring[_ringnum][3] = _ring[i][3];
			}
		}
	}

	_ringnum++;
	ArrayResize(_Ring, _ringnum);
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
		if(_fpi[i][1] < BuyThold && EnableTrade == true && (RingOrd[i][0] == 0 || (Superaddition == true && _fpi[i][1] <= RingOrd[i][1] - 0.0005)))
		{
			openRing(0, i, _price, _fpi[i][1]);
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
		if(_fpi[i][3] > SellThold && EnableTrade == true && (RingOrd[i][0] == 0 || (Superaddition == true && _fpi[i][3] >= RingOrd[i][3] + 0.0005)))
		{
			openRing(1, i, _price, _fpi[i][3]);
		}
		//-- sell FPI history
		if(_fpi[i][4]==0 || _fpi[i][3]>_fpi[i][4]) 
			_fpi[i][4] = _fpi[i][3];
	}
}

//-- open ring _direction = 0(buy)/1(sell)
bool openRing(int _direction, int _index, double _price[], double _fpi)
{
	int ticketno[4];
	int b_c_direction, i, limit_direction;
	
	//-- adjust b c order direction
	if(_direction==0)
		b_c_direction = 1;
	else if(_direction==1)
		b_c_direction = 0;

	//-- make comment string
	string commentText = _index + "|" + _direction + "@" + _fpi;

	//-- calculate last symbol order losts
	double c_lots = NormalizeDouble(BaseLots * _price[2], LotsDigit);

	//-- open order a
	ticketno[1] = OrderSend(Ring[_index][1], _direction, BaseLots, _price[1], 0, 0, 0, commentText, MagicNumber);
	if(ticketno[1] <= 0)
	{
		if(_direction==0 && MarketInfo(Ring[_index][1], MODE_ASK) < _price[1])
			ticketno[1] = OrderSend(Ring[_index][1], _direction, BaseLots, MarketInfo(Ring[_index][1], MODE_ASK), 0, 0, 0, commentText, MagicNumber);
		else if(_direction==1 && MarketInfo(Ring[_index][1], MODE_BID) > _price[1])
			ticketno[1] = OrderSend(Ring[_index][1], _direction, BaseLots, MarketInfo(Ring[_index][1], MODE_BID), 0, 0, 0, commentText, MagicNumber);
	}
	if(ticketno[1] > 0)
		outputLog("nst_ta - First order opened. [" + Ring[_index][1] + "]", "Trading info");
	else
	{
		outputLog("nst_ta - First order can not be send. cancel ring. [" + Ring[_index][1] + "][" + GetLastError() + "]", "Trading error");
		//-- exit openRing func
		return(false);
	}

	//-- open order b
	ticketno[2] = OrderSend(Ring[_index][2], b_c_direction, BaseLots, _price[2], 0, 0, 0, commentText, MagicNumber);
	if(ticketno[2] <= 0)
	{
		if(b_c_direction==0 && MarketInfo(Ring[_index][2], MODE_ASK) < _price[2])
			ticketno[2] = OrderSend(Ring[_index][2], _direction, BaseLots, MarketInfo(Ring[_index][2], MODE_ASK), 0, 0, 0, commentText, MagicNumber);
		else if(b_c_direction==1 && MarketInfo(Ring[_index][2], MODE_BID) > _price[2])
			ticketno[2] = OrderSend(Ring[_index][2], _direction, BaseLots, MarketInfo(Ring[_index][2], MODE_BID), 0, 0, 0, commentText, MagicNumber);
	}
	if(ticketno[2] > 0)
		outputLog("nst_ta - Second order opened. [" + Ring[_index][2] + "]", "Trading info");
	else
	{
		outputLog("nst_ta - Second order can not be send. open limit order. [" + Ring[_index][2] + "][" + GetLastError() + "]", "Trading error");

		limit_direction = b_c_direction + 2;

		ticketno[2] = OrderSend(Ring[_index][2], limit_direction, BaseLots, _price[2], 0, 0, 0, commentText, MagicNumber);
		if(ticketno[2] > 0)
			outputLog("nst_ta - Second limit order opened. [" + Ring[_index][2] + "]", "Trading info");
		else
			outputLog("nst_ta - Second limit order can not be send. [" + Ring[_index][2] + "][" + GetLastError() + "]", "Trading error");
	}

	//-- open order c
	ticketno[3] = OrderSend(Ring[_index][3], b_c_direction, c_lots, _price[3], 0, 0, 0, commentText, MagicNumber);
	if(ticketno[3] <= 0)
	{
		if(b_c_direction==0 && MarketInfo(Ring[_index][3], MODE_ASK) < _price[3])
			ticketno[3] = OrderSend(Ring[_index][3], _direction, c_lots, MarketInfo(Ring[_index][3], MODE_ASK), 0, 0, 0, commentText, MagicNumber);
		else if(b_c_direction==1 && MarketInfo(Ring[_index][3], MODE_BID) > _price[3])
			ticketno[3] = OrderSend(Ring[_index][3], _direction, c_lots, MarketInfo(Ring[_index][3], MODE_BID), 0, 0, 0, commentText, MagicNumber);
	}
	if(ticketno[3] > 0)
		outputLog("nst_ta - Third order opened. [" + Ring[_index][3] + "]", "Trading info");
	else
	{
		outputLog("nst_ta - Third order can not be send. open limit order. [" + Ring[_index][3] + "][" + GetLastError() + "]", "Trading error");

		limit_direction = b_c_direction + 2;
		
		ticketno[3] = OrderSend(Ring[_index][3], limit_direction, c_lots, _price[3], 0, 0, 0, commentText, MagicNumber);
		if(ticketno[3] > 0)
			outputLog("nst_ta - Third limit order opened. [" + Ring[_index][3] + "]", "Trading info");
		else
			outputLog("nst_ta - Third limit order can not be send. [" + Ring[_index][3] + "][" + GetLastError() + "]", "Trading error");
	}

	return(true);
}



/*
 * Order management funcs
 *
 */

//-- check current order
void checkCurrentOrder(double &_ringord[][])
{
	double ringfpi;
	int i, j, ringindex, ringdirection;
	int total = OrdersTotal();
	//string 

	if(total == 0)
	{
		for(i = 1; i < ringnum; i++)
		{
			_ringord[i][0] = 0; //-- order number of ring
			_ringord[i][1] = 0; //-- order fpi of ring
		}
	}
	else
	{
		for(i = 0; i <= total; i++)
		{
			if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
			{
				if(OrderMagicNumber() == MagicNumber)
				{
					getInfoByComment(OrderComment(), ringindex, ringdirection, ringfpi);

					_ringord[ringindex][0]++;
					if(_ringord[ringindex][1] < ringfpi)
						_ringord[ringindex][1] = ringfpi;
				}
			}
		}
	}
}

//--
void getInfoByComment(string _commont, int &_index, int &_direction, double &_fpi)
{
	int verticalchart = StringFind(_commont, "|", 0);
	int atchart = StringFind(_commont, "@", verticalchart);

	_fpi = StrToDouble(StringSubstr(_commont, atchart+1, 0));
	_direction = StrToDouble(StringSubstr(_commont, verticalchart+1, 1));
	_index = StrToInteger(StringSubstr(_commont, 0, verticalchart));
}














/*
//-- global vars
int CloseSP = 3;
int aDigits, bDigits, cDigits;
double Price[4];
string OrderCommentString = "NST_TA_";
int TicketNo[4];
double buyFPI, buy_hFPI, buy_lFPI;
double sellFPI, sell_hFPI, sell_lFPI;
double hFPI,lFPI,hProfit,lProfit;
double ringProfit;
int totalSpread;
double realRingFPI;



//-- init
int init()
{
	//----------------------- Set up Rings ----------------------------
	Ring[ 1,1] = "EURCHF"; Ring[ 1,2] = "EURUSD"; Ring[ 1,3] = "USDCHF";
	Ring[ 2,1] = "EURCHF"; Ring[ 2,2] = "EURGBP"; Ring[ 2,3] = "GBPCHF";
	Ring[ 3,1] = "EURJPY"; Ring[ 3,2] = "EURAUD"; Ring[ 3,3] = "AUDJPY";
	Ring[ 4,1] = "EURJPY"; Ring[ 4,2] = "EURCHF"; Ring[ 4,3] = "CHFJPY";
	Ring[ 5,1] = "EURJPY"; Ring[ 5,2] = "EURGBP"; Ring[ 5,3] = "GBPJPY";
	Ring[ 6,1] = "EURJPY"; Ring[ 6,2] = "EURUSD"; Ring[ 6,3] = "USDJPY";
	Ring[ 7,1] = "EURCAD"; Ring[ 7,2] = "EURUSD"; Ring[ 7,3] = "USDCAD";
	Ring[ 8,1] = "EURUSD"; Ring[ 8,2] = "EURAUD"; Ring[ 8,3] = "AUDUSD";
	Ring[ 9,1] = "EURUSD"; Ring[ 9,2] = "EURGBP"; Ring[ 9,3] = "GBPUSD";
	Ring[10,1] = "GBPJPY"; Ring[10,2] = "GBPCHF"; Ring[10,3] = "CHFJPY";
	Ring[11,1] = "GBPJPY"; Ring[11,2] = "GBPUSD"; Ring[11,3] = "USDJPY";
	Ring[12,1] = "GBPCHF"; Ring[12,2] = "GBPUSD"; Ring[12,3] = "USDCHF";
	Ring[13,1] = "AUDJPY"; Ring[13,2] = "AUDUSD"; Ring[13,3] = "USDJPY";
	Ring[14,1] = "USDJPY"; Ring[14,2] = "USDCHF"; Ring[14,3] = "CHFJPY";












	aDigits = MarketInfo(aSymbol, MODE_DIGITS);
	bDigits = MarketInfo(bSymbol, MODE_DIGITS);
	cDigits = MarketInfo(cSymbol, MODE_DIGITS);

	hProfit = 0.0;
	lProfit = 0.0;

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
	getPrice();
	int countO = countOrder();
	double marginLevel;
	if(OrdersTotal()>0)
	  marginLevel = AccountEquity()/AccountMargin();
	else
	  marginLevel = 100;


	if(EnableTrade==true && countO==0 && marginLevel>2)
	{
		TAOpen();
	}else if(countO==3)
	{
		TAClose();
		//Alert(countO);
	}else if(countO<3 && countO>0){
		Alert("Ring Error! ("+aSymbol+"_"+bSymbol+"_"+cSymbol+")");
		PlaySound("alert2.wav");
	}

	watermark();
} */

/* triangularAribitrange()
 *
 * use for check FPI value, control open order and close order
 *
 */
/*void TAOpen()
{
	//-- open order
	if(buyFPI<=bOpenThold && buyFPI>0 && totalSpread<=MaxSpread)
	{
		openRing(0);
		Print("Open signal(BUY):" + aSymbol + bSymbol + cSymbol + "@" + buyFPI);
		PlaySound("0.wav");
	}else if(sellFPI>=sOpenThold && sellFPI>0 && totalSpread<=MaxSpread)
	{
		openRing(1);
		Print("Open signal(SELL):" + aSymbol + bSymbol + cSymbol + "@" + sellFPI);
		PlaySound("0.wav");
	}
}

void TAClose()
{
	if(realRingFPI==0)
	{
		realRingFPI = getRealFPI();
	}

	ringProfit = checkProfit();

	//if(ringProfit>1 && sellFPI>=sOpenThold && sellFPI>0)
	if(ringProfit>8)
	{
		//-- close ring, log text and play sound to notification
		closeRing();
		Print("Close signal(BUY):" + aSymbol + bSymbol + cSymbol + "@" + sellFPI);
		PlaySound("2.wav");

		//-- reset counter
		hProfit = 0.0;
		lProfit = 0.0;
		realRingFPI = 0.0;
	}

	if(ringProfit>hProfit || hProfit==0) hProfit = ringProfit;
	if(ringProfit<lProfit || lProfit==0) lProfit = ringProfit;
}

double getRealFPI()
{
	double fpi, aprice, bprice, cprice;
	for(int i = 0; i < OrdersTotal(); i++)
	{
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
		{
			// todo - no select order
		}
		else
		{
			if(OrderMagicNumber() == MagicNumber)
			{
				if(OrderSymbol()==aSymbol)
				{
					aprice = OrderOpenPrice();
				}else if(OrderSymbol()==bSymbol)
				{
					bprice = OrderOpenPrice();
				}else if(OrderSymbol()==cSymbol)
				{
					cprice = OrderOpenPrice();
				}
			}
		}
	}
	fpi = aprice / (bprice * cprice);
	return(fpi);
} */

/* getPrice()
 *
 * use for get three symbol bid and ask price;
 * calculate synthetic bid and ask;
 * calculate api
 *
 */
/*void getPrice()
{
	RefreshRates();
	//-- FPI
	buyFPI  = MarketInfo(aSymbol, MODE_ASK) / (MarketInfo(bSymbol, MODE_BID) * MarketInfo(cSymbol, MODE_BID));
	sellFPI = MarketInfo(aSymbol, MODE_BID) / (MarketInfo(bSymbol, MODE_ASK) * MarketInfo(cSymbol, MODE_ASK));
	//-- buy FPI history
	if(buy_hFPI==0 || buyFPI>buy_hFPI) buy_hFPI = buyFPI;
	if(buy_lFPI==0 || buyFPI<buy_lFPI) buy_lFPI = buyFPI;
	//-- sell FPI history
	if(sell_hFPI==0 || sellFPI>sell_hFPI) sell_hFPI = sellFPI;
	if(sell_lFPI==0 || sellFPI<sell_lFPI) sell_lFPI = sellFPI;
	//-- spread
	totalSpread = MarketInfo(aSymbol, MODE_SPREAD) + MarketInfo(bSymbol, MODE_SPREAD) + MarketInfo(cSymbol, MODE_SPREAD);
}

//-- 
int countOrder()
{
	int countOrd = 0;
	int total = OrdersTotal();

	// if no order return 0
	if(total==0)
	{
		return(0);
	}
	// if has order count that how many orders that order magic number = MagicNumber
	for(int i = 0; i <= total; i++)
	{
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
		{
			// todo - no select order
		}
		else
		{
			if(OrderMagicNumber() == MagicNumber)
			{
				countOrd++;
			}
		}
	}

	return(countOrd);
}

//-- check current ring's profit
double checkProfit()
{
	double ringprofit = 0;
	
	for(int i = 0; i < OrdersTotal(); i++)
	{
		if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
		{
			// todo - no select order
		}
		else
		{
			if(OrderMagicNumber() == MagicNumber)
			{
				ringprofit = ringprofit + OrderProfit() + OrderSwap() + OrderCommission();
			}
		}
	}
	
	return(ringprofit);
}



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

*/