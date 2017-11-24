#ifndef MOTE_TO_MOTE_H
#define MOTE_TO_MOTE_H
typedef nx_struct MoteToMoteMsg
{
	nx_uint16_t NodeID;
	nx_uint8_t Data;
} MoteToMoteMsg_t;

enum
{
	AM_RADIO =  6
};
#endif /* MOTE_TO_MOTE_H */
