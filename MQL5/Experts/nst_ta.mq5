/*
 * >>>TODO:
 *
 */


#property copyright   "Copyright 2012, Nerrsoft.com"
#property link        "http://nerrsoft.com"
#property version     "1.00"
#property icon        "nerrsoft.ico"
#property description "Nerr Smart Trader"
#property description "Triangular Arbitrage Trading System For MQ5."
#property description "https://github.com/nerr/nst_ta"
#property description " "
#property description "By Leon Zhuang "
#property description "leon@nerrsoft.com"
#property description "Follow me on Twitter @Nerrsoft"



/*
 * Extern Items
 *
 */
input string TradeSetting  = "---------Trade Setting--------";
input bool   EnableTrade   = true;
input bool   Superaddition = false;
input double BaseLots      = 0.5;
input int    MagicNumber   = 99901;
input string NotifSetting  = "---------Notification Setting--------";
input bool   EnableNotifi  = true;
input string MySQLSetting  = "---------MySQL Setting--------";   
input bool   LogPriceToDB  = true;
input string DBHost        = "127.0.0.1";
input string DBUser        = "root";
input string DBPass        = "911911";
input string DBName        = "metatrader";
input string DBLogTable    = "nst_ta_log_alpariuk833";
input string DBTholdTable  = "nst_ta_thold_alpariuk833";



/*
 * Include mqh
 *
 */
#include <Trade\SymbolInfo.mqh>
#include <Trade\Trade.mqh>
#include <Database\EAX_MySQL.mqh>



CSymbolInfo *csymbolinfo = new CSymbolInfo();
EAX_MySQL *mysql = new EAX_MySQL();


/*
 * Define Global Varables
 *
 */
string  Ring[][3];
int     RingNum;
double  FPI[][7];
int     orderTableHeaderX[10] = {760, 790, 855, 920, 985, 1060, 1130, 1200, 1270, 1330};



/*
 * MQ5 Functions
 *
 */

int OnInit()
{
    EventSetTimer(1);
    ChartSetSymbolPeriod(0, NULL, PERIOD_M1);
    
    R_getRings(Ring);
    RingNum = ArrayRange(Ring, 0);

    D_init(Ring);

    ArrayResize(FPI, RingNum);
    FPI[0][1] = 0.0;  //-- why init value is not zero?

    //-- about mysql
    mysql.connect(DBHost, DBUser, DBPass, DBName);

    return(0);
}

void OnDeinit(const int reason)
{
    //-- destroy timer
    EventKillTimer();

}

void OnTick()
{
    run();
    
    if(LogPriceToDB == true)
        DB_logFpi2DB(DBLogTable, FPI);
}

void OnTimer()
{
    run();
}

/*
void OnTrade(){}

void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result){}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam){}

void OnBookEvent(const string &symbol){}

double OnTester(){ double ret=0.0; return(ret); }

void OnTesterInit(){}

void OnTesterPass(){}

void OnTesterDeinit(){} */



/*
 * Run
 *
 */
void run()
{
    R_getFPI(FPI, Ring);

    D_updateFpiInfo(FPI);

    D_updateSettingInfo();
}



/*
 * Ring Functions
 *
 */
//--
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

/* FPI[x][0] - long fpi
 * FPI[x][1] - long fpi history
 * FPI[x][2] - short fpi
 * FPI[x][3] - short fpi history
 * FPI[x][4] - long thold
 * FPI[x][5] - short thold
 * FPI[x][6] - sH-bL
 */
