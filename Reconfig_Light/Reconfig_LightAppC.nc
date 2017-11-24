configuration Reconfig_LightAppC{
	
}
implementation{
	  components Reconfig_LightC, MainC, LedsC, ActiveMessageC;
	  components CollectionC as Collector;
	  components new CollectionSenderC(0xee);
	  components new TimerMilliC();
	  components DelugeC;
	  components SerialPrintfC;
	  //components new SensirionSht11C() as TempSensor;
	  //EasyCollectionC.TempRead -> TempSensor.Temperature;
	  //EasyCollectionC.HumRead -> TempSensor.Humidity;
	  components new HamamatsuS10871TsrC() as Lightsenser;  // Total Solar Radiation  
	  Reconfig_LightC.LightRead -> Lightsenser;
	  Reconfig_LightC.Boot -> MainC;
	  Reconfig_LightC.RadioControl -> ActiveMessageC;
	  Reconfig_LightC.RoutingControl -> Collector;
	  Reconfig_LightC.Leds -> LedsC;
	  Reconfig_LightC.Timer -> TimerMilliC;
	  Reconfig_LightC.Send -> CollectionSenderC;
	  Reconfig_LightC.RootControl -> Collector;
	  Reconfig_LightC.Receive -> Collector.Receive[0xee];
}