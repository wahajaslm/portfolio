//
//  NetworkMidiController.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 21/05/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//


#import <mach/mach_time.h>
#import <mach/mach.h>
#import <mach/task.h>
#import "MidiMacros.h"
#import "NetworkMidiController.h"

@implementation NetworkMidiController

@synthesize services,delegate;

static NetworkMidiController* sharedInstance=nil;


static void MIDIClientNotifyProc(const MIDINotification *message, void *refCon);

#pragma mark - Lifecycle

+ (NetworkMidiController*) sharedInstance {
    @synchronized (self) {
        if (!sharedInstance) {
            sharedInstance = [[NetworkMidiController alloc] init];
        }
    }
    return sharedInstance;
}

- (id) init
{
    if (self = [super init])
        {
            midi_packet_buffer_init(&(midiPacketBuffer), 0x10000);
        }
    
    else
    
        {
            midiPacketBuffer = NULL;
            DLog(@"Unable to create the semaphore - MIDI input will not be connected!");
        }
     
        
        
        /*Services As NSmutable array objects*/
        services = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    
        /*Setting up Midi Network Sesion*/
        [MIDINetworkSession defaultSession].enabled = YES;
        [MIDINetworkSession defaultSession].connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
    
    
    
        /*Setting up Midi Client and Port*/
        OSStatus status = MIDIClientCreate(CFSTR("NetworkMIDI MIDI Client"), MIDIClientNotifyProc, (__bridge void *)(self), &client);
        if (status == noErr)
        {
            status = MIDIOutputPortCreate(client, CFSTR("NetworkMIDI Output Port"), &outputPort);
            
            if (status == noErr)
            {
       //         status = MIDIInputPortCreate(client, CFSTR("NetworkMIDI Input Port"), MIDIInputReadProc, (__bridge void *)(self), &inputPort);
                // Only connect the source if we successfully created the semaphore and buffer above
                if (status == noErr && midiPacketBuffer)
                {
         //           status = MIDIPortConnectSource(inputPort, [[MIDINetworkSession defaultSession] sourceEndpoint], (__bridge void *)(self));
                }
                
                if (status == noErr) {
                    DLog(@"Created midi client and ports.");
                }
            }
        }
        
        if (status != noErr) {
            DLog(@"Couldn't create midi client and ports...");
        }
    
    
    
        /*Setting NetService Browser*/
        browser = [[NSNetServiceBrowser alloc] init];
        browser.delegate = self;
        [browser searchForServicesOfType:MIDINetworkBonjourServiceType /* i.e. @"_apple-midi._udp"*/
                                inDomain:@""];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(midiNetworkSessionUpdated:)
                                                     name:MIDINetworkNotificationSessionDidChange
                                                   object:[MIDINetworkSession defaultSession]];
    
    return self;
}



#pragma mark - Connection management

- (void) midiNetworkSessionUpdated:(NSNotification*) notification {
    // DLog(@"Session updated: %@", notification);
    [[NSNotificationCenter defaultCenter] postNotificationName:MIDIControllerConnectionsChanged object:self];
}

- (BOOL) connected {
    return  [[[MIDINetworkSession defaultSession] connections] count] > 0;
}

- (NSString*) describeConnections {
    NSMutableArray* connections = [NSMutableArray arrayWithCapacity:[[[MIDINetworkSession defaultSession] connections] count]];
    
    for (MIDINetworkConnection* connection in [[MIDINetworkSession defaultSession] connections])
    {
        [connections addObject:[[connection host] name]];
    }
    
    if ([connections count] > 0) {
        return [connections componentsJoinedByString:@", "];
    }
    else
        return @"(Not connected)";
}

- (BOOL) isConnected:(NSNetService*) service {
  
    for (MIDINetworkConnection* connection in [[MIDINetworkSession defaultSession] connections])
    {
        DLog(@"Name: %@ net service name: %@ service name: %@", [[connection host] name], [[connection host] netServiceName], [service name]);
       
        if ([[connection host] netServiceName] != nil)
        {
            if ([[[connection host] netServiceName] isEqualToString:[service name]])
                return YES;
        }
        else if ([[[connection host] name]isEqualToString:[service name]])
            return YES;
        
    }
    
    return NO;
}


