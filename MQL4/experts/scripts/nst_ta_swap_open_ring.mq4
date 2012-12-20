#property copyright "Copyright ? 2012 Nerrsoft.com"
#property link      "http://nerrsoft.com"

//--
#include <nst_ta_public.mqh>

//-- switch
bool   EnableTrade = false;
double BaseLots = 1;
int    RingIdx = 0; //-- 0->USDMXN; 1->EURMXN;
double CommentID = 123;
int    MarginBudget = 10000;

int    MagicNumber = 701;
string Ring[2][4];

//-- begin
void start()
{
	string commstr = "";
	double checkmargin = 0;
	double lots = 0, clots = 0;
	double freemargin = AccountFreeMargin();

	Ring[0][1] = "USDJPY"; Ring[0][2] = "USDMXN"; Ring[0][3] = "MXNJPY";
	Ring[1][1] = "EURJPY"; Ring[1][2] = "EURMXN"; Ring[1][3] = "MXNJPY";

	//-- calcu lots
	while(checkmargin < MarginBudget)
	{
		lots += BaseLots;
		clots = lots * MarketInfo(Ring[RingIdx][2], MODE_BID);

		checkmargin =  freemargin - AccountFreeMarginCheck(Ring[RingIdx][1], 0, lots);
		checkmargin += freemargin - AccountFreeMarginCheck(Ring[RingIdx][2], 1, lots);
		checkmargin += freemargin - AccountFreeMarginCheck(Ring[RingIdx][3], 1, clots);
	}

	while(checkmargin > MarginBudget)
	{
		lots = lots - 0.01;
		clots = lots * MarketInfo(Ring[RingIdx][2], MODE_BID);

		checkmargin =  freemargin - AccountFreeMarginCheck(Ring[RingIdx][1], 0, lots);
		checkmargin += freemargin - AccountFreeMarginCheck(Ring[RingIdx][2], 1, lots);
		checkmargin += freemargin - AccountFreeMarginCheck(Ring[RingIdx][3], 1, clots);
	}

	//-- 
	commstr = "[" + Ring[RingIdx][1] + "]" + "[" + Ring[RingIdx][2] + "]" + "[" + Ring[RingIdx][3] + "]\n"
			+ "MarginBudget: " + MarginBudget + "\n"
			+ "Calculate Margin: " + checkmargin + "\n"
			+ "Calculate Lots: " + lots + "\n"
			+ "Calculate C Lots: " + clots + "\n"
			;
	Comment(commstr);

	//-- open Ring 
	double _price[4];
	_price[1] = MarketInfo(Ring[RingIdx][1], MODE_ASK);
	_price[2] = MarketInfo(Ring[RingIdx][2], MODE_BID);
	_price[3] = MarketInfo(Ring[RingIdx][3], MODE_BID);

	if(EnableTrade == true)
		openRing(0, RingIdx, _price, CommentID, Ring, MagicNumber, lots, 2);
}