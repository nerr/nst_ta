/* Nerr SmartTrader - Triangular Arbitrage
 *
 * By Leon Zhuang
 * Twitter @Nerrsoft
 * leon@nerrsoft.com
 * http://nerrsoft.com
 * 
 * This EA can only work on EURJPY M1 chart
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
 * 
 * @Todo
 * # add money mangment
 * # set ea se file
 */

#property copyright "Copyright ? 2012 Nerrsoft.com"
#property link      "http://nerrsoft.com"

//-- extern var
extern string BasePair 		= "---------Base Pair---------";
extern string aSymbol 		= "EURJPY";
extern string HedgePairs 	= "---------Hedge Pairs---------";
extern string bSymbol 		= "EURUSD";
extern string cSymbol 		= "USDJPY";
extern string ControlTrade  = "---------Control Trade--------";
extern bool   EnableTrade 	= false;
extern double bOpenThold  	= 0.9995;
extern double sOpenThold  	= 1.0007;
extern double BaseLots    	= 1.0;
extern int 	  MaxSpread		= 90;
extern int 	  MagicNumber 	= 999;
extern string MoneyMangment = "---------Money Mangment(not complete)---------";
extern bool   EnableMM 		= false;

//-- global var
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

//-- The information of this EA
string eaName	   = "NerrSmartTrader - TA";
string eaVersion   = "0.0.18 [dev]";
string eaCopyright = "Copyright ? 2012 Nerrsoft.com";

//-- init
int init()
{
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
}

/* triangularAribitrange()
 *
 * use for check FPI value, control open order and close order
 *
 */
void TAOpen()
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
}

/* getPrice()
 *
 * use for get three symbol bid and ask price;
 * calculate synthetic bid and ask;
 * calculate api
 *
 */
void getPrice()
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

