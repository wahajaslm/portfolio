//
//  vidiAudioSession.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 20/05/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#include <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#include <CoreFoundation/CFURL.h>
#import <UIKit/UIKit.h>


@interface VidiAudioSession : NSObject

+ (BOOL)isAudioSessionActive; // Informs if SpriteKit should play sounds (SpriteKit BUG)
+ (BOOL)isOtherAudioPlaying; // Informs if other app makes sounds

- (void)startAudio;
- (void)deactivateAudioSession;
- (void)activateAudioSession;
- (void)stopAudio ;
@end
