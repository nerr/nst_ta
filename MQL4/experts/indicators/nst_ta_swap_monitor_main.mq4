/* 
 * Nerr Smart Trader - Triangular Arbitrage Trading System -> Swap
 *
 * By Leon Zhuang
 * Twitter @Nerrsoft
 * leon@nerrsoft.com
 * http://nerrsoft.com
 * 
 */

#property copyright "Copyright ? 2013 Nerrsoft.com"
#property link      "http://nerrsoft.com"
#property indicator_chart_window



/* 
 * include library
 *
 */

#include <nst_lib_all.mqh>
#include <postgremql4.mqh>



/* 
 * define input parameter
 *
 */
extern int    MagicNumber              = 701;
extern bool   LogMarginData            = false;
extern string DatabaseSettings         = "---PostgreSQL Database Settings---";
extern string g_db_ip_setting          = "localhost";
extern string g_db_port_setting        = "5432";
extern string g_db_user_setting        = "postgres";
extern string g_db_password_setting    = "911911";
extern string g_db_name_setting        = "nst";



/* 
 * Global variable
 *
 */

string Ring[2, 3], SymExt;
string SymbolArr[5] = {"USDJPY", "USDMXN", "MXNJPY", "EURJPY", "EURMXN"};
double FPI[2, 7];
bool nottradesingal = false;
int RingNum = 2;
int RingSpread[2];
int orderTableX[6] = {25, 100, 200, 300, 400, 500};

//-- insert margin data to db var
double test_swap, test_commission, test_pl;
datetime tm;
int std_t = 0;
int orderLine = 0;



/* 
 * System Funcs
 *
 */

//-- init
int init()
{
    //-- begin script and connect to pgsql
    string res = pmql_connect(g_db_ip_setting, g_db_port_setting, g_db_user_setting, g_db_password_setting, g_db_name_setting);
    if((res != "ok") && (res != "already connected"))
    {
        libDebugOutputLog("DB not connected!", "PGSQL-ERR");
        return (-1);
    }

    Ring[0][0] = "USDJPY"; Ring[0][1] = "USDMXN"; Ring[0][2] = "MXNJPY";
    Ring[1][0] = "EURJPY"; Ring[1][1] = "EURMXN"; Ring[1][2] = "MXNJPY";

    if(StringLen(Symbol()) > 6)
        SymExt = StringSubstr(Symbol(),6);

    //-- initDebugInfo
    initDebugInfo(Ring);

    return(0);
}

//-- deinit
int deinit()
{
    pmql_disconnect();
    return(0);
}

//-- start
int start()
{
    //if(Hour()==0 && Minute()==0 && Seconds()==0){}
        //D_logOrderInfo();
    getFPI(FPI, Ring);
    if(FPI[0][2]+FPI[1][2] > 0)
    {
        if((FPI[0][2]+FPI[1][2])/2 >= 0.99965)
            PlaySound("alert2.wav");
    }

    updateFpiInfo(FPI);
    updateAccountInfo();
    updateSwapInfo(Ring);
    updateOrderInfo(MagicNumber);
    
    if(LogMarginData == true)
        logSafeMarginTest2Db();

    return(0);
}


