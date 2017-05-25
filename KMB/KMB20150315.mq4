//+------------------------------------------------------------------+
//|                                                          KMB.mq4 |
//|             Copyright 2014, Eddie Zhang, eddie.j.zhang@gmail.com |
//|                            http://blog.sina.com.cn/eddiejunzhang |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Eddie Zhang, eddie.j.zhang@gmail.com"
#property link      "http://blog.sina.com.cn/eddiejunzhang"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//|交易策略说明                                    |
//|以KDJ、MA和Bollingar为考查对象，以15分钟图和60分钟图为研究对象    |
//|适用于我现在的两个帐户，一个为1000美元，另一个为100美元。         |
//|权重分析方法。人为给定一个趋势建议。                              |
//|建仓采用EA自动方式，平仓采用手工方式。                            |
//|                                    |
//|2015-3-2,考虑加一个开关，从赚钱到不赚钱时，立即全部平仓           |
//|不求在一个点上下单 而在一段时间下单                               |
//+------------------------------------------------------------------+

#define MAGICMA  2015

//--- Inputs
input double   Lots=0.01;    //建仓的头寸
                             //input int      Trend            =-1;      //设定的趋势，1涨，-1跌，0震荡

//--- set constant value
long dd=10000;  //用于把价格放大10000倍，比较点差

//--- set weight value.
int wM15MA7=1,wM15MA13=2,wM15MA26=4,wM15MA52=8,wM15MA104=10,wM15MA208=12;
int wM15BOLL132U=7,wM15BOLL132L=7;
int wM15KDJ853M30=10,wM15KDJ853S30=10,wM15KDJ853M20=15,wM15KDJ853S20=15;
int wM15RSI14=0;
int wM15MA180=12,wM15MA360=10,wM15MA540=8;

int wH1MA7=2,wH1MA13=4,wH1MA26=5,wH1MA52=9,wH1MA104=13,wH1MA208=15;
int wH1BOLL132U=13,wH1BOLL132L=13;
int wH1KDJ853M30=20,wH1KDJ853S30=20,wH1KDJ853M20=30,wH1KDJ853S20=30;
int wH1RSI14=0;
int wH1MA180=15,wH1MA360=13,wH1MA540=9;

int filehandle;  //file hangle.  it contains records.
int zTotallPrev;  //前一个总的指标值。

bool   AllowPlaceLongOrder  =true;    //允许下长单
bool   AllowPlaceShortOrder =true;    //允许下短单
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer 设计时器时间间隔, the unit is SECOND.
   EventSetTimer(20);

//--- Open a file to input records.
   string subfolder="Research";
   string filename=TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES);
   filename=StringSubstr(filename,0,4)+StringSubstr(filename,5,2)
            +StringSubstr(filename,8,2)+" "+StringSubstr(filename,11,2)
            +StringSubstr(filename,14,2);
   filename="\\REC"+filename+".csv";
   filehandle=FileOpen(subfolder+filename,FILE_WRITE|FILE_CSV);
   FileWriteString(filehandle,"Time;Symbol;CurrentPrice;M15MA7;"+
                   "M15MA13;M15MA26;M15MA52;M15MA104;M15MA208;"+
                   "M15BOLL132U;M15BOLL132L;"+
                   "M15KDJ853M;M15KDJ853S;M15RSI14;M15MA180;M15MA360;M15MA540;"+
                   "H1MA7;H1MA13;H1MA26;H1MA52;H1MA104;H1MA208;"+
                   "H1BOLL132U;H1BOLL132L;H1KDJ853M;H1KDJ853S;H1RSI14;"+
                   "H1MA180;H1MA360;H1MA540;H4KDJ853M;zMA;iBOLL;zM15KDJ;zH1KDJ"+"\r\n");

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
//Close opened file
   FileClose(filehandle);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   double CurrentPrice;

   double M15MA7,M15MA13,M15MA26,M15MA52,M15MA104,M15MA208;
   double M15BOLL132U,M15BOLL132L,M15KDJ853M,M15KDJ853S,M15RSI14;
   double M15MA180,M15MA360,M15MA540;

   double H1MA7,H1MA13,H1MA26,H1MA52,H1MA104,H1MA208;
   double H1BOLL132U,H1BOLL132L,H1KDJ853M,H1KDJ853S,H1RSI14;
   double H1MA180,H1MA360,H1MA540;

   double H4KDJ853M;

