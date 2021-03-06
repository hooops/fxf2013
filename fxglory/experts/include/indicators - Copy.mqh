//+------------------------------------------------------------------+
//|                                                   indicators.mq4 |
//|                                              Manish Khanchandani |
//|                                              http://mkgalaxy.com |
//+------------------------------------------------------------------+
#property copyright "Manish Khanchandani"
#property link      "http://mkgalaxy.com"

double ichimoku[8][9999];
string bollingerband;
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2005

//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);

// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import

//+------------------------------------------------------------------+
//| EX4 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex4"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

string TimeframeToString(int P)
{
   switch(P)
   {
      case PERIOD_M1:  return("M1");
      case PERIOD_M5:  return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1:  return("H1");
      case PERIOD_H4:  return("H4");
      case PERIOD_D1:  return("D1");
      case PERIOD_W1:  return("W1");
      case PERIOD_MN1: return("MN1");
   }
}
int ind_momentum(int shift, string symbol, int timeframe)
{
   double momentum;
   momentum = iMomentum(symbol,timeframe,14,PRICE_CLOSE,shift);
   if (momentum > 0) {
      return (1);
   } else if (momentum < 0) {
      return (-1);
   } else {
      return (0);
   }
}


double ichimoku(int num, string symbol, int timeframe)
{
   int Tenkan=9;
   int Kijun=26;
   int Senkou=52;
   int max_number = 5;
   //ichimoku[0] tenkan_sen
   //ichimoku[1] kijun_sen
   //ichimoku[2] senkou_span_a
   //ichimoku[3] senkou_span_b
   //ichimoku[4] senkou_span_high
   //ichimoku[5] senkou_span_low
   //ichimoku[6] chinkou_span
   //ichimoku[7] chinkou_span_mode
   for (int i = num; i <= (num + max_number); i++) {
      ichimoku[0][i] = iIchimoku(symbol, timeframe, Tenkan, Kijun, Senkou, MODE_TENKANSEN, i);
      ichimoku[1][i] = iIchimoku(symbol, timeframe, Tenkan, Kijun, Senkou, MODE_KIJUNSEN, i);
      ichimoku[2][i] = iIchimoku(symbol, timeframe, Tenkan, Kijun, Senkou, MODE_SENKOUSPANA, i);
      ichimoku[3][i] = iIchimoku(symbol, timeframe, Tenkan, Kijun, Senkou, MODE_SENKOUSPANB, i);
      if (ichimoku[2][i] >= ichimoku[3][i]) {
         ichimoku[4][i] = ichimoku[2][i];
         ichimoku[5][i] = ichimoku[3][i];
      } else if(ichimoku[2][i] <= ichimoku[3][i]) {
         ichimoku[4][i] = ichimoku[3][i];
         ichimoku[5][i] = ichimoku[2][i];
      }
      ichimoku[6][i] = iIchimoku(symbol, timeframe, Tenkan, Kijun, Senkou, MODE_CHINKOUSPAN, i+26);
      ichimoku[7][i] = chinkou_span_mode((i+26), ichimoku[6][i]);
      //Alert(i, " - ", tenkan_sen[i], " - ", kijun_sen[i], " - ", senkou_span_a[i], " - ", senkou_span_b[i], " - ", chinkou_span[i], " - (", chinkou_span_mode[i], ")");
   }
   /*infobox = StringConcatenate(infobox, "\nTenkan Sen: ", DoubleToStr(tenkan_sen[num],Digits), ", Kijun Sen: ", DoubleToStr(kijun_sen[num],Digits), 
      ", Senkou A: ", DoubleToStr(senkou_span_a[num],Digits), ", Senkou B: ", DoubleToStr(senkou_span_b[num],Digits), ", Chinkou Span: ", DoubleToStr(chinkou_span[num],Digits), 
      ", Chinkou Mode: (", chinkou_span_mode[num], ")");*/
   return (ichimoku);
}
int chinkou_span_mode(int number, double cs)
{
   double high,low;
   high = High[number];
   low = Low[number];
   if (cs >= high){
      return (1);
   } else if (cs <= low){
      return (-1);
   } else {
     return (0);
   }
}


