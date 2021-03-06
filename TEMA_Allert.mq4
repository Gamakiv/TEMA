//+------------------------------------------------------------------+
//|                                                       temaal.mq4 |
//|                                          Copyright 2020, GamaKiv |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2020, GamaKiv"
#property link      "https://www.mql5.com"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 2

#property indicator_color1 DodgerBlue
#property  indicator_width1  1

#property indicator_color2 Gold
#property  indicator_width2  1

//---- input parameters
extern int TEMA_fast_period=20;
extern int TEMA_slow_period=50;
extern bool Alerta = false;
extern bool SendaMail = false;
extern bool ShowStrelka = true;


//---- buffers
double TemaBuffer[];
double TemaBuffer_1[];

double Ema[];
double EmaOfEma[];
double EmaOfEmaOfEma[];

double Ema_1[];
double EmaOfEma_1[];
double EmaOfEmaOfEma_1[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
// <Буфер с добавлением _1 для медленной ТЕМА
   
   IndicatorBuffers(8);
      SetIndexStyle(0,DRAW_LINE);
      SetIndexBuffer(0,TemaBuffer);           
      SetIndexBuffer(1,TemaBuffer_1);
      
      SetIndexBuffer(2,Ema);
      SetIndexBuffer(3,Ema_1);
           
      SetIndexBuffer(4,EmaOfEma);
      SetIndexBuffer(5,EmaOfEma_1);
           
      SetIndexBuffer(6,EmaOfEmaOfEma);
      SetIndexBuffer(7,EmaOfEmaOfEma_1);
                            
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
    
   //значение быстрой TEMA текущее
   double  tema_fast_current = TEMA_F(TEMA_fast_period, 0);  
   //значение медленой ТЕМА текущее
   double  tema_slow_current = TEMA_S(TEMA_slow_period, 0);  
   
   //значение быстрой TEMA предидущее
   double  tema_fast_previous = TEMA_F(TEMA_fast_period, 1);     
   //значение медленой ТЕМА предидущее
   double  tema_slow_previous = TEMA_S(TEMA_slow_period, 1);  
   
   
   
   bool BuySignal=false;
   bool SellSignal=false;
   string TimeFrame = "";
   string text = "";
   string sub = "";
   
 
   
   if(tema_fast_current > tema_slow_current)
      { // Быстрая ТЕМА выше медленной
         if(tema_fast_previous<=tema_slow_previous)
            { // На предыдущем баре быстрая ТЕМА ниже медленной
               BuySignal=true;
            } 
      }
   
   if(tema_fast_current<tema_slow_current)
      { // Быстрая ТЕМА ниже медленной 
         if(tema_fast_previous>=tema_slow_previous)
            { // На предыдущем баре быстрая ТЕМА выше медленной
               SellSignal=true;
            } 
      }  
   
   //для проверки   
   //Comment("Быстрое тек - ", TEMA_F(TEMA_fast_period, 0), "  #  Медленое тек - ", tema_slow_current);
   
        
   //if(BuySignal == true)
   if(BuySignal && NewBar())
      {
                  if(ObjectDelete("ArrowUp") == false)
                     ObjectDelete("ArrowDown");
                  if(ShowStrelka == true)
                    {
                     GetArow("ArrowUp","Up");                
                    }
               
                  //необходимо свормировать данные для отправки
                  //получим текущий таймфрейм
                  switch(ChartPeriod(0))
                     {
                        case 1:  TimeFrame = "M1"; break; 
                        case 5:  TimeFrame = "M5"; break; 
                        case 15: TimeFrame = "M15"; break; 
                        case 30: TimeFrame = "M30"; break; 
                        case 60: TimeFrame = "H1"; break; 
                        case 240: TimeFrame = "H4"; break;
                        case 1440: TimeFrame = "D1"; break;                               
                     }
                     
                  
                  if(Alerta == true)
                     {
                        Alert("ПОКУПКА! СИГНАЛ! ", ChartSymbol(0), " on ", TimeFrame, " - ", TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS));
                     }
                     
                  if(SendaMail == true)
                     {
                        sub = "BUY Signal! " + ChartSymbol(0);
                        text = "Обнаружено пересечение TEMA по паре " +  ChartSymbol(0) + ". Таймфрем " 
                           + TimeFrame + " в " + TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS) 
                           + " Возможный СИГНАЛ НА ПОКУПКУ!";
                        SendMail(sub, text);
                     }
               
        }
     
     
     
   //if(SellSignal == true)
   if(SellSignal && NewBar())
      {
       //  Comment("СИГНАЛ НА ПРОДАЖУ");
                  if(ObjectDelete("ArrowUp") == false)
                     ObjectDelete("ArrowDown");
               
              if(ShowStrelka == true)
               {    
                  GetArow("ArrowUp","Down");       
               }
               
               //необходимо свормировать данные для отправки
               //получим текущий таймфрейм
               switch(ChartPeriod(0))
                  {
                     case 1:  TimeFrame = "M1"; break; 
                     case 5:  TimeFrame = "M5"; break; 
                     case 15: TimeFrame = "M15"; break; 
                     case 30: TimeFrame = "M30"; break; 
                     case 60: TimeFrame = "H1"; break; 
                     case 240: TimeFrame = "H4"; break;
                     case 1440: TimeFrame = "D1"; break;                               
                  }
                  
               
               if(Alerta == true)
                  {
                     Alert("ПРОДАЖА! СИГНАЛ! ", ChartSymbol(0), " на ", TimeFrame, " - ", TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS));
                  }
                  
               if(SendaMail == true)
                  {
                     sub = "Sell Signal! " + ChartSymbol(0);
                     text = "Обнаружено пересечение TEMA по паре " +  ChartSymbol(0) + ". Таймфрем " 
                     + TimeFrame +  " в " + TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS) 
                     + " Возможный СИГНАЛ НА ПРОДАЖУ! ";                     
                     SendMail(sub, text);
                  }
            
       }
              
   return(rates_total);
  }