void R_getFPI(double &_fpi[][7], string &_ring[][3])
{
    double l_price[3];
    double s_price[3];

    for(int i = 0; i < RingNum; i ++)
    {
        for(int x = 0; x < 3; x++)
        {
            csymbolinfo.Name(Ring[i][x]);
            if(csymbolinfo.RefreshRates())
            {
                if(x == 0)
                {
                    l_price[x] = csymbolinfo.Ask();
                    s_price[x] = csymbolinfo.Bid();
                }
                else
                {
                    l_price[x] = csymbolinfo.Bid();
                    s_price[x] = csymbolinfo.Ask();
                }
            }
            else
            {
                l_price[x] = 0;
                s_price[x] = 0;
            }
        }
        
        //-- long
        if(l_price[0] > 0 && l_price[1] > 0 && l_price[2] > 0)
        {
            _fpi[i][0] = l_price[0] / (l_price[1] * l_price[2]);
            //-- check buy chance
            //if(_fpi[i][0] < _fpi[i][4] && EnableTrade == true && (R_ringHaveOrder(i) == false || (Superaddition == true && _fpi[i][0] <= RingOrd[i][0] - 0.0005)))
            if(_fpi[i][0] < _fpi[i][4] && EnableTrade == true && R_ringHaveOrder(i) == false)
            {
                O_openRing(0, i, l_price, _fpi[i][0], Ring, MagicNumber, BaseLots);
            }
            //-- buy FPI history
            if(_fpi[i][1] == 0 || _fpi[i][0] < _fpi[i][1]) 
                _fpi[i][1] = _fpi[i][0];
        }
        else
            _fpi[i][0] = 0;

        //-- short
        if(s_price[0] > 0 && s_price[1] > 0 && s_price[2] > 0)
        {
            //-- sell fpi
            _fpi[i][2] = s_price[0] / (s_price[1] * s_price[2]);
            //-- check sell chance
            //if(_fpi[i][5] > 0 && _fpi[i][2] >= _fpi[i][5] && EnableTrade == true && (R_ringHaveOrder(i) == false || (Superaddition == true && _fpi[i][2] >= RingOrd[i][2] + 0.0005)))
            if(_fpi[i][5] > 0 && _fpi[i][2] >= _fpi[i][5] && EnableTrade == true && R_ringHaveOrder(i) == false)
            {
                O_openRing(1, i, s_price, _fpi[i][2], Ring, MagicNumber, BaseLots);
            }
            //-- sell FPI history
            if(_fpi[i][3] == 0 || _fpi[i][2] > _fpi[i][3]) 
                _fpi[i][3] = _fpi[i][2];
        }
        else
            _fpi[i][2] = 0;



        //-- sH-bL
        if(_fpi[i][6]==0 || _fpi[i][3] - _fpi[i][1] > _fpi[i][6])
            _fpi[i][6] = _fpi[i][3] - _fpi[i][1];

        //-- auto set fpi thold
        if(_fpi[i][6] >= 0.001 && _fpi[i][4] == 0 && _fpi[i][5] == 0 && _fpi[i][1] != 0 && _fpi[i][3] != 0)
        {
            _fpi[i][4] = _fpi[i][1]; //-- 
            _fpi[i][5] = _fpi[i][3]; //--
        }
    }
}

//-- check ring have order or not by ring index number
bool R_ringHaveOrder(int _ringindex)
{
    int total = OrdersTotal();
    int  ringidx = -1;
    string comm = "";

    if(total == 0)
        return(false);
    else
    {
        for(int i = 0; i < total; i++)
        {
            comm = "";
            if(OrderGetTicket(i))
            {
                if(OrderGetInteger(ORDER_MAGIC) == MagicNumber)
                {
                    comm = OrderGetString(ORDER_COMMENT);
                    ringidx = StringToInteger(StringSubstr(comm, 0, StringFind(comm, "#", 0)));
                    
                    if(ringidx == _ringindex)
                        return(true);
                }
            }
        }
    }

    return(false);
}



/*
 * Order Functions
 *
 */
//-- open ring _direction = 0(buy)/1(sell)
bool O_openRing(int _direction, int _index, double &_price[], double _fpi, string &_ring[][3], int _magicnumber, double _lots)
{
    int b_c_direction, limit_direction, statuscode[3];
    
    //-- adjust b c order direction
    if(_direction == 0)
        b_c_direction = 1;
    else if(_direction == 1)
        b_c_direction = 0;

    //-- make comment string
    string commentText = "|" + IntegerToString(_direction) + "@" + DoubleToString(_fpi, 7);

    //-- calculate last symbol order losts
    double c_lots = NormalizeDouble(_lots * _price[2], 2);
    
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

//--
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

//--
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
 * Display Functions
 *
 */
//-- init display items
void D_init(string &_ring[][3])
{
    //--
    color titlecolor = C'0xd9,0x26,0x59';
    int   ringnum = ArrayRange(_ring, 0);

    //-- delete all objects first
    ObjectsDeleteAll(0);

    //-- set background
    D_setBackground(1200);

    //-- fpi table title
    int y = 20; //-- ydistance
    D_createTextObj("fpi_header", 25, y, ">>>Rings(" + IntegerToString(ringnum) + ") & FPI", titlecolor);
    //-- fpi table header
    y += 15;
    string fpiTableHeaderName[10] = {"Id", "SymbolA", "SymbolB", "SymbolC", "lFPI", "lLowest", "sFPI", "sHighest", "lThold", "sThold"};
    int    fpiTableHeaderX[10]    = {25, 50, 115, 181, 250, 325, 400, 475, 550, 625};
    D_setTableHeader("fpi_header_col_", fpiTableHeaderName, fpiTableHeaderX, y);
    //-- fpi table body
    int i, j;
    for(i = 0; i < ringnum; i ++)
    {
        y += 15;

        for (j = 0; j < 10; j ++) 
        {
            if(j == 0) 
                D_createTextObj("fpi_body_row_" + IntegerToString(i) + "_col_" + IntegerToString(j), fpiTableHeaderX[j], y, IntegerToString(i), Gray);
            else if(j > 0 & j < 4) 
                D_createTextObj("fpi_body_row_" + IntegerToString(i) + "_col_" + IntegerToString(j), fpiTableHeaderX[j], y, _ring[i][j-1], White);
            else 
                D_createTextObj("fpi_body_row_" + IntegerToString(i) + "_col_" + IntegerToString(j), fpiTableHeaderX[j], y);
        }
    }

    //-- setting table title
    y = 20;
    D_createTextObj("setting_header", 760,  y, ">>>Settings", titlecolor);
    //-- setting table
    string settingTableHeaderName[6] = {"Trade:", "", "Superaddition:", "",  "BaseLots:", ""};
    int    settingTableHeaderX[6]    = {760, 805, 860, 960, 1020, 1090};
    y += 15;
    D_setTableHeader("setting_body_row_1_col_", settingTableHeaderName, settingTableHeaderX, y);

    //-- orders info
    y += 15 * 2;
    string orderTableHeaderName[10] = {"Id", "OrderA", "OrderB", "OrderC", "ProfitA",  "ProfitB", "ProfitC", "Summary", "Target", "FPI"};
    D_createTextObj("order_header", 760,  y, ">>>Orders", titlecolor);
    y += 15;
    D_setTableHeader("order_header_col_", orderTableHeaderName, orderTableHeaderX, y);
}

//-- set background
void D_setBackground(int _size = 1000, string _bgname = "background", color _bgcolor = C'0x27,0x28,0x22')
{
    D_createTextObj(_bgname, 15, 15, "g", _bgcolor, "Webdings", _size);
}

//-- set table header
void D_setTableHeader(string _prefix, string &_name[], int &_x[], int _y, color _fontcolor = GreenYellow)
{
    int num = ArrayRange(_name, 0);

    for(int i = 0; i < num; i++)
        D_createTextObj(_prefix + IntegerToString(i), _x[i], _y, _name[i], _fontcolor);
}

//-- create text object
void D_createTextObj(string _name, int _x, int _y, string _text="", color _color = White, string _font = "Courier New", int _fontsize = 9)
{
    if(ObjectFind(0, _name) < 0)
    {
        ObjectCreate    (0, _name, OBJ_LABEL, 0, 0, 0);
        ObjectSetString (0, _name, OBJPROP_TEXT, _text);
        ObjectSetString (0, _name, OBJPROP_FONT, _font);
        ObjectSetInteger(0, _name, OBJPROP_FONTSIZE, _fontsize);
        ObjectSetInteger(0, _name, OBJPROP_XDISTANCE, _x);
        ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, _y);
        ObjectSetInteger(0, _name, OBJPROP_COLOR, _color);
    }
}

