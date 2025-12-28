//
//  PitchBendViewController.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 14/05/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "NetworkMidiController.h"
#import "AudioController.h"
//#import "EZAudio.h"
#include "VidiTimer.h"
#include "analysisdata.h"
#include "channel.h"
#import "VidiSequence.h"

typedef enum{
STANDBY=1,
RECORD=2,
LIVE=3
}MKnobStates;


typedef enum{
    ON=1,
    OFF=2
}MicStates;



@interface PitchBendViewController : UIViewController<SettingsViewControllerDelegate>
{
    bool noteWasOn;
    bool CurrentNoteState;
    bool PrevNoteState;
    bool lock;
    bool Hold;
	IBOutlet UILabel*	fileDescription;

    UInt32 previousNote;
    NSUInteger channel;
    NSInteger  offsetNumOctave;
    NSInteger noteOffsetOctave;
    NSInteger offsetNumSemi;
    NSInteger noteOffsetSemi;
    Float32*  l_fftData;
    BufferManager* bufferManager ;
    VidiTimer * vidiTimer;
    AnalysisData *Adata;
    Channel *ch;
    MKnobStates MKnobState;
    MicStates CurMicState;
    AudioController * audioController;
    AQRecorder * recorder;
    AQPlayer * player;
    VidiSequence * PvidiSequence;
    int beat;
    
    MusicTimeStamp midiTimeStampInBeatsStart ;//inbeats
    MusicTimeStamp midiTimeStampInBeatsEnd;//inbeats
    
    

    NSTimeInterval processTimerInterval;
    NSTimer *processTimer;
}
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIButton *btn_play;

@property (weak, nonatomic) IBOutlet UIButton *btn_record;
@property (nonatomic, retain)	UILabel			*fileDescription;

@property (weak, nonatomic) IBOutlet UIView *lowerControlView;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UILabel *SemiToneLabel;
@property (weak, nonatomic) IBOutlet UILabel *octaveLabel;
@property (strong, nonatomic) IBOutlet UIView *DebugView;
@property (weak, nonatomic) IBOutlet UISlider *PitchBendSlider;
@property (weak, nonatomic) IBOutlet UISlider *ModWheelSlider;
@property (weak, nonatomic) IBOutlet UIButton *MKnob;
@property (weak, nonatomic) IBOutlet UIButton *OctaveUp;
@property (weak, nonatomic) IBOutlet UIButton *OctaveDown;
@property (weak, nonatomic) IBOutlet UIButton *Mic;
@property (weak, nonatomic) IBOutlet UIButton *MicState;
@property (weak, nonatomic) IBOutlet UIButton *Wifi;
@property (weak, nonatomic) IBOutlet UIButton *SemiToneUp;
@property (weak, nonatomic) IBOutlet UIButton *SemiToneDown;

- (IBAction)SemiToneChange:(UIButton *)sender;

- (void)MicStateChange;
- (void)MknobStateChanged;
- (IBAction)OctaveChange:(UIButton *)sender;



-(void) setDebugView;
void NoteAtPitch(int pitch, double noteLength);
- (IBAction)SliderValueChnaged:(id)sender;
- (IBAction)NoteOn:(UIButton *)sender;
- (IBAction)NoteOff:(UIButton*)sender;
@end
