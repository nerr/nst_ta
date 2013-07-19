/*
 * Date & Time Funcs
 *
 */

//-- trans datatime to string format
string libDatetimeTm2str(datetime _t)
{
    string strtime = TimeToStr(_t, TIME_DATE | TIME_SECONDS);
    strtime = StringSetChar(strtime, 4, '-');
    strtime = StringSetChar(strtime, 7, '-');

    return(strtime);
}