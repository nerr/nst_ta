#property copyright "Copyright ? 2012 Nerrsoft.com"
#property link      "http://nerrsoft.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Gold
#property indicator_level1 0.0

//--- buffers
double sSwap[];
double lSwap[];

//-- extern items
extern string SYMBOL = "";

int init()
{
    if(SYMBOL=="")
        SYMBOL = Symbol();

    IndicatorShortName("Swap Monitor - " + SYMBOL);

    SetIndexStyle(0,DRAW_LINE);
    SetIndexBuffer(0,sSwap);
    SetIndexStyle(1,DRAW_LINE);
    SetIndexBuffer(1,lSwap);
    
    return(0);
}

int start()
{   
    if(isNewBar() == true)
    {
        sSwap[0] = MarketInfo(SYMBOL, MODE_SWAPSHORT);
        lSwap[0] = MarketInfo(SYMBOL, MODE_SWAPLONG);
    }
    return(0);
}

bool isNewBar()
{
    static int t = 0;

    if(t < iTime(0 , 0 , 0))
    {
      t = iTime(0 , 0 , 0); 
      return(true); 
    } 
    else
      return(false);
}