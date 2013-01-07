#property copyright   "Copyright 2013, Nerrsoft.com"
#property link        "http://nerrsoft.com"
#property version     "1.00"
#property description "Nerr Smart Trader"
#property description "Triangular Arbitrage Trading System For MQ5."
#property description "https://github.com/nerr/nst_ta"
#property description " "
#property description "By Leon Zhuang "
#property description "leon@nerrsoft.com"
#property description "Follow me on Twitter @Nerrsoft"

#include <Trade\SymbolInfo.mqh>
CSymbolInfo *s0 = new CSymbolInfo();
CSymbolInfo *s1 = new CSymbolInfo();
CSymbolInfo *s2 = new CSymbolInfo();
CSymbolInfo *ss = new CSymbolInfo();
string  Ring[][3];

int swaptotal = 6;

void OnStart()
{
    R_getRings(Ring);
    int RingNum = ArrayRange(Ring, 0);
    
    int i;
    string discomm;
    double ringswap[2];
    
    for(i = 0; i < RingNum; i++)
    {
        getringswap(i, ringswap);
        //--
        
        if(ringswap[0] > swaptotal || ringswap[1] > swaptotal)
        {
            discomm = discomm + IntegerToString(i) + " => "
                + "[" + Ring[i][0] + "]" + "[" + Ring[i][1] + "]" + "[" + Ring[i][2] + "]";
            if(ringswap[0] > swaptotal)
                discomm = discomm + " <Long>[" + DoubleToString(ringswap[0]) + "]";
            else if(ringswap[1] > swaptotal)
                discomm = discomm + " <Short>[" + DoubleToString(ringswap[1]) + "]";
                
            discomm = discomm + "\n";
        }
    }
    
    Comment(discomm);
}

void getringswap(int _i, double &_rs[])
{
    s0.Name(Ring[_i][0]);
    s1.Name(Ring[_i][1]);
    s2.Name(Ring[_i][2]);
    
    _rs[0]  = s0.SwapLong();
    _rs[0] += s1.SwapShort() / SymbolInfoDouble(Ring[_i][1], SYMBOL_ASK);
    _rs[0] += s2.SwapShort() * SymbolInfoDouble(Ring[_i][1], SYMBOL_ASK) / SymbolInfoDouble(Ring[_i][0], SYMBOL_ASK);
    
    _rs[1]  = s0.SwapShort();
    _rs[1] += s1.SwapLong() / SymbolInfoDouble(Ring[_i][1], SYMBOL_BID);
    _rs[1] += s2.SwapLong() * SymbolInfoDouble(Ring[_i][1], SYMBOL_BID) / SymbolInfoDouble(Ring[_i][0], SYMBOL_BID);
    
    string ms = "";
    ms = StringSubstr(Ring[_i][0], 0, 3);
    
    if(ms=="AUD")
    {
        _rs[0] = _rs[0] * SymbolInfoDouble("AUDUSD", SYMBOL_BID);
        _rs[1] = _rs[1] * SymbolInfoDouble("AUDUSD", SYMBOL_ASK);
    }
    else if(ms=="EUR")
    {
        _rs[0] = _rs[0] * SymbolInfoDouble("EURUSD", SYMBOL_BID);
        _rs[1] = _rs[1] * SymbolInfoDouble("EURUSD", SYMBOL_ASK);
    }
    else if(ms=="GBP")
    {
        _rs[0] = _rs[0] * SymbolInfoDouble("GBPUSD", SYMBOL_BID);
        _rs[1] = _rs[1] * SymbolInfoDouble("GBPUSD", SYMBOL_ASK);
    }
    else if(ms=="NZD")
    {
        _rs[0] = _rs[0] * SymbolInfoDouble("NZDUSD", SYMBOL_BID);
        _rs[1] = _rs[1] * SymbolInfoDouble("NZDUSD", SYMBOL_ASK);
    }
    else if(ms=="CAD")
    {
        _rs[0] = _rs[0] / SymbolInfoDouble("USDCAD", SYMBOL_BID);
        _rs[1] = _rs[1] / SymbolInfoDouble("USDCAD", SYMBOL_ASK);
    }
}


void R_getRings(string &_ring[][3])
{
    string symbols[], symext;
    
    R_getSymbols(symbols);
    
    if(StringLen(symbols[0]) > 6)
        symext = StringSubstr(symbols[0], 6);

    int symbolnum = ArrayRange(symbols, 0);

    int i = 0, j = 0, n = 0, m = 0;
    string iSymA, iSymB, jSymA, jSymB;

    for(i = 0; i < symbolnum; i++)
    {
        iSymA = StringSubstr(symbols[i], 0, 3);
        iSymB = StringSubstr(symbols[i], 3, 3);
        
        for(j = 0; j < symbolnum; j++)
        {
            jSymA = StringSubstr(symbols[j], 0, 3);
            jSymB = StringSubstr(symbols[j], 3, 3);
            
            if(i != j && iSymA == jSymA && iSymB != jSymB)
            {
                if(SymbolInfoDouble(jSymB + iSymB + symext, SYMBOL_ASK) > 0)
                    n++;
            }
        }
    }
    
    ArrayResize(_ring, n);
    
    for(i = 0; i < symbolnum; i++)
    {
        iSymA = StringSubstr(symbols[i], 0, 3);
        iSymB = StringSubstr(symbols[i], 3, 3);
        
        for(j = 0; j < symbolnum; j++)
        {
            jSymA = StringSubstr(symbols[j], 0, 3);
            jSymB = StringSubstr(symbols[j], 3, 3);
            
            if(i != j && iSymA == jSymA && iSymB != jSymB)
            {
                if(SymbolInfoDouble(jSymB + iSymB + symext, SYMBOL_ASK) > 0)
                {
                    _ring[m][0] = symbols[i];
                    _ring[m][1] = symbols[j];
                    _ring[m][2] = jSymB + iSymB + symext;
                    m++;
                }
            }
        }
    }
}

void R_getSymbols(string &_symbols[])
{
    int numOfGoods = SymbolsTotal(false);
    int n = 0, i = 0, j = 0;

    for(i = 0; i < numOfGoods; i++)
    {
        if(SymbolInfoInteger(SymbolName(i, false), SYMBOL_TRADE_CALC_MODE) == 0)
            n++;
    }

    ArrayResize(_symbols, n);

    for(i = 0; i < numOfGoods; i++)
    {
        if(SymbolInfoInteger(SymbolName(i, false), SYMBOL_TRADE_CALC_MODE) == 0)
        {
            _symbols[j] = SymbolName(i, false);
            j++;
        }
    }
}