//-- init debug info object on chart
void initDebugInfo(string _ring[][])
{
    ObjectsDeleteAll();

    color titlecolor = C'0xd9,0x26,0x59';
    int y, i, j;
    int ringnum = ArrayRange(_ring, 0);

    //-- set background
    libVisualCreateTextObj("_background", 15, 15, "g", C'0x27,0x28,0x22', "Webdings", 800);

    //-- set fpi table
    y += 15;
    libVisualCreateTextObj("fpi_header", 25,    y, ">>> Rings(" + ringnum + ") & FPI", titlecolor);
    y += 15;
    string fpiTableHeaderName[12] = {"Id", "SymbolA", "SymbolB", "SymbolC", "lFPI", "lLowest", "sFPI", "sHighest", "lThold", "sThold", "Spread", "MinSpread"};
    int    fpiTableHeaderX[12]    = {25, 50, 115, 181, 250, 325, 400, 475, 550, 625, 700, 775};
    for(i = 0; i < 12; i++)
        libVisualCreateTextObj("fpi_header_col_" + i, fpiTableHeaderX[i], y, fpiTableHeaderName[i]);

    for(i = 0; i < ringnum; i ++)
    {
        y += 15;

        for (j = 0; j < 12; j ++) 
        {
            if(j == 0) 
                libVisualCreateTextObj("fpi_body_row_" + (i) + "_col_" + (j), fpiTableHeaderX[j], y, (i+1), Gray);
            else if(j > 0 & j < 4) 
                libVisualCreateTextObj("fpi_body_row_" + (i) + "_col_" + (j), fpiTableHeaderX[j], y, _ring[i][j-1], White);
            else 
                libVisualCreateTextObj("fpi_body_row_" + (i) + "_col_" + (j), fpiTableHeaderX[j], y);
        }
    }

    //-- set swap table
    y += 15 * 2;
    libVisualCreateTextObj("swap_header", 25, y, ">>> Swap Estimate (1 Lots) [SR/ODS]", titlecolor);
    int swapTableHeaderX[5] = {25, 50, 200, 350, 500};
    int swapTableValueX[7] = {50, 100, 200, 250, 350, 400, 500};
    for(i = 0; i < ringnum; i ++)
    {
        y += 15;
        libVisualCreateTextObj("swap_header_row_" + i + "_col_0", swapTableHeaderX[0], y, (i+1), Gray);
        for(j = 0; j < 3; j++)
            libVisualCreateTextObj("swap_header_row_" + i + "_col_" + (j+1), swapTableHeaderX[j+1], y, _ring[i][j]);
        libVisualCreateTextObj("swap_header_row_" + i + "_col_4", swapTableHeaderX[4], y, "Total");

        y += 15;
        for(j = 0; j < 7; j++)
            libVisualCreateTextObj("swap_value_row_" + i + "_col_" + j, swapTableValueX[j], y, "", White);
    }

    //-- set account table
    y += 15 * 2;
    libVisualCreateTextObj("account_header", 25, y, ">>> Account Info", titlecolor);
    string accountTableName[5] = {"Balance", "Profit/Loss", "Equity", "Used Margin", "Free Margin"};
    int accountTableX[5] = {25, 100, 200, 300, 400};
    y += 15;
    for(i = 0; i < 5; i++)
    {
        libVisualCreateTextObj("account_header_col_" + i, accountTableX[i], y, accountTableName[i]);
        libVisualCreateTextObj("account_value_col_" + i, accountTableX[i], (y + 15), "", White);
    }

    //-- set order table
    y += 15 * 3;
    libVisualCreateTextObj("order_header", 25, y, ">>> Order Summary", titlecolor);
    string orderTableName[6] = {"Symbol", "Size(Lot)", "Profit/Loss", "Commission", "Swap", "Total"};
    
    y += 15;
    for(i = 0; i < 6; i++)
    {
        libVisualCreateTextObj("order_header_col_" + i, orderTableX[i], y, orderTableName[i]);
    }
    orderLine = y;
}

