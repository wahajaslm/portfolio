//
//  MIDIPacketBuffer.h
//  NetworkMIDI
//


#ifndef __MIDI_RINGBUFFER_H__
#define __MIDI_RINGBUFFER_H__

#import <CoreMIDI/CoreMIDI.h>

#define MIDI_RINGBUFFER_MAGIC  0x4D627546    /* 'MbuF' */
#define midi_packet_buffer_magic_check(var, err)  { if (var->magic != MIDI_RINGBUFFER_MAGIC) return err; }

typedef struct MIDIPacketBuffer {
    char *buffer;
    unsigned int wr_pointer;
    unsigned int rd_pointer;
    long magic;
    unsigned int size;
} MIDIPacketBuffer;


unsigned int midi_packet_buffer_init(struct MIDIPacketBuffer **, unsigned int);

void midi_packet_buffer_uninit(struct MIDIPacketBuffer *);

unsigned int midi_packet_buffer_write(struct MIDIPacketBuffer *, const MIDIPacket*);

unsigned int midi_packet_buffer_free(struct MIDIPacketBuffer *);

void midi_packet_buffer_next_packet_length(struct MIDIPacketBuffer *rb, UInt16 *);

unsigned int midi_packet_buffer_read(struct MIDIPacketBuffer *, unsigned char *, unsigned int);

unsigned int midi_packet_buffer_data_size(struct MIDIPacketBuffer *);

unsigned int midi_packet_buffer_clear(struct MIDIPacketBuffer *);

#endif

