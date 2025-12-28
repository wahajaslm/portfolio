//
//  NetworkMidiController.h
//  PanScrollView
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import "MidiPacketBuffer.h"
#import <mach/semaphore.h>

#define MIDIControllerConnectionsChanged @"MIDIControllerConnectionsChanged"

#define MIDIControllerControllerValueChanged @"MIDIControllerControllerValueChanged"
#define MIDIControllerControllerValueChangedController @"MIDIControllerControllerValueChangedController"
#define MIDIControllerControllerValueChangedChannel @"MIDIControllerControllerValueChangedChannel"
#define MIDIControllerControllerValueChangedValue @"MIDIControllerControllerValueChangedValue"

#define MIDIControllerNoteChanged @"MIDIControllerNoteChanged"
#define MIDIControllerNoteChangedNote @"MIDIControllerNoteChangedNote"
#define MIDIControllerNoteChangedChannel @"MIDIControllerNoteChangedChannel"
#define MIDIControllerNoteChangedVelocity @"MIDIControllerNoteChangedVelocity"
#define MIDIControllerNoteChangedOn @"MIDIControllerNoteChangedOn"

@protocol MIDIReceivedDelegate <NSObject>

- (void) midiControllerUpdated:(Byte)controller onChannel:(Byte)channel toValue:(Byte)value;
- (void) midiNoteOnOff:(Byte)note onChannel:(Byte)channel withVelocity:(Byte)velocity on:(BOOL)on;

@end


@interface NetworkMidiController : NSObject<NSNetServiceBrowserDelegate, NSNetServiceDelegate>
{
    
    __strong NSNetServiceBrowser *browser;
    MIDIClientRef client;
    MIDIPortRef inputPort;
    MIDIPortRef outputPort;
    
    __strong NSMutableDictionary *services;
    
@public
    semaphore_t midiReceivedSemaphore;
    MIDIPacketBuffer *midiPacketBuffer;
}

@property (nonatomic, readonly) NSMutableDictionary * services;
@property (nonatomic, weak) id<MIDIReceivedDelegate> delegate;

+ (NetworkMidiController *) sharedInstance;

- (BOOL)connected;

- (void)allNotesOffOnChannel:(NSUInteger)channel;
- (void)sendChangeForController:(NSUInteger)controller onChannel:(NSUInteger)channel withValue:(NSUInteger)value;
- (void)sendNote:(NSUInteger)note on:(BOOL)on onChannel:(NSUInteger)channel withVelocity:(NSUInteger)velocity;
- (void)sendMMCCommand:(NSUInteger)command toDevice:(NSUInteger)device;
- (void)sendChangeForPitchWheel:(NSUInteger)PitchWheel onChannel:(NSUInteger)channel withValue:(UInt16)value;

- (NSString *)describeConnections;
- (BOOL)isConnected:(NSNetService *)service;
- (void)toggleConnected:(NSNetService *)service;


@end
