#property copyright   "Copyright 2013, Nerrsoft.com"
#property link        "http://nerrsoft.com"
#property version     "1.00"
#property description "Nerr Smart Trader"
#property description "Member of Triangular Arbitrage Trading System For MQ5."
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

//-- 
string  Ring[][3];

//-- controler
double  swapmorethan = 9;
bool    enabletrade = true;
bool    checkusedmargin = false;
double  lots = 1.0;
int     magicnumber = 701;
string  comm = "test";

void OnStart()
{
    //-- get avaliable rings
    R_getRings(Ring);
    //-- get rings number
    int RingNum = ArrayRange(Ring, 0);
    
    int i,direction;
    string discomm;
    double ringswap[2], ringmargin, ringmarginlevel, sumusemargin, sumswap;
    swapmorethan *= lots;
    
    for(i = 0; i < RingNum; i++)
    {
        //-- get swap total of a ring
        R_getringswap(i, ringswap);
        //--
        
        if(ringswap[0] > swapmorethan || ringswap[1] > swapmorethan)
        {
            discomm = discomm + (i) + " => "
                + "[" + Ring[i][0] + "]" + "[" + Ring[i][1] + "]" + "[" + Ring[i][2] + "]";
            if(ringswap[0] > swapmorethan)
            {
                ringmargin = R_calcuRingMargin(0, lots, i);
                ringmarginlevel = ringmargin / ringswap[0];
                discomm = discomm + " <Long>[" + DoubleToString(ringswap[0], 2) + "]";
                sumswap += ringswap[0];
                
                direction = 0;
            }
            else if(ringswap[1] > swapmorethan)
            {
                ringmargin = R_calcuRingMargin(1, lots, i);
                ringmarginlevel = ringmargin / ringswap[1];
                discomm = discomm + " <Short>[" + DoubleToString(ringswap[1], 2) + "]";
                
                sumswap += ringswap[1];
                direction = 1;
            }
            sumusemargin += ringmargin;
            
            discomm = discomm + " <UseMargin>[" + DoubleToString(ringmargin, 2) + "]";
            discomm = discomm + " <OneSwapUseMargin>[" + DoubleToString(ringmarginlevel, 2) + "]"; 
            discomm = discomm + "\n";
            
            double price[3];
            
            price[0] = SymbolInfoDouble(Ring[37][0], SYMBOL_ASK);
            price[1] = SymbolInfoDouble(Ring[37][1], SYMBOL_BID);
            price[2] = SymbolInfoDouble(Ring[37][2], SYMBOL_BID);
            
            //-- trade
            if(enabletrade==true)
                O_openRing(direction, i, price, comm, Ring, magicnumber, lots);
        }
    }
    
    discomm = discomm + "-------------------------------\n";
    discomm = discomm + "Open all ring will use margin: " + sumusemargin + "\n";
    discomm = discomm + "Open all ring will get swap: " + sumswap + "\n";
    
    Comment(discomm);
}

double R_calcuRingMargin(int _d, double _l, int _i)
{
    double checkmargin = 0;
    double freemargin = AccountInfoDouble(ACCOUNT_FREEMARGIN);
    double clots = _l * SymbolInfoDouble(Ring[_i][2], O_getSymbolAction(_d + 9));
    
   /*
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
    } */
    
    return(checkmargin);
}


void R_getringswap(int _i, double &_rs[])
{
    s0.Name(Ring[_i][0]);
    s1.Name(Ring[_i][1]);
    s2.Name(Ring[_i][2]);
    
    _rs[0]  = s0.SwapLong();
    _rs[0] += s1.SwapShort() / SymbolInfoDouble(Ring[_i][1], SYMBOL_BID);
    _rs[0] += s2.SwapShort() * SymbolInfoDouble(Ring[_i][1], SYMBOL_BID) / SymbolInfoDouble(Ring[_i][0], SYMBOL_BID);
    
    _rs[1]  = s0.SwapShort();
    _rs[1] += s1.SwapLong() / SymbolInfoDouble(Ring[_i][1], SYMBOL_ASK);
    _rs[1] += s2.SwapLong() * SymbolInfoDouble(Ring[_i][1], SYMBOL_ASK) / SymbolInfoDouble(Ring[_i][0], SYMBOL_ASK);
    
    //-- get main currency
    string mc = "";
    mc = StringSubstr(Ring[_i][0], 0, 3);
    
    if(mc=="AUD")
    {
        _rs[0] = _rs[0] * SymbolInfoDouble("AUDUSD", SYMBOL_BID);
        _rs[1] = _rs[1] * SymbolInfoDouble("AUDUSD", SYMBOL_ASK);
    }
    else if(mc=="EUR")
    {
        _rs[0] = _rs[0] * SymbolInfoDouble("EURUSD", SYMBOL_BID);
        _rs[1] = _rs[1] * SymbolInfoDouble("EURUSD", SYMBOL_ASK);
    }
    else if(mc=="GBP")
    {
        _rs[0] = _rs[0] * SymbolInfoDouble("GBPUSD", SYMBOL_BID);
        _rs[1] = _rs[1] * SymbolInfoDouble("GBPUSD", SYMBOL_ASK);
    }
    else if(mc=="NZD")
    {
        _rs[0] = _rs[0] * SymbolInfoDouble("NZDUSD", SYMBOL_BID);
        _rs[1] = _rs[1] * SymbolInfoDouble("NZDUSD", SYMBOL_ASK);
    }
    else if(mc=="CAD")
    {
        _rs[0] = _rs[0] / SymbolInfoDouble("USDCAD", SYMBOL_BID);
        _rs[1] = _rs[1] / SymbolInfoDouble("USDCAD", SYMBOL_ASK);
    }
}

