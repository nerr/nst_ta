/* Nerr Smart Trader - Include - Public Functions
 *
 * By Leon Zhuang
 * Twitter @Nerrsoft
 * leon@nerrsoft.com
 * http://nerrsoft.com
 *
 * 
 */
#include <sqlite.mqh>
/*
 * SQLite functions
 */
bool DB_checkTableExists(string _db, string _table)
{
	int res = sqlite_table_exists (_db, _table);

	if(res < 0) {
		outputLog("Check for table existence failed with code " + res, "Error");
		return(false);
	}

	return(res > 0);
}

void DB_exec(string _db, string _exp)
{
	int res = sqlite_exec (_db, _exp);

	if(res != 0)
		outputLog("Expression '" + _exp + "' failed with code " + res, "Error");
}

bool DB_logOrderInfo(string _db, string _tb, string _dt, int _mg)
{
	if(!DB_checkTableExists(_db, _tb))
		sendAlert("[" + _tb + "] table is not exists.", "Error");

	string currtime = TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS);
	int ordertotal = OrdersTotal();
	string query = "INSERT INTO " + _tb + " (datetime,ticket,symbol,type,size,openprice,closeprice,commission,profit,swap) ";
   
	//-- order log
	for(int i = 0; i < ordertotal; i++)
	{
		if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
		{
			if(OrderMagicNumber() == _mg)
			{
				query = StringConcatenate(
					query,
					"select \"" + _dt + "\", " + OrderTicket() + ", \"" + OrderSymbol() + "\", ",
					OrderType() + ", " + OrderLots() + ", " + OrderOpenPrice() + ", ",
					OrderClosePrice() + ", " + OrderCommission() + ", " + OrderProfit() + ", " + OrderSwap() + " union all "
				);
			}
		}
	}

	query = StringSubstr(query, 0, StringLen(query) - 11);
	
	DB_exec(_db, query);

	return(true);
}

bool DB_logAccountInfo(string _db, string _tb, string _dt)
{
	if(!DB_checkTableExists(_db, _tb))
		sendAlert("[" + _tb + "] table is not exists.", "Error");

	string query = "INSERT INTO " + _tb + " (datetime,broker,account,balance,equity,margin,freemargin,leverage) VALUES ";
	query = StringConcatenate(
		query + "(",
		"\"" + _dt + "\",",
		"\"" + AccountCompany() + "\",",
		AccountNumber() + ",",
		AccountBalance() + ",",
		AccountEquity() + ",",
		AccountMargin() + ",",
		AccountFreeMargin() + ",",
		AccountLeverage() + ")"
	);

	DB_exec(_db, query);

	return(true);
}