void updateOrderInfo(int _mn)
{
    string prefix = "order_body_row_";
    int j, i, y = orderLine;
    double oinfo[5][5]; //--size; profit; commission; swap; total;
    double sum[5];

    for(i = 0; i < 6; i ++)
    {
        for(j = 0; j < 6; j ++)
        {
            if(ObjectType(prefix + i + "_col_" + j) > 0)
                ObjectDelete(prefix + i + "_col_" + j);

            oinfo[i][j] = 0;
        }

        if(ObjectType("order_summary_col_" + i) > 0)
            ObjectDelete("order_summary_col_" + i);
    }

    int idx;
    for(i = 0; i < OrdersTotal(); i++)
    {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if(OrderMagicNumber() == _mn)
            {
                idx = checkSymbolIdx(OrderSymbol());
                oinfo[idx][4] = 0;

                oinfo[idx][0] += OrderLots();
                oinfo[idx][1] += OrderProfit();
                oinfo[idx][2] += OrderCommission();
                oinfo[idx][3] += OrderSwap();

                oinfo[idx][4] += oinfo[idx][1] + oinfo[idx][2] + oinfo[idx][3];


                test_pl += OrderProfit();
                test_commission += OrderCommission();
                test_swap += OrderSwap();
            }
        }
    }
    
    for(i = 0; i < 6; i ++)
    {
        if(oinfo[i][0] > 0)
        {
            y += 15;
            libVisualCreateTextObj(prefix + i + "_col_0", orderTableX[0], y, SymbolArr[i], White);
            for(j = 1; j < 6; j ++)
            {
                libVisualCreateTextObj(prefix + i + "_col_" + j, orderTableX[j], y, DoubleToStr(oinfo[i][j-1], 2), White);
                sum[j-1] += oinfo[i][j-1];
            }
        }
    }

    if(y > 255)
    {
        y += 15;
        libVisualCreateTextObj("order_summary_col_0", 25, y, "Summary", C'0xd9,0x26,0x59');

        for(i = 0; i < 5; i++)
        {
            if(sum[i] > 0)
                libVisualCreateTextObj("order_summary_col_"+(i+1), orderTableX[i+1],y, DoubleToStr(sum[i], 2), DeepSkyBlue);
            else
                libVisualCreateTextObj("order_summary_col_"+(i+1), orderTableX[i+1],y, DoubleToStr(sum[i], 2), LightSeaGreen);
        }
    }

    ArrayInitialize(sum, 0);
}

int checkSymbolIdx(string _sym)
{
    for(int i = 0; i < 6; i ++)
    {
        if(_sym == SymbolArr[i])
            return(i);
    }
    return(10);
}

void updateSwapInfo(string &_ring[][3])
{
    double sinfo[7];

    for(int i = 0; i < ArrayRange(_ring, 0); i++)
    {
        sinfo[0] = MarketInfo(_ring[i][0], MODE_SWAPLONG);
        sinfo[2] = MarketInfo(_ring[i][1], MODE_SWAPSHORT);
        sinfo[4] = MarketInfo(_ring[i][2], MODE_SWAPSHORT);
        
        sinfo[1] = sinfo[0];
        sinfo[3] = sinfo[2] / MarketInfo(_ring[i][1], MODE_ASK);
        sinfo[5] = sinfo[4] * MarketInfo(_ring[i][1], MODE_ASK) / MarketInfo(_ring[i][0], MODE_ASK);
        if(StringSubstr(_ring[i][0], 0, 3) == "EUR")
        {
            sinfo[1] *= MarketInfo("EURUSD", MODE_BID);
            sinfo[3] *= MarketInfo("EURUSD", MODE_BID);
            sinfo[5] *= MarketInfo("EURUSD", MODE_BID);
        }

        sinfo[6] = sinfo[1] + sinfo[3] + sinfo[5];

        for(int j = 0; j < 7; j++)
        {
            if(j==0 || j==2 || j==4)
                libVisualSetTextObj("swap_value_row_" + i + "_col_" + j, DoubleToStr(sinfo[j], 2), White);
            else
                libVisualSetTextObj("swap_value_row_" + i + "_col_" + j, DoubleToStr(sinfo[j], 2), C'0xe6,0xdb,0x74');
        }
    }
}

void updateAccountInfo()
{
    double ainfo[5];
    ainfo[0] = AccountBalance();
    ainfo[1] = AccountProfit();
    ainfo[2] = AccountEquity();
    ainfo[3] = AccountMargin();
    ainfo[4] = AccountFreeMargin();

    for(int i = 0; i < 5; i++)
        libVisualSetTextObj("account_value_col_" + i, DoubleToStr(ainfo[i], 2), White);
}