/*
 * Ring function
 */

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



double calcuSwap(int _d, string _s, double _l) //--
{
    double swap, usdprice;
    string firstcurr = StringSubstr(_s, 0, 3);
    
    
    
    if(firstcurr == "USD")
        usdprice = 1;
    else
    {
        if(SymbolInfoDouble(firstcurr + "USD", SYMBOL_BID) > 0)
        {
            usdprice = SymbolInfoDouble(firstcurr + "USD", O_getSymbolAction(_d + 9));
        }
        else if(SymbolInfoDouble("USD" + firstcurr, SYMBOL_BID) > 0)
        {
            usdprice = 1 / SymbolInfoDouble("USD" + firstcurr, O_getSymbolAction(_d + 9));
        }
        else
            return(0);
    }
    
    if(SymbolInfoDouble(_s, O_getSymbolAction(_d + 9)) > 0)
        swap = SymbolInfoDouble(_s, O_getSymbolAction(_d + 18)) / SymbolInfoDouble(_s, O_getSymbolAction(_d + 9)) * usdprice * _l;
    
    return(swap);
}


bool O_openRing(int _direction, int _index, double &_price[], string _comment, string &_ring[][3], int _magicnumber, double _lots)
{
    int b_c_direction, limit_direction, statuscode[3];
    
    //-- adjust b c order direction
    if(_direction == 0)
        b_c_direction = 1;
    else if(_direction == 1)
        b_c_direction = 0;

    //-- make comment string
    string commentText = "|" + IntegerToString(_direction) + "@" + _comment;

    //-- calculate last symbol order losts
    double c_lots = NormalizeDouble(_lots * _price[1], 2);
    
    //-- check lots of three orders
    if(!O_checkLots(_ring[_index][0], _lots) || !O_checkLots(_ring[_index][1], _lots) || !O_checkLots(_ring[_index][2], c_lots))
    {
      N_outputLog("Lots error. [RingIdx:" + IntegerToString(_index) + "][AB:" + DoubleToString(_lots, 2) + "][C:" + DoubleToString(c_lots, 2), "Trading Error");
      return(false);
    }
    
    //-- open order a
    statuscode[0] = O_openOrder(_ring[_index][0], 0, _direction, _lots, _price[0], _magicnumber, IntegerToString(_index) + "#1" + commentText);
    if(statuscode[0] == 10015)
    {
        if(_direction==0 && SymbolInfoDouble(_ring[_index][0], SYMBOL_ASK) < _price[0])
            statuscode[0] = O_openOrder(_ring[_index][0], 0, _direction, _lots, SymbolInfoDouble(_ring[_index][0], SYMBOL_ASK), _magicnumber, IntegerToString(_index) + "#1" + commentText);
        else if(_direction==1 && SymbolInfoDouble(_ring[_index][0], SYMBOL_BID) > _price[0])
            statuscode[0] = O_openOrder(_ring[_index][0], 0, _direction, _lots, SymbolInfoDouble(_ring[_index][0], SYMBOL_BID), _magicnumber, IntegerToString(_index) + "#1" + commentText);
    }
    if(statuscode[0] == 10009)
        N_outputLog("nst_ta - First order opened. [RingIdx:" + IntegerToString(_index) + "][Symbol:" + _ring[_index][1] + "]", "Trading info");
    else
    {
        N_outputLog("nst_ta - First order can not be send. cancel ring. [RingIdx:" + IntegerToString(_index) + "][Symbol:" + _ring[_index][1] + "][Code:" + IntegerToString(statuscode[0]) + "]", "Trading error");
        return(false);
    }

    //-- open order b
    statuscode[1] = O_openOrder(_ring[_index][1], 0, b_c_direction, _lots, _price[1], _magicnumber, IntegerToString(_index) + "#2" + commentText);
    if(statuscode[1] == 10015)
    {
        if(b_c_direction==0 && SymbolInfoDouble(_ring[_index][1], SYMBOL_ASK) < _price[1])
            statuscode[1] = O_openOrder(_ring[_index][1], 0, b_c_direction, _lots, SymbolInfoDouble(_ring[_index][1], SYMBOL_ASK), _magicnumber, IntegerToString(_index) + "#2" + commentText);
        else if(b_c_direction==1 && SymbolInfoDouble(_ring[_index][1], SYMBOL_BID) > _price[1])
            statuscode[1] = O_openOrder(_ring[_index][1], 0, b_c_direction, _lots, SymbolInfoDouble(_ring[_index][1], SYMBOL_BID), _magicnumber, IntegerToString(_index) + "#2" + commentText);
    }
    if(statuscode[1] == 10009)
        N_outputLog("nst_ta - Second order opened. [RingIdx:" + IntegerToString(_index) + "][Symbol:" + _ring[_index][1] + "]", "Trading info");
    else
    {
        N_outputLog("nst_ta - Second order can not be send. open limit order. [" + _ring[_index][1] + "][Code:" + IntegerToString(statuscode[0]) + "]", "Trading error");

        limit_direction = b_c_direction + 2;

        statuscode[1] = O_openOrder(_ring[_index][1], 1, limit_direction, _lots, _price[1], _magicnumber, IntegerToString(_index) + "#2" + commentText);
        if(statuscode[1] == 10009)
            N_outputLog("nst_ta - Second limit order opened. [RingIdx:" + IntegerToString(_index) + "][Symbol:" + _ring[_index][1] + "]", "Trading info");
        else
            N_outputLog("nst_ta - Second limit order can not be send. [RingIdx:" + IntegerToString(_index) + "][Symbol:" + _ring[_index][1] + "][Code:" + IntegerToString(statuscode[0]) + "]", "Trading error");
    }

    
    //-- open order c
    statuscode[2] = O_openOrder(_ring[_index][2], 0, b_c_direction, c_lots, _price[2], _magicnumber, IntegerToString(_index) + "#3" + commentText);
    if(statuscode[2] == 10015)
    {
        if(b_c_direction==0 && SymbolInfoDouble(_ring[_index][2], SYMBOL_ASK) < _price[2])
            statuscode[2] = O_openOrder(_ring[_index][2], 0, b_c_direction, c_lots, SymbolInfoDouble(_ring[_index][2], SYMBOL_ASK), _magicnumber, IntegerToString(_index) + "#3" + commentText);
        else if(b_c_direction==1 && SymbolInfoDouble(_ring[_index][2], SYMBOL_BID) > _price[2])
            statuscode[2] = O_openOrder(_ring[_index][2], 0, b_c_direction, c_lots, SymbolInfoDouble(_ring[_index][2], SYMBOL_BID), _magicnumber, IntegerToString(_index) + "#3" + commentText);
    }
    if(statuscode[2] == 10009)
        N_outputLog("nst_ta - Third order opened. [RingIdx:" + IntegerToString(_index) + "][Symbol:" + _ring[_index][2] + "]", "Trading info");
    else
    {
        N_outputLog("nst_ta - Third order can not be send. open limit order. [" + _ring[_index][2] + "][Code:" + IntegerToString(statuscode[0]) + "]", "Trading error");

        limit_direction = b_c_direction + 2;

        statuscode[2] = O_openOrder(_ring[_index][2], 1, limit_direction, c_lots, _price[2], _magicnumber, IntegerToString(_index) + "#3" + commentText);
        if(statuscode[2] == 10009)
            N_outputLog("nst_ta - Third limit order opened. [RingIdx:" + IntegerToString(_index) + "][Symbol:" + _ring[_index][2] + "]", "Trading info");
        else
            N_outputLog("nst_ta - Third limit order can not be send. [RingIdx:" + IntegerToString(_index) + "][Symbol:" + _ring[_index][2] + "][Code:" + IntegerToString(statuscode[0]) + "]", "Trading error");
    }

    return(true);
}

