/*
 * >>>TODO:
 * []calculate lots funcs
 * []open ring chance
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
extern string TradeSetting  = "---------Trade Setting--------";
extern bool   EnableTrade   = true;
extern bool   Superaddition = false;
extern double BaseLots      = 0.5;
extern int    MagicNumber   = 99901;
extern string NotifSetting  = "---------Notification Setting--------";
extern bool   EnableNotifi  = true;



/*
 * Include mqh
 *
 */
#include <Trade\SymbolInfo.mqh>



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
    CSymbolInfo *csymbolinfo = new CSymbolInfo();

    double _price[3];

    for(int i = 0; i < RingNum; i ++)
    {
        if(!csymbolinfo.Name(Ring[i][0]) || !csymbolinfo.Name(Ring[i][1]) || !csymbolinfo.Name(Ring[i][2]))
            continue;
        
        //-- long 
        _price[0] = SymbolInfoDouble(Ring[i][0], SYMBOL_ASK);
        _price[1] = SymbolInfoDouble(Ring[i][1], SYMBOL_BID);
        _price[2] = SymbolInfoDouble(Ring[i][2], SYMBOL_BID);
        //-- buy fpi
        _fpi[i][0] = _price[0] / (_price[1] * _price[2]);
        //-- check buy chance
        /*if(_fpi[i][1] <= _fpi[i][5] && EnableTrade == true && (ringHaveOrder(i) == false || (Superaddition == true && _fpi[i][1] <= RingOrd[i][1] - 0.0005)))
        {
            openRing(0, i, _price, _fpi[i][1], Ring, MagicNumber, BaseLots, LotsDigit);
        }*/
        //-- buy FPI history
        if(_fpi[i][1] == 0 || _fpi[i][0] < _fpi[i][1]) 
            _fpi[i][1] = _fpi[i][0];

        //-- short
        _price[0] = SymbolInfoDouble(Ring[i][0], SYMBOL_BID);
        _price[1] = SymbolInfoDouble(Ring[i][1], SYMBOL_ASK);
        _price[2] = SymbolInfoDouble(Ring[i][2], SYMBOL_ASK);
        //-- sell fpi
        _fpi[i][2] = _price[0] / (_price[1] * _price[2]);
        //-- check sell chance
        /*if(_fpi[i][6] > 0 && _fpi[i][3] >= _fpi[i][6] && EnableTrade == true && (ringHaveOrder(i) == false || (Superaddition == true && _fpi[i][3] >= RingOrd[i][3] + 0.0005)))
        {
            openRing(1, i, _price, _fpi[i][3], Ring, MagicNumber, BaseLots, LotsDigit);
        }*/
        //-- sell FPI history
        if(_fpi[i][3] == 0 || _fpi[i][2] > _fpi[i][3]) 
            _fpi[i][3] = _fpi[i][2];


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