- (void) connectToService:(NSNetService*) service {
    MIDINetworkHost* host = [MIDINetworkHost hostWithName:[service name] netService:service];
    MIDINetworkConnection* newConnection = [MIDINetworkConnection connectionWithHost:host];
    [[MIDINetworkSession defaultSession] addConnection:newConnection];
   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MidiEndPointRefForSequence" object:nil];
  
    DLog(@"Connected to %@", [service name]);
}


- (void) toggleConnected:(NSNetService*) service {
    if ([self isConnected:service])
    {
        for (MIDINetworkConnection* connection in [[MIDINetworkSession defaultSession] connections])
        {
            DLog(@"Name: %@ net service name: %@ service name: %@", [[connection host] name], [[connection host] netServiceName], [service name]);
            if ([[connection host] netServiceName] != nil)
            {
                if ([[[connection host] netServiceName] isEqualToString:[service name]])
                {
                    [[MIDINetworkSession defaultSession] removeConnection:connection];
                    break;
                }
            }
            else
            {
                if ([[[connection host] name]isEqualToString:[service name]])
                {
                    [[MIDINetworkSession defaultSession] removeConnection:connection];
                    break;
                }
            }
        }
        
         [[NSNotificationCenter defaultCenter] postNotificationName:@"MidiEndPointRefForSequenceRemove" object:nil];
    }
    else
    {
        if ([service hostName])
        {
            // If it's already been resolved we can just add it
            [self connectToService:service];
        }
        else
        {
            // Otherwise resolve it
            [service setDelegate:self];
            [service resolveWithTimeout:10.0];
        }
    }
}






#pragma mark - NSNetServiceBrowserDelegate

-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)aService moreComing:(BOOL)more {
    DLog(@"Found service %@ on %@", [aService name], [aService hostName]);
    
    // Filter out local services
    if (![[aService name] isEqualToString:[[UIDevice currentDevice] name]])
    {
        [services setValue:aService forKey:[aService name]];
    }
}
-(void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)aService moreComing:(BOOL)more {
    DLog(@"Removing service %@", [aService name]);
    [services removeObjectForKey:[aService name]];
}

- (void) netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    DLog(@"Browser stopped.");
}





#pragma mark - NSNetServiceDelegate

-(void)netServiceDidResolveAddress:(NSNetService *)service {
    [service setDelegate:nil];
    DLog(@"Resolved service name: %@ host name: %@", [service name], [service hostName]);
    [self connectToService:service];
}

-(void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    [service setDelegate:nil];
    DLog(@"Could not resolve: %@", errorDict);
}

- (void)netServiceDidStop:(NSNetService *)service {
    [service setDelegate:nil];
    DLog(@"Service stopped: %@", [service name]);
}



#pragma mark - Internal MIDI stuff

static void MIDIClientNotifyProc(const MIDINotification *message, void *refCon) {
    // This just logs the changes; add any necessary processing here
    switch (message->messageID) {
        case kMIDIMsgSetupChanged:
            DLog(@"MIDI setup changed");
            break;
        case kMIDIMsgObjectAdded:
        {
            MIDIObjectAddRemoveNotification* addRemoveMessage = (MIDIObjectAddRemoveNotification*)message ;
            if (addRemoveMessage->childType == kMIDIObjectType_Source) {
                DLog(@"MIDI source added.");
            }
            if (addRemoveMessage->childType == kMIDIObjectType_Destination) {
                DLog(@"MIDI destination added.");
            }
        }
            break;
        case kMIDIMsgObjectRemoved:
        {
            MIDIObjectAddRemoveNotification* addRemoveMessage = (MIDIObjectAddRemoveNotification*)message ;
            if (addRemoveMessage->childType == kMIDIObjectType_Source) {
                DLog(@"MIDI source removed.");
            }
            if (addRemoveMessage->childType == kMIDIObjectType_Destination) {
                DLog(@"MIDI destination added.");
            }
        }
            break;
        case kMIDIMsgPropertyChanged:
        {
            MIDIObjectPropertyChangeNotification* propertyChangeMessage = (MIDIObjectPropertyChangeNotification*)message;
            if (propertyChangeMessage->propertyName)
                DLog(@"MIDI property %@ changed.", propertyChangeMessage->propertyName);
        }
            break;
        case kMIDIMsgThruConnectionsChanged:
            DLog(@"MIDI thru connections changed.");
            break;
        case kMIDIMsgSerialPortOwnerChanged:
            DLog(@"MIDI serial port owner changed.");
            break;
        case kMIDIMsgIOError:
            DLog(@"MIDI I/O error.");
            break;
    }
}