int O_openOrder(string _symbol, int _action, int _direction, double _lots, double _price, int _magicnumber, string _comment)
{
   MqlTradeRequest request;
   request.action = O_getAction(_action); 
   request.type   = O_getType(_direction);
   request.magic  = _magicnumber;
   request.symbol = _symbol;
   request.volume = _lots;
   request.price  = _price;
   request.comment= _comment;
   request.sl     = 0;
   request.tp     = 0;
 
   MqlTradeResult result;
   OrderSend(request, result);

   return result.retcode;
}

bool O_checkLots(string _symbol, double _lots)
{
   double min = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN);
   double max = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
   int    setp= (int)(_lots * 100000) % (int)(SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP) * 100000);
   
   if(_lots >= min && _lots <= max && setp == 0)
      return(true);
   else
      return(false);
}

/*
 * Notification Functions
 *
 */
//-- send print
void N_outputLog(string _logtext, string _type="Information")
{
    string text = ">>>" + _type + ":" + _logtext;
    Print(text);
}

//-- send alert
void N_sendAlert(string _text = "null", string _type="Information")
{
    N_outputLog(_text, _type);
    PlaySound("alert.wav");
    Alert(_text);
}

//--
void N_pushInfo(string _text, string _type="Information")
{
    string text = ">>>" + _type + ":" + _text;
    SendNotification(text);
}




