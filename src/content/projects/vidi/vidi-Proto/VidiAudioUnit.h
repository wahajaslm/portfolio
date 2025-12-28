//
//  VidiAudioUnit.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 20/05/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "aurio_helper.h"
#include <CoreFoundation/CFURL.h>
#import "CAStreamBasicDescription.h"
#import "FFTBufferManager.h"

#define InputBus 1
#define OutputBus 0

@interface VidiAudioUnit : NSObject
{
    AudioUnit					RemoteIoUnit;
    BOOL						unitIsRunning;
    BOOL						unitHasBeenCreated;
    AURenderCallbackStruct		RenderCallbackStruct; /*For Remote I/O input scope*/
    DCRejectionFilter*			dcFilter;
    CAStreamBasicDescription	vidiStreamBasicDescription;
    FFTBufferManager*			fftBufferManager;
    AudioBuffer audioBuffer; // this will hold the latest data from the microphone
}
@property (nonatomic, assign)	AudioUnit				RemoteIoUnit;
@property (nonatomic, assign)	BOOL					unitIsRunning;
@property (nonatomic, assign)	BOOL					unitHasBeenCreated;
@property (nonatomic, assign)	AURenderCallbackStruct	RenderCallbackStruct;


-(void)SetupAudioUnit;
-(void)StartRemoteIO;
- (id)init;



@end
