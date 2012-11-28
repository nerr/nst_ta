/* Nerr Smart Trader - Include - Public Functions
 *
 * By Leon Zhuang
 * Twitter @Nerrsoft
 * leon@nerrsoft.com
 * http://nerrsoft.com
 *
 * 
 */

//-- send print
void outputLog(string _logtext, string _type="Information")
{
	string text = ">>>" + _type + ":" + _logtext;
	Print(text);
}

//-- send alert
void sendAlert(string _text = "null")
{
	outputLog(_text);
	PlaySound("alert.wav");
	Alert(_text);
}

//-- desc error code to string
string errorDescription(int _error)
{

	string ErrorNumber;
	switch(_error) {
		//-- information by server
		case 0:
		case 1:     ErrorNumber = "ERR_NO_RESULT"; break;
		case 2:     ErrorNumber = "ERR_COMMON_ERROR"; break;
		case 3:     ErrorNumber = "ERR_INVALID_TRADE_PARAMETERS"; break;
		case 4:     ErrorNumber = "ERR_SERVER_BUSY"; break;
		case 5:     ErrorNumber = "ERR_OLD_VERSION"; break;
		case 6:     ErrorNumber = "ERR_NO_CONNECTION"; break;
		case 7:     ErrorNumber = "ERR_NOT_ENOUGH_RIGHTS"; break;
		case 8:     ErrorNumber = "ERR_TOO_FREQUENT_REQUESTS"; break;
		case 9:     ErrorNumber = "ERR_MALFUNCTIONAL_TRADE"; break;
		case 64:    ErrorNumber = "ERR_ACCOUNT_DISABLED"; break;
		case 65:    ErrorNumber = "ERR_INVALID_ACCOUNT"; break;
		case 128:   ErrorNumber = "ERR_TRADE_TIMEOUT"; break;
		case 129:   ErrorNumber = "ERR_INVALID_PRICE"; break;
		case 130:   ErrorNumber = "ERR_INVALID_STOPS"; break;
		case 131:   ErrorNumber = "ERR_INVALID_TRADE_VOLUME"; break;
		case 132:   ErrorNumber = "ERR_MARKET_CLOSED"; break;
		case 133:   ErrorNumber = "ERR_TRADE_DISABLED"; break;
		case 134:   ErrorNumber = "ERR_NOT_ENOUGH_MONEY"; break;
		case 135:   ErrorNumber = "ERR_PRICE_CHANGED"; break;
		case 136:   ErrorNumber = "ERR_OFF_QUOTES"; break;
		case 137:   ErrorNumber = "ERR_BROKER_BUSY"; break;
		case 138:   ErrorNumber = "ERR_REQUOTE"; break;
		case 139:   ErrorNumber = "ERR_ORDER_LOCKED"; break;
		case 140:   ErrorNumber = "ERR_LONG_POSITIONS_ONLY_ALLOWED"; break;
		case 141:   ErrorNumber = "ERR_TOO_MANY_REQUESTS"; break;
		case 145:   ErrorNumber = "ERR_TRADE_MODIFY_DENIED"; break;
		case 146:   ErrorNumber = "ERR_TRADE_CONTEXT_BUSY"; break;
		case 147:   ErrorNumber = "ERR_TRADE_EXPIRATION_DENIED"; break;
		case 148:   ErrorNumber = "ERR_TRADE_TOO_MANY_ORDERS"; break;
		case 149:   ErrorNumber = "ERR_TRADE_HEDGE_PROHIBITED"; break;
		case 150:   ErrorNumber = "ERR_TRADE_PROHIBITED_BY_FIFO"; break;

		//-- MQL4 running information
		case 4000:  ErrorNumber = "ERR_NO_MQLERROR"; break;
		case 4001:  ErrorNumber = "ERR_WRONG_FUNCTION_POINTER"; break;
		case 4002:  ErrorNumber = "ERR_ARRAY_INDEX_OUT_OF_RANGE"; break;
		case 4003:  ErrorNumber = "ERR_NO_MEMORY_FOR_CALL_STACK"; break;
		case 4004:  ErrorNumber = "ERR_RECURSIVE_STACK_OVERFLOW"; break;
		case 4005:  ErrorNumber = "ERR_NOT_ENOUGH_STACK_FOR_PARAM"; break;
		case 4006:  ErrorNumber = "ERR_NO_MEMORY_FOR_PARAM_STRING"; break;
		case 4007:  ErrorNumber = "ERR_NO_MEMORY_FOR_TEMP_STRING"; break;
		case 4008:  ErrorNumber = "ERR_NOT_INITIALIZED_STRING"; break;
		case 4009:  ErrorNumber = "ERR_NOT_INITIALIZED_ARRAYSTRING"; break;
		case 4010:  ErrorNumber = "ERR_NO_MEMORY_FOR_ARRAYSTRING"; break;
		case 4011:  ErrorNumber = "ERR_TOO_LONG_STRING"; break;
		case 4012:  ErrorNumber = "ERR_REMAINDER_FROM_ZERO_DIVIDE"; break;
		case 4013:  ErrorNumber = "ERR_ZERO_DIVIDE"; break;
		case 4014:  ErrorNumber = "ERR_UNKNOWN_COMMAND"; break;
		case 4015:  ErrorNumber = "ERR_WRONG_JUMP"; break;
		case 4016:  ErrorNumber = "ERR_NOT_INITIALIZED_ARRAY"; break;
		case 4017:  ErrorNumber = "ERR_DLL_CALLS_NOT_ALLOWED"; break;
		case 4018:  ErrorNumber = "ERR_CANNOT_LOAD_LIBRARY"; break;
		case 4019:  ErrorNumber = "ERR_CANNOT_CALL_FUNCTION"; break;
		case 4020:  ErrorNumber = "ERR_EXTERNAL_CALLS_NOT_ALLOWED"; break;
		case 4021:  ErrorNumber = "ERR_NO_MEMORY_FOR_RETURNED_STR"; break;
		case 4022:  ErrorNumber = "ERR_SYSTEM_BUSY"; break;
		case 4050:  ErrorNumber = "ERR_INVALID_FUNCTION_PARAMSCNT"; break;
		case 4051:  ErrorNumber = "ERR_INVALID_FUNCTION_PARAM"; break;
		case 4052:  ErrorNumber = "ERR_STRING_FUNCTION_INTERNAL"; break;
		case 4053:  ErrorNumber = "ERR_SOME_ARRAY_ERROR"; break;
		case 4054:  ErrorNumber = "ERR_INCORRECT_SERIESARRAY_USING"; break;
		case 4055:  ErrorNumber = "ERR_CUSTOM_INDICATOR_ERROR"; break;
		case 4056:  ErrorNumber = "ERR_INCOMPATIBLE_ARRAYS"; break;
		case 4057:  ErrorNumber = "ERR_GLOBAL_VARIABLES_PROCESSING"; break;
		case 4058:  ErrorNumber = "ERR_GLOBAL_VARIABLE_NOT_FOUND"; break;
		case 4059:  ErrorNumber = "ERR_FUNC_NOT_ALLOWED_IN_TESTING"; break;
		case 4060:  ErrorNumber = "ERR_FUNCTION_NOT_CONFIRMED"; break;
		case 4061:  ErrorNumber = "ERR_SEND_MAIL_ERROR"; break;
		case 4062:  ErrorNumber = "ERR_STRING_PARAMETER_EXPECTED"; break;
		case 4063:  ErrorNumber = "ERR_INTEGER_PARAMETER_EXPECTED"; break;
		case 4064:  ErrorNumber = "ERR_DOUBLE_PARAMETER_EXPECTED"; break;
		case 4065:  ErrorNumber = "ERR_ARRAY_AS_PARAMETER_EXPECTED"; break;
		case 4066:  ErrorNumber = "ERR_HISTORY_WILL_UPDATED"; break;
		case 4067:  ErrorNumber = "ERR_TRADE_ERROR"; break;
		case 4099:  ErrorNumber = "ERR_END_OF_FILE"; break;
		case 4100:  ErrorNumber = "ERR_SOME_FILE_ERROR"; break;
		case 4101:  ErrorNumber = "ERR_WRONG_FILE_NAME"; break;
		case 4102:  ErrorNumber = "ERR_TOO_MANY_OPENED_FILES"; break;
		case 4103:  ErrorNumber = "ERR_CANNOT_OPEN_FILE"; break;
		case 4104:  ErrorNumber = "ERR_INCOMPATIBLE_FILEACCESS"; break;
		case 4105:  ErrorNumber = "ERR_NO_ORDER_SELECTED"; break;
		case 4106:  ErrorNumber = "ERR_UNKNOWN_SYMBOL"; break;
		case 4107:  ErrorNumber = "ERR_INVALID_PRICE_PARAM"; break;
		case 4108:  ErrorNumber = "ERR_INVALID_TICKET"; break;
		case 4109:  ErrorNumber = "ERR_TRADE_NOT_ALLOWED"; break;
		case 4110:  ErrorNumber = "ERR_LONGS_NOT_ALLOWED"; break;
		case 4111:  ErrorNumber = "ERR_SHORTS_NOT_ALLOWED"; break;
		case 4200:  ErrorNumber = "ERR_OBJECT_ALREADY_EXISTS"; break;
		case 4201:  ErrorNumber = "ERR_UNKNOWN_OBJECT_PROPERTY"; break;
		case 4202:  ErrorNumber = "ERR_OBJECT_DOES_NOT_EXIST"; break;
		case 4203:  ErrorNumber = "ERR_UNKNOWN_OBJECT_TYPE"; break;
		case 4204:  ErrorNumber = "ERR_NO_OBJECT_NAME"; break;
		case 4205:  ErrorNumber = "ERR_OBJECT_COORDINATES_ERROR"; break;
		case 4206:  ErrorNumber = "ERR_NO_SPECIFIED_SUBWINDOW"; break;
		case 4207:  ErrorNumber = "ERR_SOME_OBJECT_ERROR"; break;
		default:    ErrorNumber = "";
	}
	//---
	return(ErrorNumber);
}

