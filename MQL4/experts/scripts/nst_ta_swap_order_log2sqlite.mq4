#property copyright "Copyright ? 2013 Nerrsoft.com"
#property link      "http://nerrsoft.com"
//--
#include <nst_ta_public.mqh>


string 	db_name 		= "D:\\Documents\\alpariuk";
string 	db_ordertable	= "dayinfo";
string 	db_accounttable	= "accountinfo";
int 	magicnum		= 701;

void start()
{
	db_name = db_name + AccountNumber() + ".db";

	string currtime = TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS);
	DB_logOrderInfo(db_name, db_ordertable, currtime, magicnum);
	DB_logAccountInfo(db_name, db_accounttable, currtime);
}