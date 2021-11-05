//+------------------------------------------------------------------+
//|                                MQL5_Indicators_StochasticRSI.mq5 |
//|                                                 Dmytro Malevskyi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Dmytro Malevskyi"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 5
#property indicator_plots   1
//--- plot StoRSI
#property indicator_label1  "StoRSI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGreenYellow,clrYellow,clrBlue,clrOrange,clrLightSlateGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      RSIPeriod=14;
input int      InpKPeriod=5;
input int      InpDPeriod=3;
input int      InpSlowing=3;
input int      UpperLevel=80;
input int      LowerLevel=20;
//--- indicator buffers
double         StoRSIBuffer[];
double         StoRSIColors[];
double         RsiBuffer[];
double         HHBuffer[];
double         LLBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,StoRSIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,StoRSIColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,RsiBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,HHBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,LLBuffer,INDICATOR_CALCULATIONS);
   
   // Indicator Look
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,LowerLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,UpperLevel);
   IndicatorSetString(INDICATOR_SHORTNAME, "StochRSI("+RSIPeriod+","+InpKPeriod+","+InpDPeriod+","+InpSlowing+")");
   
   // Extra data
   RsiHandle = iRSI(_Symbol,_Period,RSIPeriod,PRICE_CLOSE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   if (rates_total <= InpKPeriod+InpDPeriod+InpSlowing)
      return(0);
   
   if(CopyBuffer(RsiHandle, 0, 0, rates_total, RsiBuffer) < 0)
   {
      Print("Rsi data could not be loaded, Error code: ", GetLastError());
      return(0);
   }
   
   int pos = RSIPeriod-1;
   if(pos+1 < prev_calculated) pos = prev_calculated-2;
   else
     {
      for(int i=0;i<total;i++)
        {
         
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
