/* Nerr Smart Trader - Triangular Arbitrage Trading System - Swap
 *
 * By Leon Zhuang
 * Twitter @Nerrsoft
 * leon@nerrsoft.com
 * http://nerrsoft.com
 *  
 * @History
 * v0.0.0  [dev] 2012-12-11 init.
 *
 * @Todo
 */



#property copyright "Copyright ? 2012 Nerrsoft.com"
#property link      "http://nerrsoft.com"



//-- include mqh file
#include <nst_ta_public.mqh>



/* 
 * define extern
 *
 */

extern string 	TradeSetting 	= "---------Trade Setting--------";
extern bool 	EnableTrade 	= true;
extern double 	BaseLots    	= 1;
extern int 		MagicNumber 	= 701;



/* 
 * Global variable
 *
 */

string 	Ring[2, 3];
string 	db_name 		= "D:\\Documents\\alpariukswaptest.db";
string 	db_ordertable	= "dayinfo";
string 	db_accounttable	= "accountinfo";

/* 
 * System Funcs
 *
 */

//-- init
int init()
{
	if (!D_checkTableExists(db_name, db_table))
		sendAlert("db is not exists.", "Error");

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
	return(0);
}

//-- start
int start()
{
	if(Hour()==0 && Minute==0 && Seconds()==0)
		D_logOrderInfo();

	return(0);
}







/*
 *
 * functions about db
 *
 */
void D_logOrderInfo()
{
	string query;
	string currtime = TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS);
	string currdate = TimeToStr(TimeLocal(),TIME_DATE);

	query = "SELECT datetime FROM " + db_table + " Where datetime LIKE'" + currdate + "%' LIMIT 1";
	int cols[1];
    int handle = sqlite_query(db, "select * from test", cols);
    if(cols > 0)
    	return(0);



	int ordertotal = OrdersTotal();
	query = "INSERT INTO " + db_table + " (datetime,ticket,symbol,type,size,openprice,closeprice,commission,profit,swap) ";
	for(int i = 0; i < ordertotal; i++)
	{
		if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
		{
			if(OrderMagicNumber() == 99902)
			{
				query = StringConcatenate(
					query,
					"select \"" + currtime + "\", " + OrderTicket() + ", \"" + OrderSymbol() + "\", ",
					OrderType() + ", " + OrderLots() + ", " + OrderOpenPrice() + ", ",
					OrderClosePrice() + ", " + OrderCommission() + ", " + OrderProfit() + ", " + OrderSwap() + " union all "
				);
			}
		}
	}

	query = StringSubstr(query, 0, StringLen(query) - 11);
	
	D_exec(db_name, query);
}

bool D_checkTableExists(string _db, string _table)
{
	int res = sqlite_table_exists (_db, _table);

	if(res < 0) {
		outputLog("Check for table existence failed with code " + res, "Error");
		return(false);
	}

	return(res > 0);
}

void D_exec(string _db, string _exp)
{
	int res = sqlite_exec (_db, _exp);

	if(res != 0)
		outputLog("Expression '" + _exp + "' failed with code " + res, "Error");
}