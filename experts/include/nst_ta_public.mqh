/* Nerr Smart Trader - Include - Public Functions
 *
 * By Leon Zhuang
 * Twitter @Nerrsoft
 * leon@nerrsoft.com
 * http://nerrsoft.com
 *
 * 
 */
#include <nst_public.mqh>

//-- find available rings
string findAvailableRing(string &_ring[][], string _currencies, string _symExt)
{
	string avasymbols[100][2];
	findAvailableSymbol(avasymbols, _currencies, _symExt);

	int symbolnum = ArrayRange(avasymbols, 0);

	int i, j;
	int n = 1;
	for(i = 0; i < symbolnum; i++)
	{
		for(j = 0; j < symbolnum; j++)
		{
			if(i != j && avasymbols[i][0] == avasymbols[j][0] && avasymbols[i][1] != avasymbols[j][1])
			{
				if(MarketInfo(avasymbols[j][1] + avasymbols[i][1] + _symExt, MODE_ASK) > 0)
				{
					_ring[n][1] = avasymbols[i][0] + avasymbols[i][1] + _symExt;
					_ring[n][2] = avasymbols[j][0] + avasymbols[j][1] + _symExt;
					_ring[n][3] = avasymbols[j][1] + avasymbols[i][1] + _symExt;
					n++;
				}
			}
		}
	}
	ArrayResize(_ring, n);
}

//-- find available symbols
string findAvailableSymbol(string &_symbols[][], string _currencies, string _symExt)
{
	int currencynum = StringLen(_currencies) / 4;
	string currencyarr[100];
	ArrayResize(currencyarr, currencynum);

	int i, j, n;
	//-- make currency array
	for(i = 0; i < currencynum; i++)
		currencyarr[i] = StringSubstr(_currencies, i * 4, 3);
	//-- check available symbol
	for(i = 0; i < currencynum; i++)
	{
		for(j = 0; j < currencynum; j++)
		{
			if(i != j)
			{
				if(MarketInfo(currencyarr[i]+currencyarr[j] + _symExt, MODE_ASK) > 0)
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

//-- open ring _direction = 0(buy)/1(sell)
bool openRing(int _direction, int _index, double _price[], double _fpi, string _ring[][], int _magicnumber, double _baselots, int _lotsdigit)
{
	int ticketno[4];
	int b_c_direction, i, limit_direction;
	
	//-- adjust b c order direction
	if(_direction==0)
		b_c_direction = 1;
	else if(_direction==1)
		b_c_direction = 0;

	//-- make comment string
	string commentText = "|" + _direction + "@" + _fpi;

	//-- calculate last symbol order losts
	double c_lots = NormalizeDouble(_baselots * _price[2], _lotsdigit);


	//-- open order a
	ticketno[1] = OrderSend(_ring[_index][1], _direction, _baselots, _price[1], 0, 0, 0, _index + "#1" + commentText, _magicnumber);
	if(ticketno[1] <= 0)
	{
		if(_direction==0 && MarketInfo(_ring[_index][1], MODE_ASK) < _price[1])
			ticketno[1] = OrderSend(_ring[_index][1], _direction, _baselots, MarketInfo(_ring[_index][1], MODE_ASK), 0, 0, 0, commentText, _magicnumber);
		else if(_direction==1 && MarketInfo(_ring[_index][1], MODE_BID) > _price[1])
			ticketno[1] = OrderSend(_ring[_index][1], _direction, _baselots, MarketInfo(_ring[_index][1], MODE_BID), 0, 0, 0, commentText, _magicnumber);
	}
	if(ticketno[1] > 0)
		outputLog("nst_ta - First order opened. [" + _ring[_index][1] + "]", "Trading info");
	else
	{
		outputLog("nst_ta - First order can not be send. cancel ring. [" + _ring[_index][1] + "][" + errorDescription(GetLastError()) + "]", "Trading error");
		//-- exit openRing func
		return(false);
	}


	//-- open order b
	ticketno[2] = OrderSend(_ring[_index][2], b_c_direction, _baselots, _price[2], 0, 0, 0, _index + "#2" + commentText, _magicnumber);
	if(ticketno[2] <= 0)
	{
		if(b_c_direction==0 && MarketInfo(_ring[_index][2], MODE_ASK) < _price[2])
			ticketno[2] = OrderSend(_ring[_index][2], _direction, _baselots, MarketInfo(_ring[_index][2], MODE_ASK), 0, 0, 0, commentText, _magicnumber);
		else if(b_c_direction==1 && MarketInfo(_ring[_index][2], MODE_BID) > _price[2])
			ticketno[2] = OrderSend(_ring[_index][2], _direction, _baselots, MarketInfo(_ring[_index][2], MODE_BID), 0, 0, 0, commentText, _magicnumber);
	}
	if(ticketno[2] > 0)
		outputLog("nst_ta - Second order opened. [" + _ring[_index][2] + "]", "Trading info");
	else
	{
		outputLog("nst_ta - Second order can not be send. open limit order. [" + _ring[_index][2] + "][" + errorDescription(GetLastError()) + "]", "Trading error");

		limit_direction = b_c_direction + 2;

		ticketno[2] = OrderSend(_ring[_index][2], limit_direction, _baselots, _price[2], 0, 0, 0, _index + "#2" + commentText, _magicnumber);
		if(ticketno[2] > 0)
			outputLog("nst_ta - Second limit order opened. [" + _ring[_index][2] + "]", "Trading info");
		else
			outputLog("nst_ta - Second limit order can not be send. [" + _ring[_index][2] + "][" + errorDescription(GetLastError()) + "]", "Trading error");
	}


	//-- open order c
	ticketno[3] = OrderSend(_ring[_index][3], b_c_direction, c_lots, _price[3], 0, 0, 0, _index + "#3" + commentText, _magicnumber);
	if(ticketno[3] <= 0)
	{
		if(b_c_direction==0 && MarketInfo(_ring[_index][3], MODE_ASK) < _price[3])
			ticketno[3] = OrderSend(_ring[_index][3], _direction, c_lots, MarketInfo(_ring[_index][3], MODE_ASK), 0, 0, 0, commentText, _magicnumber);
		else if(b_c_direction==1 && MarketInfo(_ring[_index][3], MODE_BID) > _price[3])
			ticketno[3] = OrderSend(_ring[_index][3], _direction, c_lots, MarketInfo(_ring[_index][3], MODE_BID), 0, 0, 0, commentText, _magicnumber);
	}
	if(ticketno[3] > 0)
		outputLog("nst_ta - Third order opened. [" + _ring[_index][3] + "]", "Trading info");
	else
	{
		outputLog("nst_ta - Third order can not be send. open limit order. [" + _ring[_index][3] + "][" + errorDescription(GetLastError()) + "]", "Trading error");

		limit_direction = b_c_direction + 2;
		
		ticketno[3] = OrderSend(_ring[_index][3], limit_direction, c_lots, _price[3], 0, 0, 0, _index + "#3" + commentText, _magicnumber);
		if(ticketno[3] > 0)
			outputLog("nst_ta - Third limit order opened. [" + _ring[_index][3] + "]", "Trading info");
		else
			outputLog("nst_ta - Third limit order can not be send. [" + _ring[_index][3] + "][" + errorDescription(GetLastError()) + "]", "Trading error");
	}

	return(true);
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