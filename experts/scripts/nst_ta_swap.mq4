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



//
string 	Ring[200,4];
double 	swap[200,7];
double 	BaseLots = 0.5;
int 	LotsDigit = 2;
int 	MagicNumber = 701;
bool 	EnableTrade = false;
double 	t = 10;



int start()
{
	//----
	int row, col, n, m, i, j, d;
	double _price[4];
	string commstr;
	double swapindi;
	double long_a_s, short_a_s;
	findAvailableRing(Ring);

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
				openRing(d, i, _price);

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

//-- find available symbols
string findAvailableSymbol(string &_symbols[][])
{
	string c = "EUR|USD|GBP|CAD|AUD|CHF|JPY|NZD|DKK|SEK|NOK|MXN|PLN|CZK|ZAR|SGD|HKD|TRY|RUB|LTL|LVL|HUF|HRK|CCK|";
	
	int currencynum = StringLen(c) / 4;
	string currencyarr[100];
	ArrayResize(currencyarr, currencynum);

	int i, j, n;
	//-- make currency array
	for(i = 0; i < currencynum; i++)
		currencyarr[i] = StringSubstr(c, i * 4, 3);
	//-- check available symbol
	for(i = 0; i < currencynum; i++)
	{
		for(j = 0; j < currencynum; j++)
		{
			if(i != j)
			{
				if(MarketInfo(currencyarr[i]+currencyarr[j], MODE_ASK) > 0)
				{
					_symbols[n][0] = currencyarr[i];
					_symbols[n][1] = currencyarr[j];
					n++;
				}
			}
		}
	}
	//-- resize array
	ArrayResize(_symbols, n);
}


//-- find available rings
string findAvailableRing(string &_ring[][])
{
	string avasymbols[100][2];
	findAvailableSymbol(avasymbols);

	int symbolnum = ArrayRange(avasymbols, 0);

	int i, j;
	int n = 1;
	for(i = 0; i < symbolnum; i++)
	{
		for(j = 0; j < symbolnum; j++)
		{
			if(i != j && avasymbols[i][0] == avasymbols[j][0] && avasymbols[i][1] != avasymbols[j][1])
			{
				if(MarketInfo(avasymbols[j][1] + avasymbols[i][1], MODE_ASK) > 0)
				{
					_ring[n][1] = avasymbols[i][0] + avasymbols[i][1];
					_ring[n][2] = avasymbols[j][0] + avasymbols[j][1];
					_ring[n][3] = avasymbols[j][1] + avasymbols[i][1];
					n++;
				}
			}
		}
	}
	ArrayResize(_ring, n);
}


bool openRing(int _direction, int _index, double _price[])
{
	int ticketno[4];
	int b_c_direction, i, limit_direction;
	
	//-- adjust b c order direction
	if(_direction==0)
		b_c_direction = 1;
	else if(_direction==1)
		b_c_direction = 0;

	//-- make comment string
	string commentText = "|test";

	//-- calculate last symbol order losts
	double c_lots = NormalizeDouble(BaseLots * _price[2], LotsDigit);

	//-- open order a
	ticketno[1] = OrderSend(Ring[_index][1], _direction, BaseLots, _price[1], 0, 0, 0, _index + "#1" + commentText, MagicNumber);
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
		outputLog("nst_ta - First order can not be send. cancel ring. [" + Ring[_index][1] + "][" + errorDescription(GetLastError()) + "]", "Trading error");
		//-- exit openRing func
		return(false);
	}

	//-- open order b
	ticketno[2] = OrderSend(Ring[_index][2], b_c_direction, BaseLots, _price[2], 0, 0, 0, _index + "#2" + commentText, MagicNumber);
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
		outputLog("nst_ta - Second order can not be send. open limit order. [" + Ring[_index][2] + "][" + errorDescription(GetLastError()) + "]", "Trading error");

		limit_direction = b_c_direction + 2;

		ticketno[2] = OrderSend(Ring[_index][2], limit_direction, BaseLots, _price[2], 0, 0, 0, _index + "#2" + commentText, MagicNumber);
		if(ticketno[2] > 0)
			outputLog("nst_ta - Second limit order opened. [" + Ring[_index][2] + "]", "Trading info");
		else
			outputLog("nst_ta - Second limit order can not be send. [" + Ring[_index][2] + "][" + errorDescription(GetLastError()) + "]", "Trading error");
	}

	//-- open order c
	ticketno[3] = OrderSend(Ring[_index][3], b_c_direction, c_lots, _price[3], 0, 0, 0, _index + "#3" + commentText, MagicNumber);
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
		outputLog("nst_ta - Third order can not be send. open limit order. [" + Ring[_index][3] + "][" + errorDescription(GetLastError()) + "]", "Trading error");

		limit_direction = b_c_direction + 2;
		
		ticketno[3] = OrderSend(Ring[_index][3], limit_direction, c_lots, _price[3], 0, 0, 0, _index + "#3" + commentText, MagicNumber);
		if(ticketno[3] > 0)
			outputLog("nst_ta - Third limit order opened. [" + Ring[_index][3] + "]", "Trading info");
		else
			outputLog("nst_ta - Third limit order can not be send. [" + Ring[_index][3] + "][" + errorDescription(GetLastError()) + "]", "Trading error");
	}

	return(true);
}