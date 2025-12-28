//
//  VidiTimer.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 20/06/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "VidiTimer.h"

@implementation VidiTimer

static VidiTimer *sharedInstance = nil;

+ (VidiTimer*) sharedInstance {
    @synchronized (self) {
        if (!sharedInstance) {
            sharedInstance = [[VidiTimer alloc] init];
        }
    }
    return sharedInstance;
}


- (id)init
{
    if (self = [super init]) {
        hours = 0;
        minutes =0;
        seconds =0;
        miliseconds=0;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:MILLISECOND target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        
    }
    return self;
}



- (void)timerTick:(NSTimer *)timer
{
    // Timers are not guaranteed to tick at the nominal rate specified, so this isn't technically accurate.
    // However, this is just an example to demonstrate how to stop some ongoing activity, so we can live with that inaccuracy.
    _ticks +=1;
    miliseconds= fmod(_ticks, 1000);
    seconds = fmod(trunc(_ticks/1000), 60.0);
    minutes = fmod(trunc(_ticks /60000.0), 60.0);
    hours = trunc(_ticks / 360000.0);
  
}


- (void)startMidiTimer
{
    if (_midiTimer) {
     
      [self stopMidiTimer];
    }
    midiMiliseconds=0;
    // Timers are not guaranteed to tick at the nominal rate specified, so this isn't technically accurate.
    // However, this is just an example to demonstrate how to stop some ongoing activity, so we can live with that inaccuracy.
    _midiTimer = [NSTimer scheduledTimerWithTimeInterval:MILLISECOND target:self selector:@selector(miditimerTick:) userInfo:nil repeats:YES];
}


- (void)stopMidiTimer
{
    if (_midiTimer)
    {
        [_midiTimer invalidate];
        _midiTimer =nil;
    }
    _midiTicks =0;
   midiMiliseconds=0;
}


- (void)miditimerTick:(NSTimer *)timer
{
    // Timers are not guaranteed to tick at the nominal rate specified, so this isn't technically accurate.
    // However, this is just an example to demonstrate how to stop some ongoing activity, so we can live with that inaccuracy.
    _midiTicks +=1;
    midiMiliseconds= _midiTicks;
   // midiMiliseconds= fmod(_ticks, 1000);
   // seconds = fmod(trunc(_ticks/1000), 60.0);
   // minutes = fmod(trunc(_ticks /60000.0), 60.0);
   // hours = trunc(_ticks / 360000.0);
    
}

-(Float32)midiTimeStamp
{
    return midiMiliseconds;
    
}

-(NSString*)TimeStamp
{
    NSString * timeStamp =[NSString stringWithFormat:@"TimeStamp: %02.0f:%02.0f:%02.0f:%3.0f", hours, minutes, seconds,miliseconds];
    return timeStamp;
}

-(void)dealloc
{
    // I'm never called!
 //   [super dealloc];
}

@end
