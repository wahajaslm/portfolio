//
//  vidiAudioSession.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 20/05/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "vidiAudioSession.h"


@implementation VidiAudioSession

#pragma mark - AVAudioSession methods

// Flag that informs if Audio Session is active
static BOOL isAudioSessionActive = NO;

- (void)startAudio
{
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    NSLog(@"%s isOtherAudioPlaying: %d, oldCategory: %@ withOptions: %d", __FUNCTION__, audioSession.otherAudioPlaying, audioSession.category, audioSession.categoryOptions);
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [audioSession setMode:AVAudioSessionModeMeasurement error:&error];
    
    Float32 preferredBufferSize = .005;
    
    [audioSession setPreferredIOBufferDuration:preferredBufferSize error:&error];
    
    if (!error)
    {
        [self activateAudioSession];
    }
    else
    {
        NSLog(@"%s setCategory Error: %@", __FUNCTION__, error);
    }
    
    if (isAudioSessionActive) {
        [self observeAudioSessionNotifications:YES];
    }
}

// Class method that informs if other app(s) makes sounds
+ (BOOL)isOtherAudioPlaying {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    return audioSession.otherAudioPlaying;
}



- (void)activateAudioSession {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    [audioSession setActive:YES error:&error];
    
    NSLog(@"%s [Main:%d] isActive: %d, isOtherAudioPlaying: %d, AVAudioSession Error: %@", __FUNCTION__, [NSThread isMainThread], isAudioSessionActive, audioSession.isOtherAudioPlaying, error);
    
    if (error) {
        // It's not enough to setActive:YES
        // We have to deactivate it effectively (without that error),
        // so try again (and again... until success).
        isAudioSessionActive = NO;
        [self activateAudioSession];
        return;
    }

    if (!error) {
        // We have to set this flag at the end of activation attempt to avoid playing any sound before.
        isAudioSessionActive = YES;
    } else {
        // Activation failure
        isAudioSessionActive = NO;
    }
    
    NSLog(@"%s isActive: %d, AVAudioSession Activated with category: %@ Error: %@", __FUNCTION__, isAudioSessionActive, [audioSession category], error);
    NSLog(@"%s AVAudioSession Activated with mode: %@ Error: %@", __FUNCTION__, [audioSession mode], error);

}




// Informs if SpriteKit should play sounds (SpriteKit BUG)
+ (BOOL)isAudioSessionActive {
    return isAudioSessionActive;
}

- (void)stopAudio {
    if (!isAudioSessionActive) {
        // Prevent background apps from duplicate entering if terminating an app.
        return;
    }
    
    // Start deactivation process
    [self deactivateAudioSession];
    
    // Remove observers
    [self observeAudioSessionNotifications:NO];
}

- (void)deactivateAudioSession {
    if (isAudioSessionActive) {
        // We have to set this flag before any deactivation attempt to avoid trying playing any sound underway.
        isAudioSessionActive = NO;
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    //[audioSession setActive:NO error:&error];
    [audioSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
    
    NSLog(@"%s isActive: %d, AVAudioSession Error: %@", __FUNCTION__, isAudioSessionActive, error);
    
    if (error) {
        // It's not enough to setActive:NO
        // We have to deactivate it effectively (without that error),
        // so try again (and again... until success).
        [self deactivateAudioSession];
        return;
    } else {
        // Success
    }
}

- (void)observeAudioSessionNotifications:(BOOL)observe {
    NSLog(@"%s YES: %d", __FUNCTION__, observe);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    if (observe) {
        [center addObserver:self selector:@selector(handleAudioSessionInterruption:) name:AVAudioSessionInterruptionNotification object:audioSession];
        [center addObserver:self selector:@selector(handleAudioSessionRouteChange:) name:AVAudioSessionRouteChangeNotification object:audioSession];
        [center addObserver:self selector:@selector(handleAudioSessionMediaServicesWereLost:) name:AVAudioSessionMediaServicesWereLostNotification object:audioSession];
        [center addObserver:self selector:@selector(handleAudioSessionMediaServicesWereReset:) name:AVAudioSessionMediaServicesWereResetNotification object:audioSession];
    } else {
        [center removeObserver:self name:AVAudioSessionInterruptionNotification object:audioSession];
        [center removeObserver:self name:AVAudioSessionRouteChangeNotification object:audioSession];
        [center removeObserver:self name:AVAudioSessionMediaServicesWereLostNotification object:audioSession];
        [center removeObserver:self name:AVAudioSessionMediaServicesWereResetNotification object:audioSession];
    }
}


- (void)handleAudioSessionInterruption:(NSNotification *)notification {
  //  AVAudioSession *audioSession = (AVAudioSession *)notification.object;
    
    AVAudioSessionInterruptionType interruptionType =
    (AVAudioSessionInterruptionType)[[notification.userInfo objectForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    
    AVAudioSessionInterruptionOptions interruptionOption =
    (AVAudioSessionInterruptionOptions)[[notification.userInfo objectForKey:AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
    
    BOOL isAppActive = ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)?YES:NO;
    
    switch (interruptionType) {
        case AVAudioSessionInterruptionTypeBegan: {
            [self deactivateAudioSession];
            break;
        }
            
        case AVAudioSessionInterruptionTypeEnded: {
            [self activateAudioSession];
            if (interruptionOption == AVAudioSessionInterruptionOptionShouldResume) {
                // Do your resume routine
            }
            break;
        }
            
        default:
            break;
    }
    
    NSLog(@"%s [Main:%d] [Active: %d] AVAudioSession Interruption: %@ withInfo: %@", __FUNCTION__, [NSThread isMainThread], isAppActive, notification.object, notification.userInfo);
}

- (void)handleAudioSessionRouteChange:(NSNotification*)notification {
    
    AVAudioSessionRouteChangeReason routeChangeReason =
    (AVAudioSessionRouteChangeReason)[[notification.userInfo objectForKey:AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    
    AVAudioSessionRouteDescription *routeChangePreviousRoute =
    (AVAudioSessionRouteDescription *)[notification.userInfo objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
    
    NSLog(@"%s routeChangePreviousRoute: %@", __FUNCTION__, routeChangePreviousRoute);
    
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonUnknown:
            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonUnknown", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // e.g. a headset was added or removed
            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonNewDeviceAvailable", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            // e.g. a headset was added or removed
            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonOldDeviceUnavailable", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonCategoryChange", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonOverride:
            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonOverride", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonWakeFromSleep", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory", __FUNCTION__);
            break;
            
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange:
            NSLog(@"%s routeChangeReason: AVAudioSessionRouteChangeReasonRouteConfigurationChange", __FUNCTION__);
            break;
            
        default:
            break;
    }
}

-(void)handleAudioSessionMediaServicesWereReset:(NSNotification *)notification {
    NSLog(@"%s [Main:%d] Object: %@ withInfo: %@", __FUNCTION__, [NSThread isMainThread], notification.object, notification.userInfo);
}

-(void)handleAudioSessionMediaServicesWereLost:(NSNotification *)notification {
    NSLog(@"%s [Main:%d] Object: %@ withInfo: %@", __FUNCTION__, [NSThread isMainThread], notification.object, notification.userInfo);
}

    
@end
