//
//  VidiSequence.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 10/07/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "CAXException.h"
#import "CAStreamBasicDescription.h"
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "NetworkMidiController.h"
#define MSPM 60000 //MilliSecondPerMinute
#define DefaultTimeSignature 4

typedef struct
 {
     MusicTimeStamp stamp;
     MusicEventType type;
     UInt32 size;
     void* data;
}    MidiEventInfo;

@interface VidiSequence : NSObject
{

    MusicSequence	musicSequence;
    MusicSequence	PlayerMusicSequence;

  //  NSURL * LoaDFileUrl;
    MusicTrack tempoTrack;
 //   UInt32 timeResolution ;
    MusicPlayer _musicPlayer;
    NSString * MidiList;

      int fileCount;
 
}

//@property (nonatomic , assign)NSString *documentsDirectory;
 
@property (nonatomic,assign)MIDIEndpointRef MidiEndPoint;
@property (nonatomic , readonly)  UInt32 timeResolution ;

@property (nonatomic , assign)  UInt8 TSNumerator ; //TS=TimeSignature
@property (nonatomic , assign)  UInt8 TSDenominator ;


@property (nonatomic , assign)  bool Recording;
@property (nonatomic , assign)  bool Playing;

@property (nonatomic , readonly)  MusicTrack newTrack;

@property (nonatomic, assign) Float64 tempoTrackBpm;
@property (nonatomic, readonly)CFURLRef  NewFileUrl;

@property (nonatomic,strong) NSMutableArray *midiFileItems;


+ (VidiSequence *) sharedInstance;

 const char * noteForMidiNumber(int midiNumber) ;
-(NSString*)noteStringForMidiNumber : (int)number;
-(void) StopMidiRecording;
-(Float64)timeStampToBeatStamp:(Float32)timeStamp; 
-(void)SaveNote:(UInt8)noteNumber timeStamp:(MusicTimeStamp)startTimeStamp duration:(Float32)duration;
-(void)SetTimeSignatureWithNumerator:(UInt8)numerator withDenominator:(UInt8)denominator tempoTrack:(MusicTrack)track;
-(void)NewMidiNoteEvent :(MusicTrack)thisTrack  withTimeStamp:(MusicTimeStamp)inTimestamp NoteMessage:(MIDINoteMessage)thisMessage;
- (void)determineTimeResolutionWithTempoTrack:(MusicTrack)Track;
- (void)SetupPlayerwithMidiFile:(CFURLRef)midiFileURL;
- (void) StopMidiFile;
- (void) RecordMidiFile;
- (void)PlayMidiFile;
-(MIDINoteMessage)NewNoteMessage :(UInt8)midiNoteNumber noteDuration:(Float32)noteDuration	velocity:(UInt8)velocity  releaseVelocity:(UInt8)releaseVelocity channel:(UInt8)channel;
- (void)SetTempoTrackwithBpm:(Float64)tempoBpm Timestamp:(MusicTimeStamp)inTimeStamp;
- (void)CreateSequnce;
- (void)CreateSequnceFile;
- (void)LoadSequnceFile : (CFURLRef)LoaDFileUrl;
- (void)LoadSequnceFileatIndex :(UInt8)index;
-(MusicTrack)SetNewTrack;
@end
