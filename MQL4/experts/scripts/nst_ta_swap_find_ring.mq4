#property copyright   "Copyright 2013, Nerrsoft.com"
#property link        "http://nerrsoft.com"



//-- include public funcs
#include <nst_ta_public.mqh>
string Ring[200, 4], SymExt;
extern string   Currencies = "EUR|USD|GBP|CAD|AUD|CHF|JPY|NZD|DKK|SEK|NOK|MXN|PLN|CZK|ZAR|SGD|HKD|TRY|LTL|LVL|HRK|CCK|RON|";

//-- controler
int     swapmorethan = 0;
bool    enabletrade = false;
bool    checkusedmargin = false;
double  lots = 4;
int     magicnumber = 701;
string  comm = "test";

void start()
{
    if(StringLen(Symbol()) > 6)
         SymExt = StringSubstr(Symbol(),6);

     //-- get rings
     findAvailableRing(Ring, Currencies, SymExt);
    int RingNum = ArrayRange(Ring, 0);
    
    int i,direction;
    string discomm;
    double ringswap[2], ringmargin, ringmarginlevel, sumusemargin, sumswap;
    
    swapmorethan *= lots;
    
    for(i = 1; i < RingNum; i++)
    {
        getringswap(i, ringswap,lots);
        //--
        
        if(ringswap[0] > swapmorethan || ringswap[1] > swapmorethan)
        {
            discomm = discomm + (i) + " => "
                + "[" + Ring[i][1] + "]" + "[" + Ring[i][2] + "]" + "[" + Ring[i][3] + "]";
            if(ringswap[0] > swapmorethan)
            {
                ringmargin = calcuRingMargin(0, lots, i);
                ringmarginlevel = ringmargin / ringswap[0];
                discomm = discomm + " <Long>[" + DoubleToStr(ringswap[0], 2) + "]";
                sumswap += ringswap[0];
                
                direction = 0;
            }
            else if(ringswap[1] > swapmorethan)
            {
                ringmargin = calcuRingMargin(1, lots, i);
                ringmarginlevel = ringmargin / ringswap[1];
                discomm = discomm + " <Short>[" + DoubleToStr(ringswap[1], 2) + "]";
                
                sumswap += ringswap[1];
                direction = 1;
            }
            sumusemargin += ringmargin;
            
            discomm = discomm + " <UseMargin>[" + DoubleToStr(ringmargin, 2) + "]";
            discomm = discomm + " <OneSwapUseMargin>[" + DoubleToStr(ringmarginlevel, 2) + "]"; 
            discomm = discomm + "\n";
            
            //-- trade
            if(enabletrade==true)
                openRingS(direction, i, comm, Ring, magicnumber, lots, 2);
        }
    }
    
    discomm = discomm + "-------------------------------\n";
    discomm = discomm + "Open all ring will use margin: " + sumusemargin + "\n";
    discomm = discomm + "Open all ring will get swap: " + sumswap + "\n";
    
    Comment(discomm);
}


/*
    open ring
*/
bool openRingS(int _direction, int _index, string _comment, string _ring[][], int _magicnumber, double _baselots, int _lotsdigit)
{
    int ticketno[4];
    int b_c_direction, i, limit_direction;
    
    //-- adjust b c order direction
    if(_direction==0)
        b_c_direction = 1;
    else if(_direction==1)
        b_c_direction = 0;

    //-- make comment string
    string commentText = "|" + _direction + "@" + _comment;
    
    
    double _price[4];
    if(_direction==0)
    {
       _price[1] = MarketInfo(Ring[_index][1], MODE_ASK);
       _price[2] = MarketInfo(Ring[_index][2], MODE_BID);
       _price[3] = MarketInfo(Ring[_index][3], MODE_BID);
    }
    else if(_direction==1)
    {
       _price[1] = MarketInfo(Ring[_index][1], MODE_BID);
       _price[2] = MarketInfo(Ring[_index][2], MODE_ASK);
       _price[3] = MarketInfo(Ring[_index][3], MODE_ASK);
    }
    

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

/*
    get total swap
*/
void getringswap(int _i, double &_rs[2], double _l)
{
    _rs[0]  = calcuSwap(0, Ring[_i][1], _l);
    _rs[0] += calcuSwap(1, Ring[_i][2], _l);
    _rs[0] += calcuSwap(1, Ring[_i][3], _l * MarketInfo(Ring[_i][2], MODE_ASK));
    
    _rs[1]  = calcuSwap(1, Ring[_i][1], _l);
    _rs[1] += calcuSwap(0, Ring[_i][2], _l);
    _rs[1] += calcuSwap(0, Ring[_i][3], _l * MarketInfo(Ring[_i][2], MODE_BID));
}

/*
    [param] 
    int _d: 0 - long; 1 - short;
    string _s: symbol;
    double _l: lots;
    
*/
double calcuSwap(int _d, string _s, double _l) //--
{
    double swap, usdprice;
    string firstcurr = StringSubstr(_s, 0, 3);
    string secondcurr = StringSubstr(_s, 3, 3);
    
    if(firstcurr == "USD")
        usdprice = 1;
    else
    {
        if(MarketInfo(firstcurr + "USD", MODE_BID) > 0)
        {
            usdprice = MarketInfo(firstcurr + "USD", _d + 9);
        }
        else if(MarketInfo("USD" + firstcurr, MODE_BID) > 0)
        {
            usdprice = 1 / MarketInfo("USD" + firstcurr, _d + 9);
        }
        else
            return(0);
    }
    
    if(MarketInfo(_s, _d + 9) > 0)
        swap = MarketInfo(_s, _d + 18) / MarketInfo(_s, _d + 9) * usdprice * _l;
        
    if(secondcurr=="JPY" && firstcurr!="MXN")
        swap *= 100;
    
    return(swap);
}

/*

*/
double calcuRingMargin(int _d, double _l, int _i)
{
    double checkmargin = 0;
    double freemargin = AccountFreeMargin();
    double clots = _l * MarketInfo(Ring[_i][2], _d + 9);
    

    checkmargin =  freemargin - AccountFreeMarginCheck(Ring[_i][1], _d, _l);
    if(_d == 0)
    {
       checkmargin += freemargin - AccountFreeMarginCheck(Ring[_i][2], 1, _l);
       checkmargin += freemargin - AccountFreeMarginCheck(Ring[_i][3], 1, clots);
    }
    else
    {
       checkmargin += freemargin - AccountFreeMarginCheck(Ring[_i][2], 0, _l);
       checkmargin += freemargin - AccountFreeMarginCheck(Ring[_i][3], 0, clots);
    }
    
    return(checkmargin);
}
