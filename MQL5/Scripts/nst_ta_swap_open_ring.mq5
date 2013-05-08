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


string Ring[][3];
double lot = 1;
int mn = 701;
string comm = "test";



void OnStart()
{
    R_getRings(Ring);

    double price[3];
    
    int ringarr[4] = {17,21,24,37};
    
    for(int i = 0; i < ArrayRange(ringarr,0); i++)
    {
        price[0] = SymbolInfoDouble(Ring[37][0], SYMBOL_ASK);
        price[1] = SymbolInfoDouble(Ring[37][1], SYMBOL_BID);
        price[2] = SymbolInfoDouble(Ring[37][2], SYMBOL_BID);
        
        O_openRing(0,ringarr[i],price,comm,Ring,mn,lot);
    }
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