-(void) midiControllerUpdated:(Byte)controller onChannel:(Byte)channel toValue:(Byte)value {
    NSDictionary* details = @{MIDIControllerControllerValueChangedController: [NSNumber numberWithUnsignedInt:controller],
                              MIDIControllerControllerValueChangedChannel: [NSNumber numberWithUnsignedInt:channel],
                              MIDIControllerControllerValueChangedValue: [NSNumber numberWithUnsignedInt:value]};
    [[NSNotificationCenter defaultCenter] postNotificationName:MIDIControllerControllerValueChanged
                                                        object:self
                                                      userInfo:details];
}

- (void) midiNoteOnOff:(Byte)note onChannel:(Byte)channel withVelocity:(Byte)velocity on:(BOOL)on {
    NSDictionary* details = @{MIDIControllerNoteChangedNote: [NSNumber numberWithUnsignedInt:note],
                              MIDIControllerNoteChangedChannel: [NSNumber numberWithUnsignedInt:channel],
                              MIDIControllerNoteChangedVelocity: [NSNumber numberWithUnsignedInt:velocity],
                              MIDIControllerNoteChangedOn: @(on)};
    [[NSNotificationCenter defaultCenter] postNotificationName:MIDIControllerNoteChanged
                                                        object:self
                                                      userInfo:details];
}



-(void) writeMidiPacket:(Byte*)packet withLength:(Byte)packetLength {
	if (packetLength <= 0x00 || packet == NULL)
		return;
    
    @synchronized (self) {
        static UInt32 packetListBuffer[0x4000];
        MIDIPacketList *outputPacketList = (MIDIPacketList *)packetListBuffer;
        MIDIPacket *lastOutputPacket = MIDIPacketListInit(outputPacketList);
        
        unsigned int numberOfPackets = 0;
        
        lastOutputPacket = MIDIPacketListAdd(outputPacketList, sizeof packetListBuffer, lastOutputPacket,
                                             (MIDITimeStamp)mach_absolute_time(), packetLength, packet);
        if (lastOutputPacket != NULL) {
            lastOutputPacket->length = packetLength;
            outputPacketList->numPackets = ++numberOfPackets;
        }
        
        MIDISend(outputPort, [[MIDINetworkSession defaultSession] destinationEndpoint], outputPacketList);
	}
    
}

