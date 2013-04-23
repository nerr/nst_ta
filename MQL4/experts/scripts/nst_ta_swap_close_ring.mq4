/* Nerr Smart Trader - Script - close ring
 *
 * By Leon Zhuang
 * Twitter @Nerrsoft
 * leon@nerrsoft.com
 * http://nerrsoft.com
 *
 * 
 */

#property copyright "Copyright ? 2013 Nerrsoft.com"
#property link      "http://nerrsoft.com"

int order[3];
bool status[3];

double lots = 0;
double clots = 0;

bool closeall = false;
bool fixorderc = false;


int start()
{
    order[0] = 4538153;
    order[1] = 4538154;
    order[2] = 4538155;

    status[0] = false;
    status[1] = false;
    status[2] = false;

    clots = lots * getOrderOpenPrice(order[1]);
    if(fixorderc==true)
        clots += getOrderOpenLots(order[2]) - (getOrderOpenLots(order[1]) * getOrderOpenPrice(order[1]));

    closeRing();

    return(0);
}

void closeRing()
{
    bool closestatus = false;

    double profit[3];
    for(int i = 0; i < 3; i ++)
    {
        if(status[i]==false)
            profit[i] = getOrderOpenProfit(order[i]);
        else
            profit[i] = 0;
    }

    for(int i = 0; i < 3; i ++)
    {
        if(profit[i]>0 && status[i]==false)
            closestatus = closeOrderByTicket(order[i]);

        if(closestatus==true)
            status[i] = true;
        else
            closeRing();
    }

    for(int i = 0; i < 3; i ++)
    {
        if(status[i]==false)
            closestatus = closeOrderByTicket(order[i]);

        if(closestatus==true)
            status[i] = true;
        else
            closeRing();
    }
}

bool closeOrderByTicket(int _t)
{
    bool s;

    if(OrderSelect(_t, SELECT_BY_TICKET , MODE_TRADES)==true)
    {
        if (OrderType() == OP_BUY)  
            s = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3);
        if (OrderType() == OP_SELL) 
            s = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 3);
    }

    return s;
}

double getOrderOpenPrice(int _t)
{
    double p = 0;

    if(OrderSelect(_t, SELECT_BY_TICKET , MODE_TRADES)==true)
        p = OrderOpenPrice();

    return(p);
}

double getOrderOpenLots(int _t)
{
    double l = 0;

    if(OrderSelect(_t, SELECT_BY_TICKET , MODE_TRADES)==true)
        l = OrderLots();

    return(l);
}

double getOrderOpenProfit(int _t)
{
    double p = 0;

    if(OrderSelect(_t, SELECT_BY_TICKET , MODE_TRADES)==true)
        p = OrderProfit();

    return(p);
}