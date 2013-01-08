#property copyright   "Copyright 2013, Nerrsoft.com"
#property link        "http://nerrsoft.com"



//-- include public funcs
#include <nst_ta_public.mqh>


string Ring[200, 4], SymExt;
int swaptotal = 5;
extern string   Currencies      = "EUR|USD|GBP|CAD|AUD|CHF|JPY|NZD|DKK|SEK|NOK|MXN|PLN|CZK|ZAR|SGD|HKD|TRY|LTL|LVL|HRK|CCK|RON|";

void start()
{
    if(StringLen(Symbol()) > 6)
         SymExt = StringSubstr(Symbol(),6);

     //-- get rings
     findAvailableRing(Ring, Currencies, SymExt);
    int RingNum = ArrayRange(Ring, 0);
    
    int i;
    string discomm;
    double ringswap[2];
    
    for(i = 1; i < RingNum; i++)
    {
        getringswap(i, ringswap);
        //--
        
        if(ringswap[0] > swaptotal || ringswap[1] > swaptotal)
        {
            discomm = discomm + (i) + " => "
                + "[" + Ring[i][1] + "]" + "[" + Ring[i][2] + "]" + "[" + Ring[i][3] + "]";
            if(ringswap[0] > swaptotal)
                discomm = discomm + " <Long>[" + (ringswap[0]) + "]";
            else if(ringswap[1] > swaptotal)
                discomm = discomm + " <Short>[" + (ringswap[1]) + "]";
                
            discomm = discomm + "\n";
        }
    }
    
    Comment(discomm);
}


void getringswap(int _i, double &_rs[2])
{
    _rs[0] = calcuSwap(0, Ring[_i][1]) + calcuSwap(1, Ring[_i][2]) + calcuSwap(1, Ring[_i][3]);
    _rs[1] = calcuSwap(1, Ring[_i][1]) + calcuSwap(0, Ring[_i][2]) + calcuSwap(0, Ring[_i][3]);
}



/*
    [param] 
    int _d: 0 - long; 1 - short;
    string _s: symbol;
    double _l: lots;
    
*/
double calcuSwap(int _d, string _s, double _l = 1) //--
{
    double swap, usdprice;
    string firstcurr = StringSubstr(_s, 0, 3);
    
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
    
    return(swap);
}