//--- i开头的是指标   
   int zMA,iBOLL,zM15KDJ,zH1KDJ,zTotall;

   bool bSendNotice;

   Print("Time = ",TimeCurrent());

//--- 计算参数：均线、保利加、KDJ等
   CurrentPrice=rd((Ask+Bid)/2,5);

   M15MA7=rd(iMA(NULL,15,7,0,MODE_SMA,PRICE_CLOSE,0),5);
   M15MA13=rd(iMA(NULL,15,13,0,MODE_SMA,PRICE_CLOSE,0),5);
   M15MA26=rd(iMA(NULL,15,26,0,MODE_SMA,PRICE_CLOSE,0),5);
   M15MA52=rd(iMA(NULL,15,52,0,MODE_SMA,PRICE_CLOSE,0),5);
   M15MA104=rd(iMA(NULL,15,104,0,MODE_SMA,PRICE_CLOSE,0),5);
   M15MA208=rd(iMA(NULL,15,208,0,MODE_SMA,PRICE_CLOSE,0),5);

   M15BOLL132U=rd(iBands(NULL,15,13,2,0,PRICE_CLOSE,MODE_UPPER,0),5);
   M15BOLL132L=rd(iBands(NULL,15,13,2,0,PRICE_CLOSE,MODE_LOWER,0),5);
   M15KDJ853M=rd(iStochastic(NULL,15,8,5,3,MODE_SMA,0,MODE_MAIN,0),0);
   M15KDJ853S=rd(iStochastic(NULL,15,8,5,3,MODE_SMA,0,MODE_SIGNAL,0),0);
   M15RSI14=rd(iRSI(NULL,15,14,PRICE_CLOSE,0),0);

   M15MA180=rd(iMA(NULL,15,180,0,MODE_SMA,PRICE_CLOSE,0),5);
   M15MA360=rd(iMA(NULL,15,360,0,MODE_SMA,PRICE_CLOSE,0),5);
   M15MA540=rd(iMA(NULL,15,540,0,MODE_SMA,PRICE_CLOSE,0),5);

   H1MA7=rd(iMA(NULL,60,7,0,MODE_SMA,PRICE_CLOSE,0),5);
   H1MA13=rd(iMA(NULL,60,13,0,MODE_SMA,PRICE_CLOSE,0),5);
   H1MA26=rd(iMA(NULL,60,26,0,MODE_SMA,PRICE_CLOSE,0),5);
   H1MA52=rd(iMA(NULL,60,52,0,MODE_SMA,PRICE_CLOSE,0),5);
   H1MA104=rd(iMA(NULL,60,104,0,MODE_SMA,PRICE_CLOSE,0),5);
   H1MA208=rd(iMA(NULL,60,208,0,MODE_SMA,PRICE_CLOSE,0),5);

   H1BOLL132U=rd(iBands(NULL,60,13,2,0,PRICE_CLOSE,MODE_UPPER,0),5);
   H1BOLL132L=rd(iBands(NULL,60,13,2,0,PRICE_CLOSE,MODE_LOWER,0),5);
   H1KDJ853M=rd(iStochastic(NULL,60,8,5,3,MODE_SMA,0,MODE_MAIN,0),0);
   H1KDJ853S=rd(iStochastic(NULL,60,8,5,3,MODE_SMA,0,MODE_SIGNAL,0),0);
   H1RSI14=rd(iRSI(NULL,60,14,PRICE_CLOSE,0),0);

   H1MA180=rd(iMA(NULL,60,180,0,MODE_SMA,PRICE_CLOSE,0),5);
   H1MA360=rd(iMA(NULL,60,360,0,MODE_SMA,PRICE_CLOSE,0),5);
   H1MA540=rd(iMA(NULL,60,540,0,MODE_SMA,PRICE_CLOSE,0),5);

   H4KDJ853M=rd(iStochastic(NULL,240,8,5,3,MODE_SMA,0,MODE_MAIN,0),0);

