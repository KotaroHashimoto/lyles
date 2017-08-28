#property version   "1.00"
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>

extern bool    closeOnOpposite=true;//Do you want to close on opposite signal?
extern int     fastMa=9;//Fast MA period
extern int     slowMa=100;//Slow MA period
extern bool    useTrailing=false;//Do you want to use trailing stop loss?
extern int     trailAmount=30;//Trailing amount
extern double  stopLoss=30;//Stop loss
extern double  takeProfit=30;//Take profit
extern double  lotSize=0.1;//Lot size
extern double  lotDelta = 0.1;//Lot delta
extern int     magicSeed=1234;//MagicNumber seed
double pips;
int    magic;

double minLot;
double maxLot;

double lastEquity;

int OnInit()
{
   magic = magicNumberGenerator();
   pips =Point; 
   if(Digits==3||Digits==5)
      pips*=10;

   minLot = MarketInfo(Symbol(), MODE_MINLOT);
   maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   
   lastEquity = AccountEquity();
   
   //#include<InitChecks.mqh>
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   
}

void OnTick()
{
   static datetime candleTime=Time[0];
   if(useTrailing && totalOpenOrders()>0) adjustTrail();
   
   if(candleTime!=Time[0]){
      if(totalOpenOrders()<1) 
         checkForSignal(); 
      
      candleTime=Time[0]; 
   }
}
  
void checkForSignal()
{
   double fast = iMA(NULL,0,fastMa,0,MODE_EMA,PRICE_CLOSE,1);
   double fastP = iMA(NULL,0,fastMa,0,MODE_EMA,PRICE_CLOSE,2);
   double slow = iMA(NULL,0,slowMa,0,MODE_EMA,PRICE_CLOSE,1);
   double slowP = iMA(NULL,0,slowMa,0,MODE_EMA,PRICE_CLOSE,2);
   Comment(fast+" \n "+fastP+" \n "+slow+"  \n "+slowP);
   
   if(fast>slow && fastP<slowP){
      if(closeOnOpposite) closeAll();
      enterTrade(OP_BUY);
   }
   
   else if(fast<slow && fastP>slowP){
      if(closeOnOpposite) closeAll();
      enterTrade(OP_SELL);
   }
}

void enterTrade(int type){

   int err=0;
   double price=Bid,
          sl=0, 
          tp=0, 
          lotsize = lotSize;
                    
   type = (type == OP_BUY) ? OP_SELL : OP_BUY;

   double eq = AccountEquity();
   if(lastEquity == eq) {
     // do nothing
   }
   else if(lastEquity < eq) {
     lotDelta = -1.0 * MathAbs(lotDelta);
     lotSize += lotDelta;
   }
   else {
     lotDelta = MathAbs(lotDelta);
     lotSize += lotDelta;
   }            
   
   lotsize = lotSize;
   
   if(maxLot < lotSize) {
     lotSize = maxLot;
     lotsize = maxLot;
     Print("Lot size(", lotsize, ") is larger than max(", maxLot, "). Rounded to ", maxLot, ".");
   }
   else if(lotSize < minLot) {
     lotSize = minLot;
     lotsize = minLot;
     Print("Lot size(", lotsize, ") is smaller than min(", minLot, "). Rounded to ", minLot, ".");
   }
   
          
   if(type == OP_BUY)
      price =Ask;
   
   lastEquity = eq;
   int ticket = OrderSend(Symbol(),type,lotsize,price,30,0,0,"EaTemplate",magic,0,Magenta); 
   if(ticket>0)
   {
      if(OrderSelect(ticket,SELECT_BY_TICKET))
      {
         sl = OrderOpenPrice()+(stopLoss*pips);
         if(stopLoss==0)sl=0;
         tp = OrderOpenPrice()-(takeProfit*pips);
         if(OrderType()==OP_BUY)
         {
            sl = OrderOpenPrice()-(stopLoss*pips);
            if(stopLoss==0)sl=0;
            tp = OrderOpenPrice()+(takeProfit*pips);
         }
         if(!OrderModify(ticket,price,sl,tp,0,Magenta)) 
         {
            err = GetLastError();
            Print("Encountered an error during modification!"+(string)err+" "+ErrorDescription(err)  );
         }
      }
      else
      {
         Print("Failed to Select Order ",ticket);
         err = GetLastError();
         Print("Encountered an error while seleting order "+(string)ticket+" error number "+(string)err+" "+ErrorDescription(err)  );
      }
   }
   else
   {
      err = GetLastError();
      Print("Encountered an error during order placement!"+(string)err+" "+ErrorDescription(err)  );
      if(err==ERR_TRADE_NOT_ALLOWED)MessageBox("You can not place a trade because \"Allow Live Trading\" is not checked in your options. Please check the \"Allow Live Trading\" Box!","Check Your Settings!");
   }
}

