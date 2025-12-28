//
//  ApplicationSettings.m
//  NetworkMIDI
//

#import "ApplicationSettings.h"

@implementation ApplicationSettings

@synthesize midiChannel;

static ApplicationSettings* sharedInstance = nil;

- (id)init
{
    self = [super init];
    
    if (self) {
        self.midiChannel = nil;
    }
    
    return  self;
}

- (NSNumber *)midiChannel
{
    if (!midiChannel) {
        midiChannel = [[NSUserDefaults standardUserDefaults] valueForKey:@"MIDIChannel"];
        if (!midiChannel)
            midiChannel = [NSNumber numberWithInteger:1];
        [self setMidiChannel:midiChannel];
    }
    return midiChannel;
}

- (void)setMidiChannel:(NSNumber *)value
{
    midiChannel = value;
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:@"MIDIChannel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (ApplicationSettings *)sharedInstance
{
    @synchronized (self) {
        if (!sharedInstance) {
            sharedInstance = [[ApplicationSettings alloc] init];
            
        }
    }
    
    return sharedInstance;
}

@end
