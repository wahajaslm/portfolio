//
//  PitchBendViewController.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 14/05/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "PitchBendViewController.h"
#import "ApplicationSettings.h"
#import "BufferManager.h"
#import "useful.h"
#import "VidiSequence.h"


@interface PitchBendViewController ()

@end

@implementation PitchBendViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) StopProcessing
{
    if (processTimer) {
        
        
        processTimer = nil;
        
        NSLog(@"ProcessTimer Stopped");
    }
    
}


-(void)PerformBackgroundProcessing:(NSNotification *)note
{
    
 ///  [self performSelectorInBackground:@selector(ComputePitch:) withObject:nil];
   // NSLog(@"background process");
    
    [self ComputePitch];
    
}

-(void)StartProcessing
{
    
     processTimerInterval= bufferManager->GetFFTInputBufferLength() / bufferManager->SampleRate();
    
   processTimer = [NSTimer scheduledTimerWithTimeInterval:processTimerInterval  target: self
                                   selector: @selector(ComputePitch) userInfo: nil repeats: YES];
    NSLog(@"ProcessTimer Started");
}

-(void)ComputePitch:(id)object
{

    bufferManager->AudioProcessing();
    
 //  [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePlotDebug" object:self];
  
 //   [self setDebugView];
    
}

-(void)ComputePitch
{
    
    bufferManager->AudioProcessing();
    
    //  [[NSNotificationCenter defaultCenter] postNotificationName:@"updatePlotDebug" object:self];
    
       [self setDebugView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self->PrevNoteState=false;
    self->CurrentNoteState=PrevNoteState;

     offsetNumOctave=0;
     noteOffsetOctave=0;
     offsetNumSemi=0;
     noteOffsetSemi=0;
    
    noteWasOn = false;
    beat = 0;
   
    PvidiSequence = [VidiSequence sharedInstance];
    
   
    //--Initial Slider Setting--//
    
    self.PitchBendSlider.transform = CGAffineTransformRotate(_PitchBendSlider.transform,270.0/180*M_PI);
    self.ModWheelSlider.transform = CGAffineTransformRotate(_ModWheelSlider.transform,270.0/180*M_PI);

    
    
    
    CurMicState = OFF;
    UITapGestureRecognizer *tapMic = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(MicStateChange)];
    tapMic.numberOfTapsRequired = 1;
    [self.Mic addGestureRecognizer:tapMic];
    
    
    
    MKnobState = STANDBY;
    UITapGestureRecognizer *tapMKnob = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(MknobStateChanged)];
    tapMKnob.numberOfTapsRequired = 2;
    
    //then need to add the gesture recogniser to a view - this will be the view that recognises the gesture
    [self.MKnob addGestureRecognizer:tapMKnob];
    
    
    vidiTimer =[VidiTimer sharedInstance];
    
   // /*Use this control under the button */
    audioController = [AudioController sharedInstance];
    
    bufferManager = [audioController getBufferManagerInstance];
    
    recorder = [audioController AQRecorder];
    player= [audioController AQPlayer];
    
    // Do any additional setup after loading the view from its nib.
    channel = [[[ApplicationSettings sharedInstance] midiChannel] unsignedIntValue] - 1;
    
    self.btn_play.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueStopped:) name:@"playbackQueueStopped" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackQueueResumed:) name:@"playbackQueueResumed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PstopRecord:) name:@"PstopRecord" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PstopPlayQueue:) name:@"PstopPlayQueue" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PerformBackgroundProcessing:) name:@"PerformBackgroundProcessing" object:nil];

    [vidiTimer startMidiTimer];
    
    /*
    VidiSequence*seq= [VidiSequence sharedInstance];
    
    NSURL*url;
    
    [seq SetupPlayerwithMidiFile:url];
    
    [seq PlayMidiFile];
    */
}





