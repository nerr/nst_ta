/* Nerr Smart Trader - Script - close all order
 *
 * By Leon Zhuang
 * Twitter @Nerrsoft
 * leon@nerrsoft.com
 * http://nerrsoft.com
 *
 * 
 */



#property copyright "Copyright ? 2012 Nerrsoft.com"
#property link      "http://nerrsoft.com"



//--
#include <nst_public.mqh>
#include <nst_ta_public.mqh>



//
string 	Ring[200,4], SymExt;
double 	swap[200,7];
double 	BaseLots = 0.5;
int 	LotsDigit = 2;
int 	MagicNumber = 701;
bool 	EnableTrade = false;
double 	t = 10;
string 	c = "EUR|USD|GBP|CAD|AUD|CHF|JPY|NZD|DKK|SEK|NOK|MXN|PLN|CZK|ZAR|SGD|HKD|TRY|RUB|LTL|LVL|HUF|HRK|CCK|";



int start()
{
	if(StringLen(Symbol()) > 6)
		SymExt = StringSubstr(Symbol(),6);

	//----
	int row, col, n, m, i, j, d;
	double _price[4];
	string commstr;
	double swapindi;
	double long_a_s, short_a_s;
	findAvailableRing(Ring, c, SymExt);

	row = ArrayRange(Ring, 0);
	ArrayResize(swap, row);

	for(i = 1; i <= row; i++)
	{
		for(j = 1; j <= 3; j++)
		{
			if(StringLen(Ring[i][j])==6)
			{
				n = j * 2;
				m = n - 1;
				swap[i][m] = MarketInfo(Ring[i][j], MODE_SWAPLONG);
				swap[i][n] = MarketInfo(Ring[i][j], MODE_SWAPSHORT);
			}
		}
	}

	for(i = 1; i < row; i++)
	{
		if(swap[i][1] > 0)
		{
			d = 0;
			_price[1] = MarketInfo(Ring[i][1], MODE_ASK);
			_price[2] = MarketInfo(Ring[i][2], MODE_BID);
			_price[3] = MarketInfo(Ring[i][3], MODE_BID);

			swapindi = swap[i][1] + swap[i][4] + swap[i][6] * _price[2];
		}
		else if(swap[i][2] > 0)
		{
			d = 1;
			_price[1] = MarketInfo(Ring[i][1], MODE_BID);
			_price[2] = MarketInfo(Ring[i][2], MODE_ASK);
			_price[3] = MarketInfo(Ring[i][3], MODE_ASK);

			swapindi = swap[i][2] + swap[i][3] + swap[i][5] * _price[2];
		}

		if(swapindi > t)
		{
			if(EnableTrade==true)
				openRing(d, i, _price, swapindi, Ring, MagicNumber, BaseLots, LotsDigit);

			commstr = commstr + "[" + d + "]" + Ring[i][1] + "_" + Ring[i][2] + "_" + Ring[i][3] + " " + swapindi + "\n";

			commstr = commstr + i + "-> " + Ring[i][1] + "[L]" + swap[i][1] + "[S]" + swap[i][2];
			commstr = commstr + "  " + Ring[i][2] + "[L]" + swap[i][3] + "[S]" + swap[i][4];
			commstr = commstr + "  " + Ring[i][3] + "[L]" + swap[i][5] + "[S]" + swap[i][6];
			commstr = commstr + "\n";
		}
	}
	Comment(commstr);

	return(0);
}