//-- set text object new value
void D_setTextObj(string _name, string _text="", color _color = White, string _font = "Courier New", int _fontsize = 9)
{
    if(ObjectFind(0, _name)>-1)
    {
        ObjectSetString (0, _name, OBJPROP_TEXT, _text);
        ObjectSetString (0, _name, OBJPROP_FONT, _font);
        ObjectSetInteger(0, _name, OBJPROP_FONTSIZE, _fontsize);
        ObjectSetInteger(0, _name, OBJPROP_COLOR, _color);
    }
}

//-- 
void D_updateSettingInfo()
{
    string settingstatus = "Disable";
    if(EnableTrade==true)
        settingstatus = "Enable";
    D_setTextObj("setting_body_row_1_col_1", settingstatus);
    
    settingstatus = "Disable";
    if(Superaddition==true)
        settingstatus = "Enable";
    D_setTextObj("setting_body_row_1_col_3", settingstatus);
    
    D_setTextObj("setting_body_row_1_col_5", DoubleToString(BaseLots, 2));
}

//--  update new debug info to chart
void D_updateFpiInfo(double &_fpi[][7])
{
    int digit = 7;
    string prefix = "fpi_body_row_";
    string row = "", col = "";

    for(int i = 0; i < RingNum; i++)    //-- row 5 to row 10
    {
        row = IntegerToString(i);

        D_setTextObj(prefix + row + "_col_4", DoubleToString(_fpi[i][0], digit), DeepSkyBlue);
        D_setTextObj(prefix + row + "_col_5", DoubleToString(_fpi[i][1], digit));
        D_setTextObj(prefix + row + "_col_6", DoubleToString(_fpi[i][2], digit), DeepSkyBlue);
        D_setTextObj(prefix + row + "_col_7", DoubleToString(_fpi[i][3], digit));
        if(_fpi[i][4] > 0)
        {
            D_setTextObj(prefix + row + "_col_8", DoubleToString(_fpi[i][4], digit), C'0xe6,0xdb,0x74');
            D_setTextObj(prefix + row + "_col_9", DoubleToString(_fpi[i][5], digit), C'0xe6,0xdb,0x74');
        }
        else
        {
            D_setTextObj(prefix + row + "_col_8", DoubleToString(_fpi[i][4], digit));
            D_setTextObj(prefix + row + "_col_9", DoubleToString(_fpi[i][5], digit));
        }
    }
}



/*
 * MySQL Functions
 *
 */
void DB_logFpi2DB(string _table, double &_fpi[][7])
{
    string marketdate = TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);

    for(int i = 0; i < RingNum; i++)
    {
        mysql.AddNew(_table);
        mysql.set("ringidx", i);
        mysql.set("lthold", _fpi[i][0]);
        mysql.set("sthold", _fpi[i][2]);
        mysql.set("marketdate", marketdate);
        mysql.write();
    }
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