int magicNumberGenerator()
{
  	string mySymbol = StringSubstr(_Symbol,0,6);
   int pairNumber=0;
   int GeneratedNumber =0;   	
	     if (mySymbol == "AUDCAD") 	pairNumber=1;
	else if (mySymbol == "AUDCHF") 	pairNumber=2;
	else if (mySymbol == "AUDJPY") 	pairNumber=3;
	else if (mySymbol == "AUDNZD") 	pairNumber=4;
	else if (mySymbol == "AUDUSD") 	pairNumber=5;
	else if (mySymbol == "CADCHF") 	pairNumber=6;
	else if (mySymbol == "CADJPY") 	pairNumber=7;
	else if (mySymbol == "CHFJPY") 	pairNumber=8;
	else if (mySymbol == "EURAUD") 	pairNumber=9;
	else if (mySymbol == "EURCAD") 	pairNumber=10;
	else if (mySymbol == "EURCHF") 	pairNumber=11;
	else if (mySymbol == "EURGBP") 	pairNumber=12;
	else if (mySymbol == "EURJPY") 	pairNumber=13;
	else if (mySymbol == "EURNZD") 	pairNumber=14;
	else if (mySymbol == "EURUSD") 	pairNumber=15;
	else if (mySymbol == "GBPAUD") 	pairNumber=16;
	else if (mySymbol == "GBPCAD") 	pairNumber=17;
	else if (mySymbol == "GBPCHF") 	pairNumber=18;
	else if (mySymbol == "GBPJPY") 	pairNumber=19;
	else if (mySymbol == "GBPNZD") 	pairNumber=20;
	else if (mySymbol == "GBPUSD") 	pairNumber=21;
	else if (mySymbol == "NZDCAD") 	pairNumber=22;
	else if (mySymbol == "NZDJPY") 	pairNumber=23;
	else if (mySymbol == "NZDCHF") 	pairNumber=24;
	else if (mySymbol == "NZDUSD") 	pairNumber=25;
	else if (mySymbol == "USDCAD") 	pairNumber=26;
	else if (mySymbol == "USDCHF") 	pairNumber=27;
	else if (mySymbol == "USDJPY")	pairNumber=28;
	GeneratedNumber = magicSeed + (pairNumber*100) + _Period;
	return(GeneratedNumber);
}

int totalOpenOrders()
{
  int total=0;
   for(int i=OrdersTotal()-1; i >= 0; i--)
	  {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderMagicNumber()== magic)
            total++;
	   else Print("Failed to select order",GetLastError());
	  }
   return (total);
}

void adjustTrail(){
   for(int i=OrdersTotal(); i>=0; i--){
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if(OrderMagicNumber() == magic)
            if(OrderType() == OP_BUY){
                  if(OrderStopLoss() < Bid-trailAmount*pips)
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-(trailAmount*pips),OrderTakeProfit(),0,CLR_NONE)){
                        int err = GetLastError();
                        Print("Encountered an error during order selection in: "+ __FUNCTION__+"!"+(string)err+" "+ErrorDescription(err)  );
                     }
            }
            else if(OrderType()==OP_SELL)
                  if(OrderStopLoss() > Ask + trailAmount*pips)
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(trailAmount*pips),OrderTakeProfit(),0,CLR_NONE)){
                        int err = GetLastError();
                        Print("Encountered an error during order selection in: "+ __FUNCTION__+"!"+(string)err+" "+ErrorDescription(err)  );
                     }
      }
      else
      {
         int err = GetLastError();
         Print("Encountered an error during order selection in: "+ __FUNCTION__+"!"+(string)err+" "+ErrorDescription(err)  );
      }
   }
}

void closeAll(){
   double closePrice=Bid;
   int err=0;
   
   for(int i=OrdersTotal()-1; i >= 0; i--)
	{
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if(OrderMagicNumber()== magic){
            if(OrderType()==OP_BUY)
               closePrice=Bid;
            else if(OrderType()==OP_SELL)
               closePrice=Ask;
               
            if(!OrderClose(OrderTicket(),OrderLots(),closePrice,3,clrNONE)){
               err = GetLastError();
               Print("Encountered an error during closing!"+(string)OrderTicket()+" ,"+(string)err+" "+ErrorDescription(err));
            }
         }
      }
      else
      {
         Print("Failed to Select Order.");
         err = GetLastError();
         Print("Encountered an error while seleting order ,error number "+(string)err+" "+ErrorDescription(err));
      }
	}
}
