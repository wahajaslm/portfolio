/*
 
     File: AudioController.h
 Abstract: This class demonstrates the audio APIs used to capture audio data from the microphone and play it out to the speaker. It also demonstrates how to play system sounds

 */

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "BufferManager.h"
#import "DCRejectionFilter.h"
#import "AQRecorder.h"
#import "AQPlayer.h"

@interface AudioController : NSObject {
    
    AudioUnit               _rioUnit;
    BufferManager*          _bufferManager;
    DCRejectionFilter*      _dcRejectionFilter;
    AVAudioPlayer*          _audioPlayer;   // for button pressed sound
   
    
    AQRecorder*					recorder;
    AQPlayer * player ;
    CFStringRef					recordFilePath;
  
    
    BOOL                    _audioChainIsBeingReconstructed;
}
@property (nonatomic, retain)	UILabel			*fileDescription;
@property (nonatomic, assign) BOOL muteAudio;
@property (nonatomic, assign, readonly) BOOL audioChainIsBeingReconstructed;
@property (nonatomic, assign)	BOOL                inBackground;

@property (nonatomic, assign)	BOOL playbackWasInterrupted;
@property (nonatomic, assign)	BOOL playbackWasPaused;
+ (AudioController *) sharedInstance;
- (BufferManager*) getBufferManagerInstance;
- (OSStatus)    startIOUnit;
- (OSStatus)    stopIOUnit;
- (void)        playButtonPressedSound;
- (double)      sessionSampleRate;
- (void)stopRecord;
-(AQRecorder*)AQRecorder;
-(AQPlayer*)AQPlayer;
-(void)stopPlayQueue;

-(void)setFileDescriptionForFormat: (CAStreamBasicDescription)format withName:(NSString*)name;

@end