//--- caculate weight
   zMA=0;
   if(MathAbs(CurrentPrice-M15MA7)*dd<=2) zMA=1;
   if(MathAbs(CurrentPrice-M15MA13)*dd<=2) zMA += 2;
   if(MathAbs(CurrentPrice-M15MA26)*dd<=3) zMA += 4;
   if(MathAbs(CurrentPrice-M15MA52)*dd<=4) zMA += 8;
   if(MathAbs(CurrentPrice-M15MA104)*dd<=5) zMA += 10;
   if(MathAbs(CurrentPrice-M15MA208)*dd<=6) zMA += 12;
   if(MathAbs(CurrentPrice-M15MA180)*dd<=6) zMA += 11;
   if(MathAbs(CurrentPrice-M15MA360)*dd<=10) zMA += 10;
   if(MathAbs(CurrentPrice-M15MA540)*dd<=13) zMA += 8;

   if(MathAbs(CurrentPrice-H1MA7)*dd<=2) zMA+=2;
   if(MathAbs(CurrentPrice-H1MA13)*dd<=3) zMA += 4;
   if(MathAbs(CurrentPrice-H1MA26)*dd<=4) zMA += 5;
   if(MathAbs(CurrentPrice-H1MA52)*dd<=5) zMA += 9;
   if(MathAbs(CurrentPrice-H1MA104)*dd<=6) zMA += 13;
   if(MathAbs(CurrentPrice-H1MA208)*dd<=8) zMA += 15;
   if(MathAbs(CurrentPrice-H1MA180)*dd<=7) zMA += 14;
   if(MathAbs(CurrentPrice-H1MA360)*dd<=13) zMA += 13;
   if(MathAbs(CurrentPrice-H1MA540)*dd<=17) zMA += 9;

//--- 
   iBOLL=0;
   if((CurrentPrice-M15BOLL132U)*dd>-2) iBOLL=7;
   if((CurrentPrice-M15BOLL132L)*dd<2) iBOLL=iBOLL-7;
   if((CurrentPrice-H1BOLL132U)*dd>-2) iBOLL=iBOLL+13;
   if((CurrentPrice-H1BOLL132L)*dd<2) iBOLL=iBOLL-13;

//--- 
   zM15KDJ=0;
   if(M15KDJ853M>70)
     {
      zM15KDJ=10;
      if(M15KDJ853M>80) zM15KDJ=15;
     }
   if(M15KDJ853M<30)
     {
      zM15KDJ=-10;
      if(M15KDJ853M<20) zM15KDJ=-15;
     }

   zH1KDJ=0;
   if(H1KDJ853M>70)
     {
      zH1KDJ=20;
      if(H1KDJ853M>80) zH1KDJ=30;
     }
   if(H1KDJ853M<30)
     {
      zH1KDJ=-20;
      if(H1KDJ853M<20) zH1KDJ=-30;
     }

   Print("zMA=",zMA,", iBOLL=",iBOLL,", zM15KDJ=",
         zM15KDJ,", zH1KDJ=",zH1KDJ);    // for debug.
//   Print("zM15KDJ=",zM15KDJ,", zH1KDJ=",zH1KDJ);  //for debug.
   zTotall=zMA+MathAbs(iBOLL+zM15KDJ+zH1KDJ);
   if(zTotall!=zTotallPrev)bSendNotice=true;
   Print("zTotall=",zTotall,", zTotallPrev=",zTotallPrev); // for debug
   zTotallPrev=zTotall;

