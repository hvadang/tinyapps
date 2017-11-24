#include<Timer.h>
#include<stdio.h>
module Reconfig_LightC{
	uses interface Boot;
	uses interface SplitControl as RadioControl;
	uses interface StdControl as RoutingControl;
	uses interface Send;
	uses interface Leds;
	uses interface Timer<TMilli>;
	uses interface RootControl;
	uses interface Receive;
	//uses interface Read<uint16_t> as TempRead;
	//uses interface Read<uint16_t> as HumRead;
	uses interface Read<uint16_t> as LightRead;
}
implementation{
  void printfFloat(float toBePrinted);
  message_t packet;
  bool sendBusy = FALSE;
  //float centiGrade;
  float light;
  //float huminity;
  
  
  typedef nx_struct EasyCollectionMsg {
    //nx_float datatemp;
    nx_float datalight;
    //nx_float datahumidity;
    nx_uint16_t NodeID;
  } EasyCollectionMsg;

  event void Boot.booted() {
    call RadioControl.start();
  }
  void sendMessage();
  
  event void RadioControl.startDone(error_t err) {
    if (err != SUCCESS)
      call RadioControl.start();
    else {
      call RoutingControl.start();
      if (TOS_NODE_ID == 1) 
	call RootControl.setRoot();
      else
	call Timer.startPeriodic(5000);
    }
  }

  event void RadioControl.stopDone(error_t err) {}
//  event void TempRead.readDone(error_t result, uint16_t val){
//		centiGrade=val;
//  }
  event void LightRead.readDone(error_t result, uint16_t val){
		light=val;	
  }
  
//  event void HumRead.readDone(error_t result, uint16_t val){
//		huminity=val;
//  }
  void sendMessage(){
    EasyCollectionMsg* msg =(EasyCollectionMsg*)call Send.getPayload(&packet, sizeof(EasyCollectionMsg));
    //msg->datatemp = centiGrade;
    msg->datalight = light;
   // msg->datahumidity = huminity;
    msg->NodeID = TOS_NODE_ID;
    if (call Send.send(&packet, sizeof(EasyCollectionMsg)) != SUCCESS) 
      call Leds.led0On();
    else 
      sendBusy = TRUE;
  }

  event void Timer.fired() {
    call Leds.led2Toggle();
    if (!sendBusy)
    //call TempRead.read();
    call LightRead.read();
   // call HumRead.read();
      	sendMessage();
  }
  
  event void Send.sendDone(message_t* m, error_t err) {
    if (err != SUCCESS) 
      call Leds.led0On();
    sendBusy = FALSE;
  }
  
  event message_t* 
  Receive.receive(message_t* msg, void* payload, uint8_t len) {
  	EasyCollectionMsg *incoming = (EasyCollectionMsg *) payload;
  	//double dbcent = -39.6 + 0.01*(incoming -> datatemp) - 2;
  	double dbligh = 0.769*100000*((incoming -> datalight/4096)*1.5)*0.00001*1000;
  	//double humi = incoming -> datahumidity;
  	//double fTemHumi = -2.0468 + 0.0367*humi - 1.5955*0.000001*humi*humi;
  	//double dbhum = (dbcent - 25)*(0.01 + 0.00008*humi) + fTemHumi;
  	//uint8_t ligh = incoming -> datalight;
  	//uint8_t humi = incoming -> datahumidity;
  	
  	printf("%d",incoming -> NodeID);
  	//printfFloat(dbcent);
  	//printf(" ");
  	printfFloat(dbligh);
  	//printf(" ");
  	//printfFloat(dbhum);
	printf(" \r\n");
    call Leds.led1Toggle();    
    return msg;
  }
	void printfFloat(float toBePrinted) {
     uint32_t fi, f0, f1;
     char c;
     float f = toBePrinted;

     if (f<0){
       c = '-'; f = -f;
     } else {
       c = ' ';
     }

     // integer portion.
     fi = (uint32_t) f;

     // decimal portion...get index for up to 3 decimal places.
     f = f - ((float) fi);
     f0 = f*10;   f0 %= 10;
     f1 = f*100;  f1 %= 10;
     printf("%c%ld.%d%d", c, fi, (uint8_t) f0, (uint8_t) f1);
   }
}