//быстрая ТЕМА  
double TEMA_F(int period, int previous)   
   {
   int i,limit,limit2,limit3,counted_bars=IndicatorCounted();
//----
   if (counted_bars==0)
      {
         limit=Bars-1;
         limit2=limit-period;
         limit3=limit2-period;
      }
      
   if (counted_bars>0)
      {
         limit=Bars-counted_bars-1;
         limit2=limit;
         limit3=limit2;
      }
   for (i=limit;i>=0;i--) 
      Ema[i]=iMA(NULL,0,period,0,MODE_EMA,PRICE_CLOSE,i);
   for (i=limit2;i>=0;i--) 
      EmaOfEma[i]=iMAOnArray(Ema,0,period,0,MODE_EMA,i);
   for (i=limit3;i>=0;i--) 
      EmaOfEmaOfEma[i]=iMAOnArray(EmaOfEma,0,period,0,MODE_EMA,i);
   for (i=limit3;i>=0;i--) 
      TemaBuffer[i]=3*Ema[i]-3*EmaOfEma[i]+EmaOfEmaOfEma[i];   
   
   if (previous==0)
      {
         return(TemaBuffer[0]);
      }
      
   if (previous==1)
      {
         return(TemaBuffer[1]);
      }
   }
  

//медленная тема 
double TEMA_S(int period, int previous)  
   {
   int i,limit,limit2,limit3,counted_bars=IndicatorCounted();
//----
   if (counted_bars==0)
      {
         limit=Bars-1;
         limit2=limit-period;
         limit3=limit2-period;
      }
   if (counted_bars>0)
      {
         limit=Bars-counted_bars-1;
         limit2=limit;
         limit3=limit2;
      }
   for (i=limit;i>=0;i--) 
      Ema_1[i]=iMA(NULL,0,period,0,MODE_EMA,PRICE_CLOSE,i);
   for (i=limit2;i>=0;i--) 
      EmaOfEma_1[i]=iMAOnArray(Ema_1,0,period,0,MODE_EMA,i);
   for (i=limit3;i>=0;i--) 
      EmaOfEmaOfEma_1[i]=iMAOnArray(EmaOfEma_1,0,period,0,MODE_EMA,i);
   for (i=limit3;i>=0;i--) 
      TemaBuffer_1[i]=3*Ema_1[i]-3*EmaOfEma_1[i]+EmaOfEmaOfEma_1[i];
   
   if (previous==0)
      {
         return(TemaBuffer_1[0]);
      }
      
   if (previous==1)
      {
         return(TemaBuffer_1[1]);
      }    
   }
   
void GetArow(string Names, string Azimut)
   {
   ObjectCreate(Names,OBJ_LABEL,0,0,0,0,0);
   
   //установить угол привязки
   ObjectSet(Names,OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   
   //установка 
   ObjectSet(Names,OBJPROP_XDISTANCE,123);
   ObjectSet(Names,OBJPROP_YDISTANCE,4);
 
   // используем значки из шрифта Wingdings - 16 = размер
   if(Azimut == "Up")
         ObjectSetText(Names,CharToStr(236),16,"Wingdings",DodgerBlue);
         
   if(Azimut == "Down")
         ObjectSetText(Names,CharToStr(238),16,"Wingdings",Gold);

   }

//определение нового бара
bool NewBar()
{
   static datetime lastbar;
   datetime curbar = Time[0];
   if(lastbar!=curbar)
   {
      lastbar=curbar;
      return (true);
   }
   else
   {
      return(false);
   }
}

//+------------------------------------------------------------------+
