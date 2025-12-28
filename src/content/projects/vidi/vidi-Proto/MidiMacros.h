//
//  MidiMacros.h
//  NetworkMIDI
//

#define MIDI_GETCOMMAND(b) (Byte)((Byte)b & 0xF0)
#define MIDI_GETCHANNEL(b) (Byte)((Byte)b & 0x0F)
#define MIDI_SETCHANNEL(b, c) (Byte)(((Byte)(b & 0xF0) | (Byte)(c & 0x0F)) & (Byte)0xFF)
#define MIDI_MAKEDATA(b) (Byte)((Byte)b & 0x7F)
/*
			Note Numbers
 Octave		C	C#	D	D#	E	F	F#	G	G#	A	A#	B
	-1		0	1	2	3	4	5	6	7	8	9	10	11
	 0		12	13	14	15	16	17	18	19	20	21	22	23
	 1		24	25	26	27	28	29	30	31	32	33	34	35
	 2		36	37	38	39	40	41	42	43	44	45	46	47
	 3		48	49	50	51	52	53	54	55	56	57	58	59
	 4		60	61	62	63	64	65	66	67	68	69	70	71
	 5		72	73	74	75	76	77	78	79	80	81	82	83
	 6		84	85	86	87	88	89	90	91	92	93	94	95
	 7		96	97	98	99	100	101	102	103	104	105	106	107
	 8		108	109	110	111	112	113	114	115	116	117	118	119
	 9		120	121	122	123	124	125	126	127
*/

#define MIDI_UPONEOCTAVE(n) ((n + 0x0C) & 0x7F)
#define MIDI_DOWNONEOCTAVE(n) ((n - 0x0C) & 0x7F)
#define MIDI_OCTAVESHIFT(n, os) ((Byte)((n + (os * 0x0C)) & 0x7F))
#define MIDI_GETNOTEONLY(n) (n % 0x0C)
#define MIDI_GETOCTAVEONLY(n) (((n - (n % 0x0C)) / 0x0C) - 1)
#define MIDI_OCTAVEWITHNOTE(o, n) (((o + 1) * 0x0C) + n)

#define MIDI_MAXVELOCITY = 0x7F

#define MIDI_ISCONTROLBYTE(b) (BOOL)(((Byte)b & (Byte)0x80) > (Byte)0x00)
#define MIDI_NOTEOFF       0x80
#define MIDI_NOTEON        0x90
#define MIDI_CONTROLCHANGE 0xB0
#define MIDI_PROGRAMCHANGE 0xC0
#define MIDI_CHAN_PRESSURE 0xD0
#define MIDI_PITCHWHEEL    0xE0
#define MIDI_EXPRESSION    0x0B
#define MIDI_CHAN_VOLUME   0x07
#define MIDI_NRPN_LSB      0x62	
#define MIDI_NRPN_MSB	   0x63
#define MIDI_RPN_LSB       0x64
#define MIDI_RPN_MSB       0x65
#define MIDI_DATAENTRY_MSB 0x06

#define MIDI_CHANNELMODE  0xB0
#define MIDI_ALLNOTESOFFC 0x7B
#define MIDI_ALLNOTESOFFV 0x00

#define MIDI_GETPITCHWHEELCHANGE(lsb, msb) (((lsb & 0x7F) | ((msb & 0x7F) << 7)) - 0x2000)
#define MIDI_GETPITCHWHEELCHANGELSB(i) ((i) & 0x7F)
#define MIDI_GETPITCHWHEELCHANGEMSB(i) (((i) >> 7) & 0x7F)

#define MIDI_GETCOMMANDLENGTH(b) ((b == MIDI_PROGRAMCHANGE || b == MIDI_CHAN_PRESSURE) ? 2 : 3)

#define MIDI_GETCONTROLLERVALUE(lsb, msb) ((lsb & 0x7F) | ((msb & 0x7F) << 7))
#define MIDI_GETCONTROLLERMSB(controller) (Byte)((controller & 0x3F80) >> 7)
#define MIDI_GETCONTROLLERLSB(controller) (Byte)(controller & 0x7F)

#define MIDI_MAKENRPN(lsb, msb) (unsigned short)(((Byte)lsb & 0x7F) | (((Byte)msb & 0x7F) << 7))

#define MIDI_MMC_COMMAND_B1 0xF0
#define MIDI_MMC_COMMAND_B2 0x7F
#define MIDI_MMC_COMMAND_B4 0x06
#define MIDI_MMC_COMMAND_B6 0xF7

#define MIDI_MMC_COMMAND_STOP       0x01
#define MIDI_MMC_COMMAND_PLAY       0x02
#define MIDI_MMC_COMMAND_DEF_PLAY   0x03
#define MIDI_MMC_COMMAND_FFWD       0x04
#define MIDI_MMC_COMMAND_REW        0x05
#define MIDI_MMC_COMMAND_PUNCH_IN   0x06
#define MIDI_MMC_COMMAND_PUNCH_OUT  0x07
#define MIDI_MMC_COMMAND_PAUSE      0x09

#define MIDI_MMC_ALL_DEVICES        0x7F