//--- 在文件中记录参数
   if(filehandle!=INVALID_HANDLE)
     {
      FileWrite(filehandle,TimeCurrent(),Symbol(),CurrentPrice,M15MA7,
                M15MA13,M15MA26,M15MA52,M15MA104,M15MA208,M15BOLL132U,M15BOLL132L,
                M15KDJ853M,M15KDJ853S,M15RSI14,M15MA180,M15MA360,M15MA540,
                H1MA7,H1MA13,H1MA26,H1MA52,H1MA104,H1MA208,
                H1BOLL132U,H1BOLL132L,H1KDJ853M,H1KDJ853S,H1RSI14,
                H1MA180,H1MA360,H1MA540,H4KDJ853M,zMA,iBOLL,zM15KDJ,zH1KDJ);
     }
   else Print("File open failed, error ",GetLastError());

//--- 判断是否可以下单
//Print("Profit=",AccountProfit());
   if(AccountProfit()>-10)
     {
      AllowPlaceLongOrder=true;
      AllowPlaceShortOrder=true;
     }
   else
     {
      AllowPlaceLongOrder=false;
      AllowPlaceShortOrder=false;
      //补充一个条件，当在当前价格附近已经有一单时，则不可以再下单。
     }

//--- 长长长单 第一一一种情形
//--- 如果均线指数>5, 且保利加与KDJ指数<-15, 且已有的单子不多时下长单
   if(zMA>5 && iBOLL+zM15KDJ+zH1KDJ<-15)
     {
      // 如果此价格附近没有订单，则执行以下操作。
      if(CheckOrders())
        {
         Print("下长单的信号出现 I");
         if(AllowPlaceLongOrder && OrdersTotal()<1)
           {
            Print("允许下单 当前小于1个订单 下长单的条件出现 I");
            PlaceLongOrder();
           }
         else
           {
            //通知，出现长单交易机会I，但不允许下单。
            SendNoticeToPhone("长单机会I "+"[zMA]="+
                              DoubleToString(zMA,0)+
                              "[iBOLL+zM15KDJ+zH1KDJ]="+
                              IntegerToString(iBOLL+zM15KDJ+zH1KDJ,0));
           }
        }
     }
//--- 长长长单 第二二二种情形
//--- 如果均线指数>10, 且保利加与KDJ指数<-20, 且已有的单子不多时下长单
   else if(zMA>10 && iBOLL+zM15KDJ+zH1KDJ<-20)
     {
      // 如果此价格附近没有订单，则执行以下操作。
      if(CheckOrders())
        {
         Print("下长单的信号出现 II");
         if(AllowPlaceLongOrder && OrdersTotal()<2)
           {
            Print("允许下单 当前小于2个订单 下长单的条件出现 II");
            PlaceLongOrder();
           }
         else
           {
            //通知，出现长单交易机会I，但不允许下单。
            SendNoticeToPhone("长单机会II "+"[zMA]="+
                              DoubleToString(zMA,0)+
                              "[iBOLL+zM15KDJ+zH1KDJ]="+
                              IntegerToString(iBOLL+zM15KDJ+zH1KDJ,0));
           }
        }
     }
   else
     {
      Print("下长单的信号没有出现. ");
     }

//--- 短短短单 第一一一种情形
//--- 如果均线指数>5, 且保利加与KDJ指数>15, 且已有的单子不多时下长单
   if(zMA>5 && iBOLL+zM15KDJ+zH1KDJ>15)
     {
      // 如果此价格附近没有订单，则执行以下操作。
      if(CheckOrders())
        {
         Print("下短单的信号出现 I");
         if(AllowPlaceShortOrder && OrdersTotal()<1)
           {
            Print("允许下单 当前小于1个订单 下短单的条件出现 I");
            PlaceShortOrder();
           }
         else
           {
            //通知，出现短单交易机会，但不允许下单。
            SendNoticeToPhone("短单机会I "+"[zMA]="+
                              DoubleToString(zMA,0)+
                              "[iBOLL+zM15KDJ+zH1KDJ]="+
                              IntegerToString(iBOLL+zM15KDJ+zH1KDJ,0));
           }
        }
     }
