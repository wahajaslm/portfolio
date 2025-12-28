//
//  VidiTimer.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 20/06/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MILLISECOND 0.001
#define SECOND  1


@interface VidiTimer : NSObject
{
double miliseconds;

double seconds;
double minutes;
double hours;

Float32 midiMiliseconds;
}
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) CFTimeInterval ticks;

@property (strong, nonatomic) NSTimer *midiTimer;
@property (assign, nonatomic) CFTimeInterval midiTicks;

+ (id)sharedInstance;
- (void)timerTick:(NSTimer *)timer;
- (void)startMidiTimer;
- (void)stopMidiTimer;
-(Float32)midiTimeStamp;
- (void)miditimerTick:(NSTimer *)timer;
-(NSString*)TimeStamp;

@end
