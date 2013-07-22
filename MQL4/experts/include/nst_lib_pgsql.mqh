//-- check sql result has error or not
bool libPgsqlIsError(string _str)
{
    return(StringFind(_str, "error") != -1);
}

//-- trans string query result to an array
void libPgsqlFetchArr(string _pgres, string &_data[][])
{
    int es, vs; //equalsign, verticalsing
    int size = ArrayRange(_data, 1);
    int i = 0;
    int ii = 0;
    int digi;

    ArrayResize(_data, libPgsqlFetchRows(_pgres));
    string res;
    _pgres = "*" + _pgres;

    while(StringFind(_pgres, "*", 0) == 0)
    {
        res = StringSubstr(_pgres, 0, StringFind(_pgres, "*", 1));

        for(ii = 0; ii < size; ii++)
        {
            es = StringFind(res, "=", vs);
            vs = StringFind(res, "|", es);

            if(es+1==vs)
                _data[i,ii] = "";
            else if(es>0 && vs==-1)
                _data[i,ii] = StringSubstr(res, es+1, -1);
            else
                _data[i,ii] = StringSubstr(res, es+1, vs-es-1);
        }

        digi = StringFind(_pgres, "*", 1);

        if(digi == -1)
            break;
        else
        {
            _pgres = StringSubstr(_pgres, digi, StringLen(_pgres)-1);
            i++;
        }
    }
}

//-- fetch rows of a query
int libPgsqlFetchRows(string _pgres)
{
    int i = 0;
    int digi = 0;
    _pgres = "*" + _pgres;

    while(StringFind(_pgres, "*", 0) == 0)
    {
        i++;
        digi = StringFind(_pgres, "*", 1);

        if(digi == -1)
            break;
        else
            _pgres = StringSubstr(_pgres, digi, StringLen(_pgres)-1);
    }

    return(i);
}