configuration MoteToMoteAppC{
}
implementation{
	//general components
	components MoteToMoteC as App;
	components MainC;
	components LedsC;
	
	App.Boot -> MainC;
	App.Leds -> LedsC;
	//user button
	components UserButtonC;
	App.Get -> UserButtonC;
	App.Notify->UserButtonC;
	
	//radio communication
	components ActiveMessageC;
	components new AMSenderC(AM_RADIO);
	components new AMReceiverC(AM_RADIO);
	
	App.Packet -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.AMSend-> AMSenderC;
	App.Receive->AMReceiverC;
	
	components DelugeC;
	
}