-(void) setDebugView {
    
    

    
    ch = bufferManager->channel;
    Adata = ch->dataAtChunk(bufferManager->currentChunk());
    CurrentNoteState= ch->isNotePlaying();
    
    if(CurrentNoteState)
    {
        //Play Note
        
        if(CurrentNoteState!=PrevNoteState)
        {
        int j = (int)ch->noteData.size()-1;
            if(ch->isVisibleNote(j) && ch->isLabelNote(j))
            {
                //double noteTime = ch->timeAtChunk(ch->noteData[j].startChunk());
                
           //    NSLog(@"T.Notes = %d",ch->noteData.size());
             //          NoteAtPitch(ch->noteData[j].avgPitch(), ch->noteData[j].noteLength());
                
                int pitch=ch->noteData[j].avgPitch();
                double noteLength = ch->noteData[j].noteLength();
                pitch += noteOffsetOctave+noteOffsetSemi-12; //12 is octave error correction
                
                bound(pitch, 0, 128);
                
                //Don't show really short notes
               //Don't show extreame notes
                if(noteLength >= 0.11)
                
                //  if (previousNote!=pitch)
                {
              
                   // if (PvidiSequence.Recording || PvidiSequence.Playing)
                    {
                     midiTimeStampInBeatsStart = [PvidiSequence timeStampToBeatStamp:[vidiTimer midiTimeStamp] ];
                     NSLog(@"timestampBeatsStart%f ",midiTimeStampInBeatsStart);
                        
                    }
                    
                    NSLog(@"NoteOn%d ,notelen %f, timestampBeats%f ",pitch,noteLength,midiTimeStampInBeatsStart);

                    _noteLabel.text= [PvidiSequence noteStringForMidiNumber:pitch];
                    
                     previousNote= pitch;
                    if(!([PvidiSequence Recording] || PvidiSequence.Playing))
                    {
                    [[NetworkMidiController sharedInstance] sendNote:pitch
                                                                  on:YES
                                                           onChannel:1
                     
                                                        withVelocity:0x7F];
                    }
               //     NSLog(@"noteon %d" , pitch);
               //     NSLog(@"notelen %f" , noteLength);

                    // previousNote= pitch;
                    
                    PrevNoteState = CurrentNoteState;
                    lock=false;
                    noteWasOn = true;

                }

                    }
            
            
        }
        
        else
        {
        //    NSLog(@"SameNote");
        }
    }
    
    
        if (!CurrentNoteState && noteWasOn && !lock)
        {
            midiTimeStampInBeatsEnd = [PvidiSequence timeStampToBeatStamp:[vidiTimer midiTimeStamp]];
            Float64 durationBeat = midiTimeStampInBeatsEnd - midiTimeStampInBeatsStart;
            NSLog(@"timestampEndBeats%f ,duration%f ",midiTimeStampInBeatsEnd,durationBeat);
            
            
            if(PvidiSequence.Recording)
            {
                
                if(durationBeat > 0.1)
                {
                  [self setMidiEventwithNote:previousNote startTimestamp:midiTimeStampInBeatsStart duration:durationBeat];
          
                }

            }
              if(![PvidiSequence Recording])
              {
            [[NetworkMidiController sharedInstance] sendNote:previousNote
                                                          on:NO
                                                   onChannel:1 withVelocity:0x7F];
              }
                NSLog(@"NoteOff");
                
         
          //  beat++;
          //  NSLog(@"Note OFF");
            
            PrevNoteState = CurrentNoteState;
            lock=true;
            noteWasOn=false;
        }
    
     //   float pitch = ch->averagePitch(chunk, chunk+1);
      //  NSLog(@"pitch %f" ,pitch );
    
    
}

void NoteAtPitch(int pitch, double noteLength)
{
    pitch = bound(pitch, 0, 128);
    
    if(noteLength < 0.1)
    { NSLog(@"notelen %f" , noteLength);
        return; //Don't show really short notes
    }
    if(pitch > 84) return; //Don't show extreame notes
   
  //  if (previousNote!=pitch)
    {
       //  previousNote= pitch;
        pitch=pitch+10;
        [[NetworkMidiController sharedInstance] sendNote:pitch
                                                      on:YES
                                               onChannel:1
                                            withVelocity:0x7F];
    NSLog(@"note %d" , pitch);
   // previousNote= pitch;
    }
}



