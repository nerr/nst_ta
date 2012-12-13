#property copyright "Copyright ? 2012 Nerrsoft.com"
#property link      "http://nerrsoft.com"
//--
#include <sqlite.mqh>
#include <nst_ta_public.mqh>


string 	db_name 	= "D:\\Documents\\alpariukswaptest.db";
string 	db_table	= "dayinfo";
int 	magicnum	= 701;


int start ()
{
	if (!D_checkTableExists(db_name, db_table))
		sendAlert("db is not exists.", "Error");

	string currtime = TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS);
	int ordertotal = OrdersTotal();
	string query = "INSERT INTO " + db_table + " (datetime,ticket,symbol,type,size,openprice,closeprice,commission,profit,swap) ";


	for(int i = 0; i < ordertotal; i++)
	{
		if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
		{
			if(OrderMagicNumber() == magicnum)
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

	return(0);
}

//-- functions about db
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