// Kumo Breakout
int kumo_breakout(int num)
{
   int result = 0;
   //strong buy condition
   if (Open[num] < ichimoku[4][num] && Close[num] > ichimoku[4][num]) {
      result = 1;
   }
   //strong sell condition
   else if (Open[num] > ichimoku[5][num] && Close[num] < ichimoku[5][num]) {
      result = -1;
   }
   return (result);
}



int alligator(int num, string symbol, int timeframe)
{
   int result = 0;
   double jaw_val=iAlligator(symbol, timeframe, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, (num-2));
   double teeth_val=iAlligator(symbol, timeframe, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, (num-2));
   double lips_val=iAlligator(symbol, timeframe, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, (num-2));
   
   //buy condition
   if (jaw_val < teeth_val && teeth_val < lips_val) {
      result = 1;
   }
   //sell condition
   else if (jaw_val > teeth_val && teeth_val > lips_val) {
      result = -1;
   }
   else {
      result = 0;
   }
   
   return (result);
}

int bollingerbands(int num, string symbol, int timeframe)
{
   bollingerband = "Bollinger Band Study: ";
   double b1 = iBands(symbol,timeframe,20,2,0,PRICE_CLOSE,MODE_UPPER,num);
   double b2 = iBands(symbol,timeframe,20,2,0,PRICE_CLOSE,MODE_LOWER,num);
   double ma = double iMA(symbol, timeframe, 20, 0, MODE_SMA, PRICE_CLOSE, num);
   double low[3];
   double high[3];
   high[0] = High[(num)];
   high[1] = High[(num+1)];
   high[2] = High[(num+2)];
   low[0] = Low[(num)];
   low[1] = Low[(num+1)];
   low[2] = Low[(num+2)];
   //Alert("start: ", DoubleToStr(b1, Digits), ", ", DoubleToStr(ma, Digits), ", ", DoubleToStr(b2, Digits));
   //Alert("Low: ", DoubleToStr(low[0], Digits), ", ", DoubleToStr(low[1], Digits), ", ", DoubleToStr(low[2], Digits));
   //Alert("High: ", DoubleToStr(high[0], Digits), ", ", DoubleToStr(high[1], Digits), ", ", DoubleToStr(high[2], Digits));
   bollingerband = StringConcatenate(bollingerband, "start: upper: ", DoubleToStr(b1, Digits), ", ma: ", DoubleToStr(ma, Digits), ", lower: ", DoubleToStr(b2, Digits)
   , ", Low: ", DoubleToStr(low[0], Digits), ", ", DoubleToStr(low[1], Digits), ", ", DoubleToStr(low[2], Digits)
   , ", High: ", DoubleToStr(high[0], Digits), ", ", DoubleToStr(high[1], Digits), ", ", DoubleToStr(high[2], Digits)
   , ", Current Open: ",Open[(num-1)], ", Current Close: ", Close[(num-1)]
   , "\nBollinger Band: "
   );
Print("bollingerband: ", bollingerband);
   int result = 0;
   if (low[0] > ma && low[1] > ma && low[2] > ma) { //search for sell
      bollingerband = StringConcatenate(bollingerband, "searching sell condition. ");
      if (high[0] < high[1] && high[2] < high[1] && Open[(num-1)] > Close[(num-1)]) {
         bollingerband = StringConcatenate(bollingerband, "sell condition exists. ");
         Print(symbol, ", period: ", TimeframeToString(timeframe), ", sell condition exists using bollingerband.");
         result = -1;
      }
   }
   else if (high[0] < ma && high[1] < ma && high[2] < ma) { //search for buy
      bollingerband = StringConcatenate(bollingerband, "searching buy condition. ");
      if (low[0] > low[1] && low[2] > high[1] && Open[(num-1)] < Close[(num-1)]) {
         bollingerband = StringConcatenate(bollingerband, "buy condition exists. ");
         Print(symbol, ", period: ", TimeframeToString(timeframe), ", buy condition exists using bollingerband.");
         result = 1;
      }
   }
   else {
      bollingerband = StringConcatenate(bollingerband, "No Buy and Sell condition. ");
   }
   return (result);
}