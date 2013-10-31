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
extern string LogPriceAccountSettings  = "---Log Price & Account Info Settings---";
extern bool   LogPriceData             = true;
extern double FpiTrigger               = 0.9997;
extern bool   PlaySoundWhenTrigger     = true;
extern string LogMarginDataSettings    = "---Log Margin Data Settings---";
extern bool   LogMarginData            = false;
extern string DatabaseSettings         = "---PostgreSQL Database Settings---";
extern string g_db_ip_setting          = "localhost";
extern string g_db_port_setting        = "5432";
extern string g_db_user_setting        = "postgres";
extern string g_db_password_setting    = "911911";
extern string g_db_name_setting        = "nst";


//-- start
int start()
{
    //-- begin script and connect to pgsql
    string res = pmql_connect(g_db_ip_setting, g_db_port_setting, g_db_user_setting, g_db_password_setting, g_db_name_setting);
    if((res != "ok") && (res != "already connected"))
    {
        libDebugOutputLog("DB not connected!", "PGSQL-ERR");
        return (-1);
    }


    //-- get account id
    account = AccountNumber();
    aid = getAccountIdByAccountNum(account);

    getFPI(FPI, Ring);

    avgfpi = FPI[0][2]+FPI[1][2];
    if(avgfpi > 0)
    {
        if((avgfpi/2) >= FpiTrigger)
        {
            if(LogPriceData == true)
                logPriceInfo2Db();

            if(PlaySoundWhenTrigger == true)
                PlaySound("alert2.wav");
        }
    }

    if(LogMarginData == true)
        logSafeMarginTest2Db();

    updateFpiInfo(FPI);
    updateAccountInfo();
    updateSwapInfo(Ring);
    updateOrderInfo(MagicNumber);
    updateLogStatusInfo(aid);

    return(0);
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