//-- 0=buy; 1=sell
bool openRing(int orderType)
{
	bool status = true;
	string commentText = "";
	color openColor;
	int b_c_orderType;
	double a_openPrice,b_openPrice,c_openPrice;
	int ticket_a, ticket_b, ticket_c;

	double c_lot;
	
	if(orderType==0)
	{
		openColor = Blue;
		commentText = OrderCommentString+"B@"+buyFPI;
		b_c_orderType = 1;
		
		RefreshRates();
		c_lot = NormalizeDouble(BaseLots*MarketInfo(bSymbol, MODE_ASK), 2);
		a_openPrice = NormalizeDouble(MarketInfo(aSymbol, MODE_BID), MarketInfo(aSymbol, MODE_DIGITS));
		b_openPrice = NormalizeDouble(MarketInfo(bSymbol, MODE_ASK), MarketInfo(bSymbol, MODE_DIGITS));
		c_openPrice = NormalizeDouble(MarketInfo(cSymbol, MODE_ASK), MarketInfo(cSymbol, MODE_DIGITS));
	}
	else{
		openColor = Red;
		commentText = OrderCommentString+"S@"+sellFPI;
		b_c_orderType = 0;
		
		RefreshRates();
		c_lot = NormalizeDouble(BaseLots*MarketInfo(bSymbol, MODE_BID), 2); 
		a_openPrice = NormalizeDouble(MarketInfo(aSymbol, MODE_ASK), MarketInfo(aSymbol, MODE_DIGITS));
		b_openPrice = NormalizeDouble(MarketInfo(bSymbol, MODE_BID), MarketInfo(bSymbol, MODE_DIGITS));
		c_openPrice = NormalizeDouble(MarketInfo(cSymbol, MODE_BID), MarketInfo(cSymbol, MODE_DIGITS));
	}
	
	while (TRUE)
	{
		TicketNo[3] = OrderSend(cSymbol, b_c_orderType, NormalizeDouble(c_lot,Digits), MarketInfo(cSymbol, MODE_BID), 3, 0, 0, commentText, MagicNumber, 0, openColor);
		Print(aSymbol+"_"+bSymbol+"_"+cSymbol+"===TicketNo[3] : ",TicketNo[3]);
		if (TicketNo[3] > 0) break;
		//Sleep(50);
	}

	while (TRUE)
	{            
		TicketNo[2] = OrderSend(bSymbol, b_c_orderType, NormalizeDouble(BaseLots,Digits), MarketInfo(bSymbol, MODE_BID), 3, 0, 0, commentText, MagicNumber, 0, openColor);
		Print(aSymbol+"_"+bSymbol+"_"+cSymbol+"===TicketNo[2] : ",TicketNo[2]);
		if (TicketNo[2] > 0) break;
		//Sleep(50);
	}

	while (TRUE)
	{
		TicketNo[1] = OrderSend(aSymbol, orderType, NormalizeDouble(BaseLots,Digits), MarketInfo(aSymbol, MODE_ASK), 3, 0, 0, commentText, MagicNumber, 0, openColor);
		Print(aSymbol+"_"+bSymbol+"_"+cSymbol+"===TicketNo[1] : ",TicketNo[1]);
		if (TicketNo[1] > 0) break;
		//Sleep(50);
	}

    //-- todo - check order send status

	return(true);
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


//
void watermark()
{
	string ComSpacer = "";

	ComSpacer = ComSpacer
	+ "\n"
	+ "\n"
	+ "\n  Version " + eaVersion
	+ "\n  " + eaCopyright
	+ "\n  http://nerrsoft.com"
	+ "\n  Follow me on twitter @Nerrsoft"
	+ "\n -----------------------------------------------"
	+ "\n  "   + aSymbol + " - " + bSymbol + " - " + cSymbol
	+ "\n -----------------------------------------------"
	+ "\n  FPI_BUY : "   + buyFPI
	+ "\n  Low2High: "   + DoubleToStr(buy_lFPI, 5) + " - " + DoubleToStr(buy_hFPI, 5)
	+ "\n -----------------------------------------------"
	+ "\n  FPI_SELL: "   + sellFPI
	+ "\n  Low2High: "   + DoubleToStr(sell_lFPI, 5) + " - " + DoubleToStr(sell_hFPI, 5)
	+ "\n -----------------------------------------------"
	+ "\n  All Spread: "   + totalSpread
	+ "\n -----------------------------------------------";

	if(countOrder()==0)
	{
		ComSpacer = ComSpacer
		+ "\n  No Ring."
		+ "\n -----------------------------------------------";
	}
	else
	{
		ComSpacer = ComSpacer
		+ "\n  Ring Being @ "+ realRingFPI
		+ "\n -----------------------------------------------"
		+ "\n  RingProfit"
		+ "\n  Low2High: "+  DoubleToStr(lProfit, 2) + " to " +  DoubleToStr(hProfit, 2)
		+ "\n  Current: "+  DoubleToStr(ringProfit, 2);
	}

	Comment(ComSpacer);

	if (ObjectFind("TITLE") < 0) {
		ObjectCreate("TITLE", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("TITLE", eaName, 9, "Courier New", White);
		ObjectSet("TITLE", OBJPROP_CORNER, 0);
		ObjectSet("TITLE", OBJPROP_BACK, FALSE);
		ObjectSet("TITLE", OBJPROP_XDISTANCE, 9);
		ObjectSet("TITLE", OBJPROP_YDISTANCE, 23);
	}

	if (ObjectFind("BGINFO1") < 0) {
		ObjectCreate("BGINFO1", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("BGINFO1", "g", 110, "Webdings", MediumVioletRed);
		ObjectSet("BGINFO1", OBJPROP_CORNER, 0);
		ObjectSet("BGINFO1", OBJPROP_BACK, TRUE);
		ObjectSet("BGINFO1", OBJPROP_XDISTANCE, 5);
		ObjectSet("BGINFO1", OBJPROP_YDISTANCE, 15);
	}

	if (ObjectFind("BGINFO2") < 0) {
		ObjectCreate("BGINFO2", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("BGINFO2", "g", 110, "Webdings", OliveDrab);
		ObjectSet("BGINFO2", OBJPROP_BACK, TRUE);
		ObjectSet("BGINFO2", OBJPROP_XDISTANCE, 5);
		ObjectSet("BGINFO2", OBJPROP_YDISTANCE, 45);
	}

	if (ObjectFind("BGINFO3") < 0) {
		ObjectCreate("BGINFO3", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("BGINFO3", "g", 110, "Webdings", OliveDrab);
		ObjectSet("BGINFO3", OBJPROP_CORNER, 0);
		ObjectSet("BGINFO3", OBJPROP_BACK, TRUE);
		ObjectSet("BGINFO3", OBJPROP_XDISTANCE, 5);
		ObjectSet("BGINFO3", OBJPROP_YDISTANCE, 150);
	}

	if (ObjectFind("FOOTER") < 0) {
		ObjectCreate("FOOTER", OBJ_LABEL, 0, 0, 0);
		ObjectSetText("FOOTER", eaName + " " + eaVersion + " " +  eaCopyright, 9, "Arial", DeepSkyBlue);
		ObjectSet("FOOTER", OBJPROP_CORNER, 2);
		ObjectSet("FOOTER", OBJPROP_XDISTANCE, 5);
		ObjectSet("FOOTER", OBJPROP_YDISTANCE, 10);
	}
}