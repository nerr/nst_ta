/* Nerr Smart Trader - Script - close all order
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


int start()
{
  int t = OrdersTotal();
  closeall(t);
  return(0);
}

void closeall(int _t)
{
  for (int i = 0; i < _t; i ++)
  {
    if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
      if (OrderType() == OP_BUY)  OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 3);
      if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 3);
    }
  }
  int t = OrdersTotal();
  if(t > 0)
  {
    closeall(t);
  }
}