/*
 * get enum items
 */

//--
ENUM_TRADE_REQUEST_ACTIONS O_getAction(int _idx)
{
   switch(_idx)
   {
      case(0):return(TRADE_ACTION_DEAL);
      case(1):return(TRADE_ACTION_PENDING);
      case(2):return(TRADE_ACTION_SLTP);
      case(3):return(TRADE_ACTION_MODIFY);
      case(4):return(TRADE_ACTION_REMOVE);
   }
   return(WRONG_VALUE);
}

//-- 
ENUM_ORDER_TYPE O_getType(int _idx)
{
   switch(_idx)
   {
      case(0):return(ORDER_TYPE_BUY);
      case(1):return(ORDER_TYPE_SELL);
      case(2):return(ORDER_TYPE_BUY_LIMIT);
      case(3):return(ORDER_TYPE_SELL_LIMIT);
      case(4):return(ORDER_TYPE_BUY_STOP);
      case(5):return(ORDER_TYPE_SELL_STOP);
      case(6):return(ORDER_TYPE_BUY_STOP_LIMIT);
      case(7):return(ORDER_TYPE_SELL_STOP_LIMIT);
   }
   return(WRONG_VALUE);
}

ENUM_SYMBOL_INFO_DOUBLE O_getSymbolAction(int _idx)
{
   switch(_idx)
   {
      case(9):return(SYMBOL_BID);
      case(10):return(SYMBOL_ASK);
      case(18):return(SYMBOL_SWAP_LONG);
      case(19):return(SYMBOL_SWAP_SHORT);
      
      /*case(0):return(SYMBOL_BID);
      case(1):return(SYMBOL_BIDHIGH);
      case(2):return(SYMBOL_BIDLOW);
      case(3):return(SYMBOL_ASK);
      case(4):return(SYMBOL_ASKHIGH);
      case(5):return(SYMBOL_ASKLOW);
      case(6):return(SYMBOL_LAST);
      case(7):return(SYMBOL_LASTHIGH);
      case(8):return(SYMBOL_LASTLOW);
      case(9):return(SYMBOL_POINT);
      case(10):return(SYMBOL_TRADE_TICK_VALUE);
      case(11):return(SYMBOL_TRADE_TICK_VALUE_PROFIT);
      case(12):return(SYMBOL_TRADE_TICK_VALUE_LOSS);
      case(13):return(SYMBOL_TRADE_TICK_SIZE);
      case(14):return(SYMBOL_TRADE_CONTRACT_SIZE);
      case(15):return(SYMBOL_VOLUME_MIN);
      case(16):return(SYMBOL_VOLUME_MAX);
      case(17):return(SYMBOL_VOLUME_STEP);
      case(18):return(SYMBOL_VOLUME_LIMIT);
      case(19):return(SYMBOL_SWAP_LONG);
      case(20):return(SYMBOL_SWAP_SHORT);
      case(21):return(SYMBOL_MARGIN_INITIAL);
      case(22):return(SYMBOL_MARGIN_MAINTENANCE);
      case(23):return(SYMBOL_MARGIN_LONG);
      case(24):return(SYMBOL_MARGIN_SHORT);
      case(25):return(SYMBOL_MARGIN_LIMIT);
      case(26):return(SYMBOL_MARGIN_STOP);
      case(27):return(SYMBOL_MARGIN_STOPLIMIT);
      case(28):return(SYMBOL_SESSION_VOLUME);
      case(29):return(SYMBOL_SESSION_TURNOVER);
      case(30):return(SYMBOL_SESSION_INTEREST);
      case(31):return(SYMBOL_SESSION_BUY_ORDERS_VOLUME);
      case(32):return(SYMBOL_SESSION_SELL_ORDERS_VOLUME);
      case(33):return(SYMBOL_SESSION_OPEN);
      case(34):return(SYMBOL_SESSION_CLOSE);
      case(35):return(SYMBOL_SESSION_AW);
      case(36):return(SYMBOL_SESSION_PRICE_SETTLEMENT);
      case(37):return(SYMBOL_SESSION_PRICE_LIMIT_MIN);
      case(38):return(SYMBOL_SESSION_PRICE_LIMIT_MAX);*/
   }
   return(WRONG_VALUE);
}