void updateFpiInfo(double &_fpi[][7])
{
    int digit = 7;
    string prefix = "fpi_body_row_";
    string row = "", col = "";
    int spread = 0;

    for(int i = 0; i < RingNum; i++)    //-- row 5 to row 10
    {
        row = (i);
        
        spread  = MarketInfo(Ring[i][0], MODE_SPREAD);
        spread += MarketInfo(Ring[i][1], MODE_SPREAD);
        spread += MarketInfo(Ring[i][2], MODE_SPREAD);

        libVisualSetTextObj(prefix + row + "_col_4", DoubleToStr(_fpi[i][0], digit), DeepSkyBlue);
        libVisualSetTextObj(prefix + row + "_col_5", DoubleToStr(_fpi[i][1], digit));
        libVisualSetTextObj(prefix + row + "_col_6", DoubleToStr(_fpi[i][2], digit), DeepSkyBlue);
        libVisualSetTextObj(prefix + row + "_col_7", DoubleToStr(_fpi[i][3], digit));
        libVisualSetTextObj(prefix + row + "_col_10", spread);
        
        if(_fpi[i][4] > 0)
        {
            libVisualSetTextObj(prefix + row + "_col_8", DoubleToStr(_fpi[i][4], digit), C'0xe6,0xdb,0x74');
            libVisualSetTextObj(prefix + row + "_col_9", DoubleToStr(_fpi[i][5], digit), C'0xe6,0xdb,0x74');
        }
        else
        {
            libVisualSetTextObj(prefix + row + "_col_8", DoubleToStr(_fpi[i][4], digit));
            libVisualSetTextObj(prefix + row + "_col_9", DoubleToStr(_fpi[i][5], digit));
        }
        
        if(spread < RingSpread[i] || RingSpread[i] == 0)
            RingSpread[i] = spread;

        if(RingSpread[i] < 300 && nottradesingal == true)
            libDebugSendAlert(Ring[i][1] + " can trade now!");

        
        libVisualSetTextObj(prefix + row + "_col_11", RingSpread[i], C'0xe6,0xdb,0x74');
    }
}

void getFPI(double &_fpi[][7], string &_ring[][3])
{
    double l_price[3];
    double s_price[3];

    for(int i = 0; i < RingNum; i ++)
    {
        for(int x = 0; x < 3; x++)
        {
            if(x == 0)
            {
                l_price[x] = MarketInfo(_ring[i][x], MODE_ASK);
                s_price[x] = MarketInfo(_ring[i][x], MODE_BID);
            }
            else
            {
                l_price[x] = MarketInfo(_ring[i][x], MODE_BID);
                s_price[x] = MarketInfo(_ring[i][x], MODE_ASK);
            }
        }
        
        //-- long
        if(l_price[0] > 0 && l_price[1] > 0 && l_price[2] > 0)
        {
            _fpi[i][0] = l_price[0] / (l_price[1] * l_price[2]);
            //-- buy FPI history
            if(_fpi[i][1] == 0 || _fpi[i][0] < _fpi[i][1]) 
                _fpi[i][1] = _fpi[i][0];
        }
        else
            _fpi[i][0] = 0;

        //-- short
        if(s_price[0] > 0 && s_price[1] > 0 && s_price[2] > 0)
        {
            _fpi[i][2] = s_price[0] / (s_price[1] * s_price[2]);
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
        if(_fpi[i][6] >= 0.002 && _fpi[i][4] == 0 && _fpi[i][5] == 0 && _fpi[i][1] != 0 && _fpi[i][3] != 0)
        {
            _fpi[i][4] = _fpi[i][1]; //-- 
            _fpi[i][5] = _fpi[i][3]; //--
        }
    }
}

//-- log margin data to db
void logSafeMarginTest2Db()
{
    tm = TimeCurrent();
    if(std_t == 0)
        std_t = tm;
    else if((tm - std_t) > 200)
        std_t = tm;
    else if(tm >= std_t)
    {
        std_t += 60;

        string query = "insert into nst_ta_swap_safe_margin_note (logtime, profitloss, commission, accountnum, margin, freemargin, equity, swap, balance) values ('"+libDatetimeTm2str(tm)+"', "+test_pl+", "+test_commission+", "+AccountNumber()+", "+AccountMargin()+", "+AccountFreeMargin()+", "+AccountEquity()+", "+test_swap+", "+AccountBalance()+")";
        string res = pmql_exec(query);
    }

    test_pl = 0;
    test_commission = 0;
    test_swap = 0;
}


/*void logAccountInfo2Db()
{
    
}*/