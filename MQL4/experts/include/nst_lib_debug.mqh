/*
 * Output Dubug/Alert/Notification Funcs
 *
 */

//-- send print
void libDebugOutputLog(string _logtext, string _type="Information")
{
    string text = ">>>" + _type + ":" + _logtext;
    Print(text);
}

//-- send notification
void libDebugSendNotifi(string _logtext, string _type="Information")
{
    string text = ">>>" + _type + ":" + _logtext;
    SendNotification(text);
}

//-- send alert
void libDebugSendAlert(string _text = "null", string _type="Information")
{
    libDebugOutputLog(_text, _type);
    libDebugSendNotifi(_text, _type);
    PlaySound("alert.wav");
    Alert(_text);
}