- (IBAction)OctaveChange:(UIButton *)sender {
    
    if (sender.tag ==1 )
    {
        offsetNumOctave+=1;
    }
   else if (sender.tag ==2 )
    {
        offsetNumOctave-=1;
    }
    
    noteOffsetOctave  = 12* offsetNumOctave;
    
    _octaveLabel.text = [NSString stringWithFormat:@"%ld",(long)offsetNumOctave];
}
- (IBAction)SemiToneChange:(UIButton *)sender {
    
    if (sender.tag ==1 )
    {
        offsetNumSemi+=1;
       
    }
    else if (sender.tag ==2 )
    {
        offsetNumSemi-=1;
        
    }
    
    if (offsetNumSemi <0)
    {
        offsetNumSemi=0;
    }
    
    if (offsetNumSemi >12)
    {
        offsetNumSemi=12;
    }
    
    _SemiToneLabel.text = [NSString stringWithFormat:@"%ld",(long)offsetNumSemi];
 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SliderValueChnaged:(id)sender {
 
    NetworkMidiController *controller = [NetworkMidiController sharedInstance];
    UISlider *PitchWheel = (UISlider *)sender;
    
    
    NSUInteger controllerNumber = [PitchWheel tag];
    NSUInteger value = (int)(PitchWheel.value);
    
    [controller sendChangeForPitchWheel:controllerNumber
                              onChannel:channel
                              withValue:value];
    
    NSLog(@"Pitch Wheel : %lu ", (unsigned long)value);
}

- (IBAction)NoteOn:(UIButton *)sender {
   
  //  NSUInteger note = [sender tag] + (0xC);
 //  [[NetworkMidiController sharedInstance] sendNote:80
   //                                        on:YES
   //                                 onChannel:channel
   //                             withVelocity:0x7F];
    Hold=true;
    NSLog(@"Note ON");
}


#pragma mark -
#pragma mark SettingsViewControllerDelegate implementation

- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller
{
    channel = [[[ApplicationSettings sharedInstance] midiChannel] unsignedIntValue] - 1;
}


- (IBAction)NoteOff:(UIButton*)sender {
    
   // NSUInteger note = [sender tag] + (0xC);
    //[[NetworkMidiController sharedInstance] sendNote:80
    //                                              on:NO
    //                                       onChannel:channel
     //                                   withVelocity:0x7F];
    
    Hold=false;
    NSLog(@"Note OFF");
    

    
        }



- (void)MknobStateChanged {
    
    if (MKnobState == STANDBY)
    {
        [_MKnob setImage:[UIImage imageNamed:@"Record Button.png"] forState:UIControlStateNormal];
        [_OctaveUp setImage:[UIImage imageNamed:@"OctaveUP_On.png"] forState:UIControlStateNormal];
        [_OctaveDown setImage:[UIImage imageNamed:@"OctaveDown_On.png"] forState:UIControlStateNormal];
        [_Wifi setImage:[UIImage imageNamed:@"Recording Mode.png"] forState:UIControlStateNormal];
        
        [_SemiToneUp setImage:[UIImage imageNamed:@"OctaveUP_On.png"] forState:UIControlStateNormal];
        [_SemiToneDown setImage:[UIImage imageNamed:@"OctaveDown_On.png"] forState:UIControlStateNormal];
        
        MKnobState=RECORD;
      //  [self StartProcessing];
        
        [PvidiSequence RecordMidiFile];
        [vidiTimer startMidiTimer];
        
        
        
       
    }
    
   else if (MKnobState ==RECORD)
    
    {
        [_MKnob setImage:[UIImage imageNamed:@"Playback Button.png"] forState:UIControlStateNormal];
        [_OctaveUp setImage:[UIImage imageNamed:@"Octave UP.png"] forState:UIControlStateNormal];
        [_OctaveDown setImage:[UIImage imageNamed:@"Octave Down.png"] forState:
         UIControlStateNormal];
        [_SemiToneUp setImage:[UIImage imageNamed:@"Octave UP.png"] forState:UIControlStateNormal];
        [_SemiToneDown setImage:[UIImage imageNamed:@"Octave Down.png"] forState:
         UIControlStateNormal];
        
        [_Wifi setImage:[UIImage imageNamed:@"Playback Mode.png"] forState:UIControlStateNormal];
        
        MKnobState=LIVE;
        midiTimeStampInBeatsStart=0;
        midiTimeStampInBeatsEnd=0;
       // [self StopProcessing];
        beat=0;
    
        [vidiTimer stopMidiTimer];
        
        [PvidiSequence StopMidiRecording];
        [PvidiSequence SetupPlayerwithMidiFile:PvidiSequence.NewFileUrl];
        [PvidiSequence PlayMidiFile];
     
    }

   else if (MKnobState==LIVE)
   {
       
       [_MKnob setImage:[UIImage imageNamed:@"Standby Button.png"] forState:UIControlStateNormal];
       [_OctaveUp setImage:[UIImage imageNamed:@"Up button.png"] forState:UIControlStateNormal];
       [_OctaveDown setImage:[UIImage imageNamed:@"Down Button.png"] forState:UIControlStateNormal];
       [_SemiToneUp setImage:[UIImage imageNamed:@"Up button.png"] forState:UIControlStateNormal];
       [_SemiToneDown setImage:[UIImage imageNamed:@"Down Button.png"] forState:UIControlStateNormal];
       
       [_Wifi setImage:[UIImage imageNamed:@"Standby Mode.png"] forState:UIControlStateNormal];
       
       
       [PvidiSequence StopMidiFile];
       PvidiSequence.Recording=false;
       PvidiSequence.Playing=false;
       [vidiTimer startMidiTimer];
       MKnobState= STANDBY;
   }
}



-(void)setMidiEventwithNote:(UInt8)note startTimestamp:(MusicTimeStamp)timestamp duration:(Float32)duration
{

    [PvidiSequence SaveNote:note timeStamp:timestamp duration:duration] ;


}

- (void)MicStateChange
{
    
    if (CurMicState==ON)
    {
        [_Mic setImage:[UIImage imageNamed:@"Mic off.png"] forState:UIControlStateNormal];
        [audioController stopIOUnit];
        [self StopProcessing];
        
        
         CurMicState = OFF;
    }
    
    else
    {
        [_Mic setImage:[UIImage imageNamed:@"Mic.png"] forState:UIControlStateNormal];
        [audioController startIOUnit];
        [self StartProcessing];
        CurMicState = ON;
        

    }
}

- (IBAction)play:(id)sender
{
	if (player->IsRunning())
	{
		if (audioController.playbackWasPaused)
        {
			OSStatus result = player->StartQueue(true);
            audioController.playbackWasPaused = NO;
			if (result == noErr)
				[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
		}
		else
			[audioController stopPlayQueue];
	}
	else
	{
		OSStatus result = player->StartQueue(false);
		if (result == noErr)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"playbackQueueResumed" object:self];
	}
}




- (IBAction)record:(id)sender
{
	if (recorder->IsRunning()) // If we are currently recording, stop and save the file.
	{
		[audioController stopRecord];
	}
	else // If we're not recording, start.
	{
		self.btn_play.enabled = NO;
        [self.btn_play setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

		
		// Set the button's state to "stop"
		[self.btn_record setTitle: @"Stop" forState:UIControlStateNormal];
        
		// Start the recorder
		recorder->StartRecord(CFSTR("recordedFile.caf"));
		
		[audioController setFileDescriptionForFormat:recorder->DataFormat() withName:@"Recorded File"];
		
		// Hook the level meter up to the Audio Queue for the recorder
	//	[lvlMeter_in setAq: recorder->Queue()];
	}
}


# pragma mark Notification routines
- (void)playbackQueueStopped:(NSNotification *)note
{
	[self.btn_play setTitle: @"Play" forState:UIControlStateNormal];
    //[lvlMeter_in setAq: nil];
	self.btn_record.enabled = YES;
}

- (void)playbackQueueResumed:(NSNotification *)note
{
	[self.btn_play setTitle: @"Stop" forState:UIControlStateNormal];
	self.btn_record.enabled = NO;
    [self.btn_record setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];

	//[lvlMeter_in setAq: player->Queue()];
}


#pragma mark Playback routines

-(void)PstopPlayQueue:(NSNotification *)note

{
	//player->StopQueue();
	//[lvlMeter_in setAq: nil];
	self.btn_record.enabled = YES;
}

- (void)PstopRecord:(NSNotification *)note

{
	// Disconnect our level meter from the audio queue
	//[lvlMeter_in setAq: nil];
	
//	recorder->StopRecord();
	
	// dispose the previous playback queue//
//	player->DisposeQueue(true);
    
	// now create a new queue for the recorded file
	//recordFilePath = (__bridge CFStringRef)[NSTemporaryDirectory() stringByAppendingPathComponent: @"recordedFile.caf"];
	//player->CreateQueueForFile(recordFilePath);
    
	// Set the button's state back to "record"
    [self.btn_record setTitle: @"Record" forState:UIControlStateNormal];
	self.btn_play.enabled = YES;
    [self.btn_play setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
}
@end
