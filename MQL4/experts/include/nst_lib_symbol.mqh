int libSymbolsList(string &Symbols[], bool Selected)
{
   string SymbolsFileName;
   int Offset, SymbolsNumber;
   
   if(Selected) SymbolsFileName = "symbols.sel";
   else         SymbolsFileName = "symbols.raw";
   
   int hFile = FileOpenHistory(SymbolsFileName, FILE_BIN|FILE_READ);
   if(hFile < 0) return(-1);

   if(Selected) { SymbolsNumber = (FileSize(hFile) - 4) / 128; Offset = 116;  }
   else         { SymbolsNumber = FileSize(hFile) / 1936;      Offset = 1924; }

   ArrayResize(Symbols, SymbolsNumber);

   if(Selected) FileSeek(hFile, 4, SEEK_SET);
   
   for(int i = 0; i < SymbolsNumber; i++)
   {
      Symbols[i] = FileReadString(hFile, 12);
      FileSeek(hFile, Offset, SEEK_CUR);
   }
   
   FileClose(hFile);
   
   return(SymbolsNumber);
}




string libSymbolDescription(string SymbolName)
{
   string SymbolDescription = "";
   
   int hFile = FileOpenHistory("symbols.raw", FILE_BIN|FILE_READ);
   if(hFile < 0) return("");

   int SymbolsNumber = FileSize(hFile) / 1936;

   for(int i = 0; i < SymbolsNumber; i++)
   {
      if(FileReadString(hFile, 12) == SymbolName)
      {
         SymbolDescription = FileReadString(hFile, 64);
         break;
      }
      FileSeek(hFile, 1924, SEEK_CUR);
   }
   
   FileClose(hFile);
   
   return(SymbolDescription);
}




string libSymbolType(string SymbolName)
{
   int GroupNumber = -1;
   string SymbolGroup = "";
   
   int hFile = FileOpenHistory("symbols.raw", FILE_BIN|FILE_READ);
   if(hFile < 0) return("");
      
   int SymbolsNumber = FileSize(hFile) / 1936;
      
   for(int i = 0; i < SymbolsNumber; i++)
   {
      if(FileReadString(hFile, 12) == SymbolName)
      {         
         FileSeek(hFile, 1936*i + 100, SEEK_SET);
         GroupNumber = FileReadInteger(hFile);
         
         break;
      }
      FileSeek(hFile, 1924, SEEK_CUR);
   }
   
   FileClose(hFile);
   
   if(GroupNumber < 0) return("");
      
   hFile = FileOpenHistory("symgroups.raw", FILE_BIN|FILE_READ);
   if(hFile < 0) return("");
   
   FileSeek(hFile, 80*GroupNumber, SEEK_SET);
   SymbolGroup = FileReadString(hFile, 16);
   
   FileClose(hFile);
   
   return(SymbolGroup);
}