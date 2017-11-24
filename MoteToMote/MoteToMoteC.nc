#include<UserButton.h>
#include"MoteToMote.h"
module MoteToMoteC
{
	//general interface
	uses 
	{
		interface Boot;
		interface Leds;
	}
	//Button interface
	uses
	{
		interface Get<button_state_t>;
		interface Notify<button_state_t>;
	}
	//MoteToMote interface
	uses
	{
		interface Packet;
		interface AMPacket;
		interface AMSend;
		interface SplitControl as AMControl;
		interface Receive;
			
	}
	
}
implementation
{
	bool _radioBusy = FALSE;
	message_t _packet;

	event void Notify.notify(button_state_t val)
	{
		if (_radioBusy == FALSE)
		{
			//create packet 
			MoteToMoteMsg_t *msg = call Packet.getPayload(& _packet, sizeof(MoteToMoteMsg_t));
			msg->NodeID = TOS_NODE_ID;
			msg->Data = (uint8_t)val;
			
			//send packet
			if (call AMSend.send(AM_BROADCAST_ADDR, &_packet,sizeof(MoteToMoteMsg_t)) == SUCCESS)
			{
				_radioBusy = TRUE;
			}
			
		}
	}

	event void Boot.booted()
	{
		call Notify.enable();
		call AMControl.start();
	}

	event void AMSend.sendDone(message_t *msg, error_t error)
	{
		if (msg == &_packet)
		{
			_radioBusy = FALSE;
		}
		
	}

	event void AMControl.startDone(error_t error)
	{
		if (error == SUCCESS)
		{
			call Leds.led0On();
		}
	}

	event message_t * Receive.receive(message_t *msg, void *payload, uint8_t len)
	{
		if (len == sizeof (MoteToMoteMsg_t))
		{
			MoteToMoteMsg_t *incomingpkt = (MoteToMoteMsg_t *) payload;
			uint8_t Data = incomingpkt -> Data;
			if (Data == 1)
			{
				call Leds.led2Toggle();
			}
			
		}
		return msg;
	}

	event void AMControl.stopDone(error_t error)
	{
		
	}
}