- (void) writeMidiPacket:(Byte *)packet withLength:(Byte)packetLength toChannel:(Byte)selectedChannel
{
	if (packetLength <= 0x00 || packet == NULL)
		return;
    
    @synchronized (self) {
        static UInt32 packetListBuffer[0x4000];
        static UInt32 buffer[0x100];
        Byte *bufferPtr = (Byte *)buffer;
        MIDIPacketList *outputPacketList = (MIDIPacketList *)packetListBuffer;
        MIDIPacket *lastOutputPacket = MIDIPacketListInit(outputPacketList);
        
        unsigned int outputPacketContentsIndex = 0;
        unsigned int packetContentsIndex = 0;
        unsigned int numberOfPackets = 0;
        
        while (packetContentsIndex < packetLength) {
            // Rechannelize commands
            if (MIDI_ISCONTROLBYTE(packet[packetContentsIndex])) {
                Byte command = MIDI_GETCOMMAND(packet[packetContentsIndex]);
                Byte commandLength = MIDI_GETCOMMANDLENGTH(command);
                bufferPtr[outputPacketContentsIndex++] = MIDI_SETCHANNEL(command, selectedChannel);
                unsigned int commandStart = packetContentsIndex;
                for (int commandOffset = 1; commandOffset < commandLength; commandOffset++) {
                    bufferPtr[outputPacketContentsIndex++] = packet[commandStart + commandOffset];
                }
                packetContentsIndex = commandStart + commandLength;
            }
            else {
                // Junk data - skip to next command
                DLog(@"%x!", packet[packetContentsIndex]);
                packetContentsIndex++;
            }
        }
        
        if (outputPacketContentsIndex > 0) {
            lastOutputPacket = MIDIPacketListAdd(outputPacketList, sizeof packetListBuffer, lastOutputPacket,
                                                 (MIDITimeStamp)mach_absolute_time(), outputPacketContentsIndex, bufferPtr);
            if (lastOutputPacket != NULL) {
                lastOutputPacket->length = (Byte)outputPacketContentsIndex;
                outputPacketList->numPackets = ++numberOfPackets;
            }
            
            MIDISend(outputPort, [[MIDINetworkSession defaultSession] destinationEndpoint], outputPacketList);
		}
	}
}

#pragma mark - Sending

-(void) allNotesOffOnChannel:(NSUInteger)channel
{
	Byte channelModeNotesOff[0x03] = {MIDI_CHANNELMODE, MIDI_ALLNOTESOFFC, MIDI_ALLNOTESOFFV};
	[self writeMidiPacket:channelModeNotesOff withLength:0x03 toChannel:(Byte)(channel & 0x0F)];
}

- (void) sendChangeForController:(NSUInteger)controller onChannel:(NSUInteger)channel withValue:(NSUInteger)value
{
    Byte lsbControllerChange[0x03] = {MIDI_CONTROLCHANGE, (Byte)(controller & 0xFF), (Byte)(value & 0x7F)};
    [self writeMidiPacket:lsbControllerChange withLength:3 toChannel:channel];
}

- (void)sendChangeForPitchWheel:(NSUInteger)PitchWheel onChannel:(NSUInteger)channel withValue:(UInt16)value
{
    Byte lsbControllerChange[0x03] = {MIDI_PITCHWHEEL, (Byte)MIDI_GETPITCHWHEELCHANGELSB(value), (Byte)MIDI_GETPITCHWHEELCHANGEMSB(value)};
    [self writeMidiPacket:lsbControllerChange withLength:3 toChannel:channel];
}

- (void) sendNote:(NSUInteger)note on:(BOOL)on onChannel:(NSUInteger)channel withVelocity:(NSUInteger)velocity
{
    if (on) {
        Byte noteOn[0x03] = {MIDI_NOTEON, MIDI_MAKEDATA(note), MIDI_MAKEDATA(velocity)};
        [self writeMidiPacket:noteOn withLength:0x03 toChannel:MIDI_GETCHANNEL(channel)];
    }
    else {
        Byte noteOff[0x03] = {MIDI_NOTEOFF, MIDI_MAKEDATA(note), MIDI_MAKEDATA(velocity)};
        [self writeMidiPacket:noteOff withLength:0x03 toChannel:MIDI_GETCHANNEL(channel)];
    }          
}

- (void) sendMMCCommand:(NSUInteger)command toDevice:(NSUInteger)device
{
    // F0 7F {deviceID} 06 {command} F7
    Byte mmcCommand[0x06] = {0xF0, 0x7F, (Byte)(device & 0xFF), 0x06, (Byte)(command & 0xFF), 0xF7};
    [self writeMidiPacket:mmcCommand withLength:0x06];
}



- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    semaphore_destroy(mach_task_self(), midiReceivedSemaphore);
    
    if (inputPort)
        MIDIPortDispose(inputPort);
    inputPort = NULL;
    if (outputPort)
        MIDIPortDispose(outputPort);
    outputPort = NULL;
    if (client)
        MIDIClientDispose(client);
    client = NULL;
    
    browser = nil;
    services = nil;
    
    midi_packet_buffer_uninit(midiPacketBuffer);
}





@end
