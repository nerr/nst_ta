/*
 * Set Display funcs
 *
 */

//-- create text object
void libVisualCreateTextObj(string objName, int xDistance, int yDistance, string objText="", color fontcolor=GreenYellow, string font="Courier New", int fontsize=9)
{
    if(ObjectFind(objName)<0)
    {
        ObjectCreate(objName, OBJ_LABEL, 0, 0, 0);
        ObjectSetText(objName, objText, fontsize, font, fontcolor);
        ObjectSet(objName, OBJPROP_XDISTANCE,   xDistance);
        ObjectSet(objName, OBJPROP_YDISTANCE,   yDistance);
    }
}

//-- set text object new value
void libVisualSetTextObj(string objName, string objText="", color fontcolor=White, string font="Courier New", int fontsize=9)
{
    if(ObjectFind(objName)>-1)
    {
        ObjectSetText(objName, objText, fontsize, font, fontcolor);
    }
}