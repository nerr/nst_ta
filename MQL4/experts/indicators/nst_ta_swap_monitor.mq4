#property copyright "Copyright ? 2012 Nerrsoft.com"
#property link      "http://nerrsoft.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Gold
#property indicator_color3 OrangeRed
#property indicator_color4 MediumBlue
#property indicator_color5 YellowGreen

#include <nst_ta_public.mqh>

//--- swap buffers
double lUSDJPY[];
double sUSDMXN[];
double sMXNJPY[];
double lEURJPY[];
double sEURMXN[];

//-- prev value storage
double prevStorage[5];


int init()
{
    IndicatorShortName("Swap Rate Monitor - 0");
    IndicatorShortName("Swap Rate Monitor - 1");

    SetIndexStyle(0, DRAW_LINE);
    SetIndexBuffer(0, lUSDJPY);
    
    SetIndexStyle(1, DRAW_LINE);
    SetIndexBuffer(1, sUSDMXN);
    
    SetIndexStyle(2, DRAW_LINE);
    SetIndexBuffer(2, sUSDMXN);
    
    SetIndexStyle(3, DRAW_LINE);
    SetIndexBuffer(3, sMXNJPY);
    
    SetIndexStyle(4, DRAW_LINE);
    SetIndexBuffer(4, sEURMXN);
    
    return(0);
}

void start()
{   
    lUSDJPY[0] = MarketInfo("USDJPY", MODE_SWAPLONG);
    sUSDMXN[0] = MarketInfo("USDMXN", MODE_SWAPSHORT);
    sMXNJPY[0] = MarketInfo("MXNJPY", MODE_SWAPSHORT);
    lEURJPY[0] = MarketInfo("EURJPY", MODE_SWAPLONG);
    sEURMXN[0] = MarketInfo("EURMXN", MODE_SWAPSHORT);

    if(prevStorage[0] != lUSDJPY[0] && prevStorage[0] != 0)
        sendn("USDJPY" ,lUSDJPY[0] ,prevStorage[0]);
    if(prevStorage[1] != sUSDMXN[0] && prevStorage[1] != 0)
        sendn("USDMXN" ,sUSDMXN[0] ,prevStorage[1]);
    if(prevStorage[2] != sMXNJPY[0] && prevStorage[2] != 0)
        sendn("MXNJPY" ,sMXNJPY[0] ,prevStorage[2]);
    if(prevStorage[3] != lEURJPY[0] && prevStorage[3] != 0)
        sendn("EURJPY" ,lEURJPY[0] ,prevStorage[3]);
    if(prevStorage[4] != sEURMXN[0] && prevStorage[4] != 0)
        sendn("EURMXN" ,sEURMXN[0] ,prevStorage[4]);
   
    prevStorage[0] = lUSDJPY[0];
    prevStorage[1] = sUSDMXN[0];
    prevStorage[2] = sMXNJPY[0];
    prevStorage[3] = lEURJPY[0];
    prevStorage[4] = sEURMXN[0];
}

void sendn(string _sy, double _cur, double _pre)
{
    sendAlert(_sy + " Short Swap Changed. Current value is " + DoubleToStr(_cur, 2) + " and prev value wass " + DoubleToStr(_pre, 2) + ".", "Notification");
}
