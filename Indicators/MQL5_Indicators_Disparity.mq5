//+------------------------------------------------------------------+
//|                                    MQL5_Indicators_Disparity.mq5 |
//|                                                 Dmytro Malevskyi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Dmytro Malevskyi"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot Disparity
#property indicator_label1  "Disparity"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrRed,clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      MAPeriod=200;
//--- indicator buffers
double         DisparityBuffer[];
double         DisparityColor[];
double         MABuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,DisparityBuffer,INDICATOR_DATA);
   SetIndexBuffer(1, DisparityColor, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, MABuffer, INDICATOR_CALCULATIONS);
   
   // Setting for the graph
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetString(INDICATOR_SHORTNAME, "Disparity Index ("+(string)MAPeriod+")");
   

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
   double sumPrice = 0.0;
   
   if(rates_total <= MAPeriod)
      return(0);

   int pos = prev_calculated - 1;
   if(pos <= MAPeriod)
     {
      sumPrice = 0.0;
      for(int i=0; i<MAPeriod; i++)
        {
         MABuffer[i] = 0.0;
         DisparityBuffer[i] = 0.0;
         sumPrice += close[i];
        }
      MABuffer[MAPeriod] = sumPrice / MAPeriod;
      DisparityBuffer[MAPeriod] = ((close[MAPeriod] - MABuffer[MAPeriod]) / MABuffer[MAPeriod]) * 100;
      pos = MAPeriod + 1;
     }

   for(int i=pos; i<rates_total && !IsStopped(); i++)
     {
      MABuffer[i] = MABuffer[i-1] + (close[i] - close[i-MAPeriod]) / MAPeriod;
      DisparityBuffer[i] = ((close[i] - MABuffer[i]) / MABuffer[i]) * 100;

      // Adding colour
      if(DisparityBuffer[i] < 0)
         DisparityColor[i] = 0;
      else
         DisparityColor[i] = 1;
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
