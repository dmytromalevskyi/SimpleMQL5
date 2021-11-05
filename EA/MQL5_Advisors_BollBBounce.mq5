//+------------------------------------------------------------------+
//|                                    MQL5_Advisors_BollBBounce.mq5 |
//|                                                 Dmytro Malevskyi |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Dmytro Malevskyi"
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- input parameters
input int      BBPeriod=20;
input double   BBDeviation=1.0;
input int      RSIPeriod=14;
input int      RSIoverBought=70;
input int      RSIoverSold=30;
input int      TakeProfit=100;
input int      StopLose=50;
input double   TradeVolume=0.01;
input int      magicNumber=23789;

//--- buffers
double upperBandBuffer[];
double middleBandBuffer[];
double lowerBandBuffer[];
double rsiBuffer[];
// price buffers
double close[];
double high[];
double low[];

//--- other global variables
int BBbandHandle = 0;
int RSIbandHandle = 0;
bool longOpen;
bool shortOpen;
int history = 100;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ArraySetAsSeries(upperBandBuffer,true);
   ArraySetAsSeries(middleBandBuffer,true);
   ArraySetAsSeries(lowerBandBuffer,true);
   ArraySetAsSeries(rsiBuffer,true);
   
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   
   BBbandHandle = iBands(_Symbol, _Period, BBPeriod, 0, BBDeviation, PRICE_CLOSE);
   RSIbandHandle = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE);
   
   longOpen = false;
   shortOpen = false;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if (CopyBuffer(BBbandHandle,1,0,history,upperBandBuffer) < 0) {PrintFormat("Error loading upper band data, code %d", GetLastError()); return;}
   if (CopyBuffer(BBbandHandle,2,0,history,lowerBandBuffer) < 0) {PrintFormat("Error loading lower band data, code %d", GetLastError()); return;}
   if (CopyBuffer(BBbandHandle,0,0,history,middleBandBuffer) < 0) {PrintFormat("Error loading middle band data, code %d", GetLastError()); return;}
   if (CopyBuffer(RSIbandHandle,0,0,history,rsiBuffer) < 0) {PrintFormat("Error loading rsi band data, code %d", GetLastError()); return;}
   
   if (CopyClose(_Symbol,_Period,0,history,close) < 0) {PrintFormat("Error loading close band data, code %d", GetLastError()); return;}
   if (CopyClose(_Symbol,_Period,0,history,high) < 0) {PrintFormat("Error loading high band data, code %d", GetLastError()); return;}
   if (CopyClose(_Symbol,_Period,0,history,low) < 0) {PrintFormat("Error loading low band data, code %d", GetLastError()); return;}
   
   MqlTradeRequest request;
   MqlTradeResult result;
   
   if(PositionSelect(_Symbol))
      {
         if ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            longOpen = true;
         else if ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            shortOpen = true;
      }
      
   else
      {
         longOpen = false;
         shortOpen = false;
      }
      
   if (isNewBar())
      {
         if ((rsiBuffer[1] <= RSIoverSold) && (low[1] < lowerBandBuffer[1]) && (!longOpen))   // ---- go long DONE
         {
            ZeroMemory(request);
            double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            request.action = TRADE_ACTION_DEAL;
            request.type = ORDER_TYPE_BUY;
            request.symbol = _Symbol;
            request.volume = TradeVolume;
            request.type_filling = ORDER_FILLING_FOK; // FILL ALL OF THE ORDER OR NOT AT ALL
            request.price = price;
            request.tp = price + (TakeProfit * _Point);
            request.sl = price - (StopLose * _Point);
            request.deviation = 10;
            request.magic = magicNumber;
            
            if ( OrderSend(request,result) )
            {
               Print("Long Order: ", result.comment);
               longOpen = true;
            }
            else
            {
               Print("Long Order Fail: ", result.comment);
            }
         }
         else if ((close[1] > middleBandBuffer[1]) && (longOpen))  // ---- exit long DONE
         {
            ZeroMemory(request);
            ulong ticket = PositionGetTicket(0);
            request.type = ORDER_TYPE_SELL;
            request.position = ticket;
            request.price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            request.action = TRADE_ACTION_DEAL;
            request.symbol = _Symbol;
            request.volume = PositionGetDouble(POSITION_VOLUME);
            request.magic = magicNumber;
            request.deviation = 10;
            
            if ( OrderSend(request,result) )
            {
               Print("Long Exit Order: ", result.comment);
               longOpen = false;
            }
            else
            {
               Print("Long Exit Order Fail: ", result.comment);
            }
            
         }
         else if ((rsiBuffer[1] >= RSIoverBought) && (high[1] > upperBandBuffer[1]) && (!shortOpen))   // ---- go short DONE
         {
            ZeroMemory(request);
            double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            request.action = TRADE_ACTION_DEAL;
            request.type = ORDER_TYPE_SELL;
            request.symbol = _Symbol;
            request.volume = TradeVolume;
            request.type_filling = ORDER_FILLING_FOK; // FILL ALL OF THE ORDER OR NOT AT ALL
            request.price = price;
            request.tp = price - (TakeProfit * _Point);
            request.sl = price + (StopLose * _Point);
            request.deviation = 10;
            request.magic = magicNumber;
            
            if ( OrderSend(request,result) )
            {
               Print("Long Order: ", result.comment);
               longOpen = true;
            }
            else
            {
               Print("Long Order Fail: ", result.comment);
            }
         }
         else if ((close[1] < middleBandBuffer[1]) && (shortOpen)) // ---- exit short DONE
         {
            ZeroMemory(request);
            ulong ticket = PositionGetTicket(0);
            request.type = ORDER_TYPE_BUY;
            request.position = ticket;
            request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            request.action = TRADE_ACTION_DEAL;
            request.symbol = _Symbol;
            request.volume = PositionGetDouble(POSITION_VOLUME);
            request.magic = magicNumber;
            request.deviation = 10;
            
            if ( OrderSend(request,result) )
            {
               Print("Short Exit Order: ", result.comment);
               longOpen = false;
            }
            else
            {
               Print("Short Exit Order Fail: ", result.comment);
            }
         }
      }
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+

bool isNewBar()
   {
     static long last_time = 0;
     long lastbar_time = SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
     
     if (last_time == 0)
     {
        last_time = lastbar_time;
        return false;
     }
     
     if (last_time != lastbar_time)
     {
         last_time = lastbar_time;
         return true;
     }
     
     return false;
     
   }