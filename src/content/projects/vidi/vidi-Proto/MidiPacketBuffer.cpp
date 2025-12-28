//
//  MidiPacketBuffer.c
//  NetworkMIDI
//

#include "MidiPacketBuffer.h"

unsigned int midi_packet_buffer_init(struct MIDIPacketBuffer **rb, unsigned int size) {
    struct MIDIPacketBuffer *ring;
	
    if (rb == NULL || size <= 1024) {
        return 0;
    }
    
    ring = (MIDIPacketBuffer*)malloc(sizeof(struct MIDIPacketBuffer));
    if (ring == NULL) {
        // Out of memory
        return 0;
    }
    memset(ring, 0x00, sizeof(struct MIDIPacketBuffer));
	
    ring->size = 1;
    
    // Ensure the size is a power of 2
    while(ring->size <= size)
        ring->size <<= 1;
	
    ring->rd_pointer = 0;
    ring->wr_pointer = 0;
    ring->buffer = (char*)malloc(sizeof(char)*(ring->size));
    memset(ring->buffer, 0x00, ring->size);
    *rb = ring;
	
    return 1;
}

void midi_packet_buffer_uninit(struct MIDIPacketBuffer *rb) {
	if (rb != NULL) {
		free(rb->buffer);
		free(rb);
	}
}

unsigned int midi_packet_buffer_write_char(struct MIDIPacketBuffer *rb, unsigned char * buf, unsigned int len) {
    unsigned int total;
    unsigned int i;
	
    total = midi_packet_buffer_free(rb);
    if (len > total)
        len = total;
    else
        total = len;
	
    i = rb->wr_pointer;
    if (i + len > rb->size) {
        memcpy(rb->buffer + i, buf, rb->size - i);
        buf += rb->size - i;
        len -= rb->size - i;
        i = 0;
    }
    memcpy(rb->buffer + i, buf, len);
    rb->wr_pointer = i + len;
    
    return total;
}

unsigned int midi_packet_buffer_write(struct MIDIPacketBuffer *rb, const MIDIPacket* packet) {
    unsigned int total = midi_packet_buffer_write_char(rb, (unsigned char*)&(packet->length), sizeof(UInt16));
    // TODO: Timestamps are discarded here (as in this instance we want to process the packets ASAP)
    total += midi_packet_buffer_write_char(rb, (unsigned char*)(packet->data), packet->length);
    return total;
}

unsigned int midi_packet_buffer_free(struct MIDIPacketBuffer *rb) {
    return (rb->size - 1 - midi_packet_buffer_data_size(rb));
}

void midi_packet_buffer_next_packet_length(struct MIDIPacketBuffer *rb, UInt16 *length) {
    unsigned int total = midi_packet_buffer_data_size(rb);
	if (total < sizeof(UInt16))
        *length = 0x0000;
    else
        midi_packet_buffer_read(rb, (unsigned char*)length, sizeof(UInt16));
}

unsigned int midi_packet_buffer_read(struct MIDIPacketBuffer *rb, unsigned char * buf, unsigned int max) {
    unsigned int total;
    unsigned int i;
    
	total = midi_packet_buffer_data_size(rb);
	
    if(max > total)
        max = total;
    else
        total = max;
	
    i = rb->rd_pointer;
    if (i + max > rb->size) {
        memcpy(buf, rb->buffer + i, rb->size - i);
        buf += rb->size - i;
        max -= rb->size - i;
        i = 0;
    }
    memcpy(buf, rb->buffer + i, max);
    rb->rd_pointer = i + max;
	
    return total;
}

unsigned int midi_packet_buffer_data_size(struct MIDIPacketBuffer *rb) {
    return ((rb->wr_pointer - rb->rd_pointer) & (rb->size-1));
}


unsigned int midi_packet_buffer_clear(struct MIDIPacketBuffer *rb) {
    memset(rb->buffer, 0, rb->size);
    rb->rd_pointer=0;
    rb->wr_pointer=0;
	
    return 0;
}
