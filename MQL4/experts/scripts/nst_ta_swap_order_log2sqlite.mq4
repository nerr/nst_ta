#property copyright "Copyright ? 2012 Nerrsoft.com"
#property link      "http://nerrsoft.com"
//--
#include <nst_ta_public.mqh>


string 	db_name 		= "D:\\Documents\\alpariukswaptest.db";
string 	db_ordertable	= "dayinfo";
string 	db_accounttable	= "accountinfo";
int 	magicnum		= 701;

void start()
{
	string currtime = TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS);
	DB_logOrderInfo(db_name, db_ordertable, currtime, magicnum);
	DB_logAccountInfo(db_name, db_accounttable, currtime);
}