//--- 短短短单 第二二二种情形
//--- 如果均线指数>10, 且保利加与KDJ指数>20, 且已有的单子不多时下长单
   else if(zMA>10 && iBOLL+zM15KDJ+zH1KDJ>20)
     {
      // 如果此价格附近没有订单，则执行以下操作。
      if(CheckOrders())
        {
         Print("下短单的信号出现 II");
         if(AllowPlaceShortOrder && OrdersTotal()<2)
           {
            Print("允许下单 当前小于2个订单 下短单的条件出现 II");
            PlaceShortOrder();
           }
         else
           {
            //通知，出现短单交易机会，但不允许下单。
            SendNoticeToPhone("短单机会II "+"[zMA]="+
                              DoubleToString(zMA,0)+
                              "[iBOLL+zM15KDJ+zH1KDJ]="+
                              IntegerToString(iBOLL+zM15KDJ+zH1KDJ,0));
           }
        }
     }
   else
     {
      Print("下短单的信号没有出现 ");
     }

//Print("margin=",AccountMargin()," profit=",AccountProfit());

   Print("AllowPlaceLongOrder=",AllowPlaceLongOrder,", AllowPlaceShortOrder=",AllowPlaceShortOrder);

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+
//|  圆整函数，参数：双精度值，位数                                  |
//+------------------------------------------------------------------+
double rd(double f,int d)
  {
   double a;
   a=MathPow(10,d);
   f=MathRound(f*a)/a;
   return(f);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Calculate open positions  计算当前已建仓订单数量 
// 此函数似乎无用，有可能长、短单同时存在。如果需要计算，应分成两个函数                |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
  {
   int buys=0,sells=0;
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
   Print("buys and sells = ",buys,"   ",sells);

//--- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 下长单，
//+------------------------------------------------------------------+
void PlaceLongOrder()
  {
//--- get minimum stop level
//double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   double minstoplevel=1000.0;
   Print("Minimum Stop Level=",minstoplevel," points");
   double price=Bid-0.0002;

//--- calculated SL and TP prices must be normalized
   double stoploss=NormalizeDouble(Bid-minstoplevel*Point,Digits);
   double takeprofit=NormalizeDouble(Bid+minstoplevel*Point,Digits);

//--- place market order to buy 'Lots'
   int ticket=OrderSend(Symbol(),OP_BUYLIMIT,Lots,price,3,stoploss,takeprofit,"My order",16384,0,clrGreen);
   if(ticket<0)
     {
      Print("OrderSend failed with error #",GetLastError());
     }
   else
      Print("OrderSend placed successfully");
//Call messagenotice
//---
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| 下短单，
//+------------------------------------------------------------------+
void PlaceShortOrder()
  {
//--- get minimum stop level
   double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
   Print("Minimum Stop Level=",minstoplevel," points");
   double price=Bid+0.0002;
//--- calculated SL and TP prices must be normalized
   double stoploss=NormalizeDouble(Ask+minstoplevel*Point,Digits);
   double takeprofit=NormalizeDouble(Ask-minstoplevel*Point,Digits);
//--- place market order to sell 'Lots'
   int ticket=OrderSend(Symbol(),OP_SELL,Lots,price,3,stoploss,takeprofit,"KMB order",16384,0,clrGreen);
   if(ticket<0)
     {
      Print("OrderSend failed with error #",GetLastError());
      //Call messagenotice
     }
   else
      Print("OrderSend placed successfully");
//---
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+ 检查当前价格附近是否已经有订单,没有则返回真，有则返回假
//+------------------------------------------------------------------+
bool CheckOrders()
  {
   int x;
   Print("Will CheckOrders.");
   for(x=0;x<=OrdersTotal(); x++)
     {
      Print("Before Order Select.",x);
      if(OrderSelect(x,SELECT_BY_POS)==false) continue;
      Print("Order selected.",x);
      if(MathAbs((Ask+Bid)/2-OrderOpenPrice())<45)
        {
         return(false);
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//+ 发送消息到手机上
//+------------------------------------------------------------------+
void SendNoticeToPhone(string Message)
  {
   SendNotification("["+TimeToStr(TimeCurrent(),TIME_MINUTES)+"] "+
                    DoubleToStr((Ask+Bid)/2,4)+" "+
                    Message+" ");
  }
//+------------------------------------------------------------------+
