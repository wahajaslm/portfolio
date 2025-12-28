//
//  VidiSequence.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 10/07/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "VidiSequence.h"

@implementation VidiSequence
@synthesize midiFileItems;
static VidiSequence* sharedInstance=nil;





+ (VidiSequence*) sharedInstance
{
    @synchronized (self) {
        if (!sharedInstance) {
    
            sharedInstance = [[VidiSequence alloc] init];
        }
    }
    return sharedInstance;
}



- (id)init
{
    if (self = [super init]) {
        
        // add interruption handler
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(SetMidiEndPointForSequence:)
                                                     name:@"MidiEndPointRefForSequence"
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(RemoveMidiEndPointForSequence:)
                                                     name:@"MidiEndPointRefForSequenceRemove"
         
                                                   object:nil];

        midiFileItems= [[NSMutableArray alloc]init];
      //  MidiList = [[NSBundle mainBundle] pathForResource:@"MidiList" ofType:@"plist"];

        
        
        _Recording =false;
        
    }
    return self;
}


-(void)SetMidiEndPointForSequence :(NSNotification *)notification{

_MidiEndPoint= [[MIDINetworkSession defaultSession] destinationEndpoint];

}


-(void)RemoveMidiEndPointForSequence :(NSNotification *)notification{
    
    _MidiEndPoint= nil;
    
}

- (void)CreateSequnce
{
    try
    {
    XThrowIfError
        ( NewMusicSequence(&musicSequence) , "Could not create midi sequence\n");
    }
    catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
	}
}


- (void)CreatePlaySequnce
{
    try
    {
        XThrowIfError
        ( NewMusicSequence(&PlayerMusicSequence) , "Could not create midi sequence\n");
    }
    catch (CAXException e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
	}
}


- (void)CreateSequnceFile
{
    
    
 //   CFStringRef inRecordFile;

   
   // NewFileUrl = [NSURL fileURLWithPath:@"/Users/<user>/Desktop/bach-invention-01.mid"];
/*
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *midiPath = [documentsDirectory
                          stringByAppendingPathComponent:[NSString stringWithFormat:@"/MIDIs/%s.mid","test"]];
    CFURLRef midiURL = (__bridge CFURLRef)[[NSURL alloc] initFileURLWithPath:midiPath];
*/
    // init sequence
  //  NewMusicSequence(&sequence);
   
    
   NSError *error;

    NSString *fileName = [NSString stringWithFormat:@"MidiFile%d",fileCount];
    
   // NSString *fileName = @"MidiFile";
    
    //1)Create path directory into documents
  //  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
  //  NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    //2)Append the path with Plist - Full file path
  
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
   
    //Plist path
    NSString *plistpath = [documentsDirectory stringByAppendingPathComponent:@"MidiList.plist"]; //3
    
    NSString *midiFilePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mid",fileName]]; //3
    
    
  
    NSFileManager *fileManager = [NSFileManager defaultManager];
  
    if (![fileManager fileExistsAtPath: plistpath]) //4
    {
     NSString *Midiplist = [[NSBundle mainBundle] pathForResource:@"MidiList" ofType:@"plist"]; //5
        
        [fileManager copyItemAtPath:Midiplist toPath: plistpath error:&error]; //6
    }
  
    
    
    NSMutableDictionary *plistFileDataDictionary = [[NSMutableDictionary alloc]initWithContentsOfFile:plistpath];
   
    NSMutableArray* plistMidiDataArray=[[NSMutableArray alloc]init];
    
    if([plistFileDataDictionary count] != 0)
    {
        
        plistMidiDataArray = [NSMutableArray arrayWithArray:(NSMutableArray*)[plistFileDataDictionary valueForKey:@"mididata"]];
     
    }
    
    [plistMidiDataArray addObject:[NSMutableArray arrayWithObjects:fileName, midiFilePath,nil]];

//    NSString *array=[[plistMidiDataArray objectAtIndex:0] objectAtIndex:0];
    
    //adding the new objects to the plist
    [plistFileDataDictionary setObject:plistMidiDataArray forKey:@"mididata"];
    
    [plistFileDataDictionary writeToFile:plistpath atomically:YES];
    //finally saving the changes made to the file
 //   [plistFileDataDictionary writeToFile:plistpath atomically:YES];
    
    
    
    
  //  NSMutableDictionary *fileDataDictionary ;
    
    

    //[fileDataDictionary :midiFilePath forKey:fileName];
    
   // [fileDataDictionary writeToFile: Midiplist atomically:YES];

    
    //This array only keeps the file name
   // [midiFileItems addObject:fileName];
    
   // [midiFileItems writeToFile:path atomically:true];
   // [MidiList ;
    
    
    // Now that Plist path has been copied to documents directory ....
    
    //NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    
    //here add elements to data file and write data to file
   // int value = 5;
    
   // [data setObject:[NSString numberWithInt:value] forKey:@”value”];
    
   // [data writeToFile: path atomically:YES];
    //[data release];

    
//    inRecordFile= (CFSTR("midiFile.mid"));
    
    
    //Saving array of 
   // [midiFileItems addObject:(__bridge NSString*)inRecordFile];
    
    
//    NSString *recordFile = [NSTemporaryDirectory() stringByAppendingPathComponent: (__bridge NSString*)inRecordFile];
    
	
    
    // create the audio file
    try
    {
    
    _NewFileUrl = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)midiFilePath, kCFURLPOSIXPathStyle, false);
        
    XThrowIfError
    (MusicSequenceFileCreate(musicSequence, _NewFileUrl, kMusicSequenceFile_MIDIType, kMusicSequenceFileFlags_EraseFile, 0),"Could Not Create Sequence File\n");
   
        
    }
    catch (CAXException e)
    {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }
    
 }


- (void)LoadSequnceFile : (CFURLRef)LoaDFileUrl
{
// Load the MIDI File
    if(!musicSequence)
    {
        [ self CreateSequnce];
    }
    
  //  LoaDFileUrl= [NSURL fileURLWithPath:@"/Users/<user>/Desktop/bach-invention-01.mid"];
    MusicSequenceFileLoad(musicSequence, LoaDFileUrl, 0, 0);
    [self ParseMidiSequence];
    
}

- (void)LoadSequnceFileatIndex :(UInt8)index
{
   // CFURLRef LoaDFileUrl;
 
 //   NSString * filename = [midiFileItems objectAtIndex:index];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *plistpath = [documentsDirectory stringByAppendingPathComponent:@"MidiList.plist"]; //3
    
    
    NSMutableDictionary *plistFileDataDictionary = [[NSMutableDictionary alloc]initWithContentsOfFile:plistpath];
    
    NSMutableArray* plistMidiDataArray=[[NSMutableArray alloc]init];
    
    if([plistFileDataDictionary count] != 0)
    {
        
        plistMidiDataArray = [NSMutableArray arrayWithArray:(NSMutableArray*)[plistFileDataDictionary valueForKey:@"mididata"]];
        
    }
    
    NSString * string = [[plistMidiDataArray objectAtIndex:index] objectAtIndex:1];
    
    NSURL  * FileUrl  = [NSURL fileURLWithPath:string];
    
    
  //  NSMutableArray* MidiData=[[NSMutableArray alloc]initWithArray:[plistMidiDataArray objectAtIndex:index]];
    
    //load from savedStock example int value
    CFURLRef midiPath = (__bridge CFURLRef)FileUrl;
   // NSString *midiPath = [documentsDirectory stringByAppendingPathComponent:filename]; //3
    
    // Load the MIDI File
    if(!musicSequence)
    {
        [ self CreateSequnce];
    }
    
    //  LoaDFileUrl= [NSURL fileURLWithPath:@"/Users/<user>/Desktop/bach-invention-01.mid"];
    MusicSequenceFileLoad(musicSequence,midiPath, 0, 0);

    [self ParseMidiSequence];
    
  }


- (void)SetTempoTrackwithBpm:(Float64)tempoBpm Timestamp:(MusicTimeStamp)inTimeStamp
{

    MusicTrack VtempoTrack;
    
    try
   
    {
        XThrowIfError
        ( MusicSequenceGetTempoTrack(musicSequence, &VtempoTrack),"Error getting tempo  track: %ld\n");
        
      //  MusicTrackClear(VtempoTrack, 0, 0);
        
        XThrowIfError
        (MusicTrackNewExtendedTempoEvent(VtempoTrack, inTimeStamp, tempoBpm),"Error adding tempo to track: %ld\n");
      
        
       [self SetTimeSignatureWithNumerator:_TSNumerator withDenominator:_TSDenominator tempoTrack:VtempoTrack];
        
        
        [self determineTimeResolutionWithTempoTrack:VtempoTrack];

    }
    catch (CAXException e)
    {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }

}

void parseTempoTrack(MusicSequence sequence)
{
    // Get the Tempo Track
    MusicTrack tempoTrack;
    MusicSequenceGetTempoTrack(sequence, &tempoTrack);
    
    // Create an iterator that will loop through the events in the track
    MusicEventIterator iterator;
    NewMusicEventIterator(tempoTrack, &iterator);
    
    Boolean hasNext = YES;
    MusicTimeStamp timestamp = 0;
    MusicEventType eventType = 0;
    const void *eventData = NULL;
    UInt32 eventDataSize = 0;
    
    // Run the loop
    MusicEventIteratorHasCurrentEvent(iterator, &hasNext);
    while (hasNext) {
        MusicEventIteratorGetEventInfo(iterator,
                                       &timestamp,
                                       &eventType,
                                       &eventData,
                                       &eventDataSize);
        
        // Process each event here
        if(eventType == kMusicEventType_ExtendedTempo)
        {
            ExtendedTempoEvent * event = (ExtendedTempoEvent*)eventData;
            
        printf("Event found! EXTENDED TEMPO: %f\n",event->bpm);
        }
        MusicEventIteratorNextEvent(iterator);
        MusicEventIteratorHasCurrentEvent(iterator, &hasNext);
    }
}

void parseTrackForMIDIEvents(MusicEventIterator iterator)
{
    MusicTimeStamp timestamp = 0;
    MusicEventType eventType = 0;
    const void *eventData = NULL;
    UInt32 eventDataSize = 0;
    Boolean hasNext = YES;
    
    MusicEventIteratorHasCurrentEvent(iterator, &hasNext);
    while (hasNext) {
        MusicEventIteratorGetEventInfo(iterator, &timestamp, &eventType, &eventData, &eventDataSize);
        if (eventType == kMusicEventType_MIDINoteMessage)
        {
            MIDINoteMessage *noteMessage = (MIDINoteMessage*)eventData;
            printf("Note - timestamp: %6.3f, channel: %d, note: %d, velocity: %d, release velocity: %d, duration: %.3f\n",
                   timestamp,
                   noteMessage->channel,
                   noteMessage->note,
                   noteMessage->velocity,
                   noteMessage->releaseVelocity,
                   noteMessage->duration
                   );
        
            }
         MusicEventIteratorNextEvent(iterator);
        MusicEventIteratorHasCurrentEvent(iterator, &hasNext);
    }
}

void parseMIDIEventTracks(MusicSequence sequence)
{
    UInt32 trackCount;
    MusicSequenceGetTrackCount(sequence, &trackCount);
    
    MusicTrack track = NULL;
    
    for (UInt32 index = 0; index < trackCount; index++) {
        MusicSequenceGetIndTrack(sequence, index, &track);
        MusicEventIterator iterator = NULL;
        NewMusicEventIterator(track, &iterator);
        parseTrackForMIDIEvents(iterator);
    }
}



- (MusicTrack)SetNewTrack
{
    MusicTrack NewTrack;
    try
    {
        
        XThrowIfError
        (MusicSequenceNewTrack(musicSequence, &NewTrack),"Error Creating new track: %ld\n");
        
    }
    
    catch (CAXException e)
    {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }
    
    return NewTrack;
}


-(MIDINoteMessage)NewNoteMessage :(UInt8)midiNoteNumber noteDuration:(Float32)noteDuration	velocity:(UInt8)velocity  releaseVelocity:(UInt8)releaseVelocity channel:(UInt8)channel
{
    
MIDINoteMessage thisMessage;
thisMessage.note = midiNoteNumber;
thisMessage.duration = noteDuration;
thisMessage.velocity = velocity;
thisMessage.releaseVelocity = releaseVelocity;
thisMessage.channel = channel;

    return thisMessage;
}

-(void)NewMidiNoteEvent :(MusicTrack)thisTrack  withTimeStamp:(MusicTimeStamp)inTimestamp NoteMessage:(MIDINoteMessage)thisMessage
{
    try{
  
    XThrowIfError
    (MusicTrackNewMIDINoteEvent(thisTrack, inTimestamp, &thisMessage),"Error adding midi note \n");
    }
    catch (CAXException e)
    {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }
}


-(void)SaveNote:(UInt8)noteNumber timeStamp:(MusicTimeStamp)startTimeStamp duration:(Float32)duration{

    
    MIDINoteMessage NoteMsg=[self NewNoteMessage:noteNumber noteDuration:duration velocity:127 releaseVelocity:0 channel:1];
    
    [self NewMidiNoteEvent:_newTrack withTimeStamp:startTimeStamp NoteMessage:NoteMsg];
    
}

/*
char *trackName = "Bass";

MIDIMetaEvent *trackNameMetaEvent = CFAllocatorAllocate(NULL, sizeof(MIDIMetaEvent) - 1 + strlen(trackName), 0);
trackNameMetaEvent->metaEventType = 0x03;
trackNameMetaEvent->dataLength = strlen(trackName);
strncpy(trackNameMetaEvent->data, trackName, strlen(trackName));

if (MusicTrackNewMetaEvent(musicTrack, 0.0, trackNameMetaEvent) != noErr)
[NSException raise:@"main" format:@"Cannot add track name meta event."];
*/


-(void)SetTimeSignatureWithNumerator:(UInt8)numerator withDenominator:(UInt8)denominator tempoTrack:(MusicTrack)track
{
  
  
    /* Note:
     
    
     Time Signature
     
     FF 58 04 nn dd cc bb
     
     nn is a byte specifying the numerator of the time signature (as notated).
     dd is a byte specifying the denominator of the time signature as a negative power of 2 (ie 2 represents a quarter-note, 3 represents an eighth-note, etc).
     cc is a byte specifying the number of MIDI clocks between metronome clicks.
     bb is a byte specifying the number of notated 32nd-notes in a MIDI quarter-note (24 MIDI Clocks). The usual value for this parameter is 8, though some sequencers allow the user to specify that what MIDI thinks of as a quarter note, should be notated as something else.
     
     Examples
     A time signature of 4/4, with a metronome click every 1/4 note, would be encoded :
     FF 58 04 04 02 18 08
     There are 24 MIDI Clocks per quarter-note, hence cc=24 (0x18).
     
     A time signature of 6/8, with a metronome click every 3rd 1/8 note, would be encoded :
     FF 58 04 06 03 24 08
     Remember, a 1/4 note is 24 MIDI Clocks, therefore a bar of 6/8 is 72 MIDI Clocks.
     Hence 3 1/8 notes is 36 (=0x24) MIDI Clocks.
     
     There should generally be a Time Signature Meta event at the beginning of a track (at time = 0), otherwise a default 4/4 time signature will be assumed. Thereafter they can be used to effect an immediate time signature change at any point within a track.
     
     For a format 1 MIDI file, Time Signature Meta events should only occur within the first MTrk chunk.
     */
    

//MIDIMetaEvent *ptr;
MIDIMetaEvent timeSignatureMetaEvent;
//Byte MidiClocks = (0x18 * 4)*(numerator/denominator);
Byte powerof2 =(log10(denominator)/log10(2));


    
timeSignatureMetaEvent.metaEventType = 0x58;
timeSignatureMetaEvent.dataLength = 4;
timeSignatureMetaEvent.data[0] = (Byte)numerator;
timeSignatureMetaEvent.data[1] = powerof2;
timeSignatureMetaEvent.data[2] = 0x18;//24midi clocks
timeSignatureMetaEvent.data[3] = 0x08;

MusicTrackNewMetaEvent(track, 0,&timeSignatureMetaEvent);

}

-(void)SetMidiMetaEvent:(MIDIMetaEvent *)MetaEvent withTempoTrack:(MusicTrack)track


{
    try
    {
        XThrowIfError(MusicTrackNewMetaEvent(track, 0,MetaEvent),"NewMetaEvent cannot be created");
    }
    
    catch (CAXException e)
    {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }

}


-(void)showNoteInformationWithNote:(MIDINoteMessage *)noteMessage
                          timestamp:(MusicTimeStamp)timestamp
{
    CABarBeatTime barBeatTime;
    MusicSequenceBeatsToBarBeatTime(musicSequence, timestamp, _timeResolution, &barBeatTime);
    
    printf("%03d:%02d:%03d, timestamp: %5.3f, channel: %d, note: %s, duration: %.3f\n",
           barBeatTime.bar,
           barBeatTime.beat,
           barBeatTime.subbeat,
           timestamp,
           noteMessage->channel,
           noteForMidiNumber(noteMessage->note),
           noteMessage->duration
           );
}


- (void)determineTimeResolutionWithTempoTrack:(MusicTrack)Track
{
    UInt32 timeRes = 0;
    UInt32 propertyLength = 0;
    
    MusicTrackGetProperty(Track,
                          kSequenceTrackProperty_TimeResolution,
                          NULL,
                          &propertyLength);
    
    
    MusicTrackGetProperty(Track,
                          kSequenceTrackProperty_TimeResolution,
                          &timeRes,
                          &propertyLength);
    
    printf("propertyLength: %d\n", propertyLength);
    printf("timeResolution: %d\n", timeRes);
    
    _timeResolution = timeRes;
}



- (void)SetupPlayerwithMidiFile:(CFURLRef)midiFileURL
{
    
    
    try {
        
    if (midiFileURL)
    {
      //  NSLog(@"midiFileURL = '%@'\n", [midiFileURL description]);
    }
    
    
    if(!musicSequence)
    {
        [ self CreateSequnce];
    }
    
        if (!_musicPlayer) {
            
    XThrowIfError(NewMusicPlayer(&_musicPlayer), "NewMusicPlayer cannot be created");
        }
    
    XThrowIfError(MusicPlayerSetSequence(_musicPlayer, musicSequence), "MusicPlayerSetSequence");
    
    
    XThrowIfError(MusicSequenceFileLoad(musicSequence,
                                     midiFileURL,
                                     0, // can be zero in many cases
                                     kMusicSequenceLoadSMF_ChannelsToTracks), "MusicSequenceFileLoad");
    
    //  MIDIEndpointRef aPlayerDestEndpoint;
    //  aPlayerDestEndpoint = MIDIGetDestination(0);
    //  CheckError(MusicSequenceSetMIDIEndpoint(self.musicSequence, aPlayerDestEndpoint), "MusicSequenceSetMIDIEndpoint");
    
    //CheckError(MusicSequenceSetAUGraph(musicSequence, self.processingGraph),
      //         "MusicSequenceSetAUGraph");
    
   // CAShow(self.musicSequence);
    
    [self ParseMidiSequence];
        [self useMIDIEndpoint];
    XThrowIfError(MusicPlayerPreroll(_musicPlayer), "MusicPlayerPreroll");
    }
    
    catch (CAXException e)
    {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }


}

-(void) StopMidiRecording{
    
    _Recording = false;
    [self CreateSequnceFile];
    
    [self stop];

}

- (void) RecordMidiFile{
    
     if (_Playing)
     {
         [self stop];
         _Playing=false;
     }
    
    
    _Recording= true;
    
    if(!musicSequence)
    {
        [ self CreateSequnce];
    }
    
     [self SetTempoTrackwithBpm:_tempoTrackBpm Timestamp:0];

    _newTrack = [self SetNewTrack];
   
    
    NSLog(@"Recording Started");
  
  
}


- (void)PlayMidiFile

{
    _Playing = true;
    try
    {
    NSLog(@"starting music player");
    XThrowIfError(MusicPlayerStart(_musicPlayer), "MusicPlayer could not be started");
    }
    catch (CAXException e)
    {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }
}

- (void) StopMidiFile
{
    try{
       
    [self stop];
        
    }
    catch (CAXException e)
    {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }


}


- (void) ParseMidiSequence
{

    parseTempoTrack(musicSequence);
    
UInt32 trackCount;
XThrowIfError(MusicSequenceGetTrackCount(musicSequence, &trackCount), "MusicSequenceGetTrackCount failed");

NSLog(@"Number of tracks: %u", (unsigned int)trackCount);

MusicTrack track;
for(int i = 0; i < trackCount; i++)
{
    XThrowIfError(MusicSequenceGetIndTrack (musicSequence, i, &track), "MusicSequenceGetIndTrack failed");
    
    MusicTimeStamp track_length;
    UInt32 tracklength_size = sizeof(MusicTimeStamp);
    XThrowIfError(MusicTrackGetProperty(track, kSequenceTrackProperty_TrackLength, &track_length, &tracklength_size), "kSequenceTrackProperty_TrackLength failed");
    NSLog(@"Track length %f", track_length);
    
    MusicTrackLoopInfo loopInfo;
    UInt32 lisize = sizeof(MusicTrackLoopInfo);
    XThrowIfError(MusicTrackGetProperty(track,kSequenceTrackProperty_LoopInfo, &loopInfo, &lisize ), "kSequenceTrackProperty_LoopInfo failed");
    NSLog(@"Loop info: duration %f", loopInfo.loopDuration);
    
    [self iterate:track];
}
    
}

- (void) iterate: (MusicTrack) track
{
	MusicEventIterator	iterator;
	XThrowIfError(NewMusicEventIterator (track, &iterator), "NewMusicEventIterator");
    
    
    MusicEventType eventType;
	MusicTimeStamp eventTimeStamp;
    UInt32 eventDataSize;
    const void *eventData;
    
    Boolean	hasCurrentEvent = NO;
    XThrowIfError(MusicEventIteratorHasCurrentEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
    while (hasCurrentEvent)
    {
        MusicEventIteratorGetEventInfo(iterator, &eventTimeStamp, &eventType, &eventData, &eventDataSize);
        NSLog(@"event timeStamp %f ", eventTimeStamp);
        switch (eventType) {
                
            case kMusicEventType_ExtendedNote : {
                ExtendedNoteOnEvent* ext_note_evt = (ExtendedNoteOnEvent*)eventData;
                NSLog(@"extended note event, instrumentID %u", (unsigned int)ext_note_evt->instrumentID);
                
            }
                break ;
                
            case kMusicEventType_ExtendedTempo : {
                ExtendedTempoEvent* ext_tempo_evt = (ExtendedTempoEvent*)eventData;
                NSLog(@"ExtendedTempoEvent, bpm %f", ext_tempo_evt->bpm);
                
            }
                break ;
                
            case kMusicEventType_User : {
                MusicEventUserData* user_evt = (MusicEventUserData*)eventData;
                NSLog(@"MusicEventUserData, data length %u", (unsigned int)user_evt->length);
            }
                break ;
                
            case kMusicEventType_Meta : {
                MIDIMetaEvent* meta_evt = (MIDIMetaEvent*)eventData;
                NSLog(@"MIDIMetaEvent, event type %d", meta_evt->metaEventType);
                
            }
                break ;
                
            case kMusicEventType_MIDINoteMessage : {
                MIDINoteMessage* note_evt = (MIDINoteMessage*)eventData;
                NSLog(@"note event channel %d", note_evt->channel);
                NSLog(@"note event note %d", note_evt->note);
                NSLog(@"note event duration %f", note_evt->duration);
                NSLog(@"note event velocity %d", note_evt->velocity);
                [self showNoteInformationWithNote:note_evt timestamp:eventTimeStamp];
            }
                break ;
                
            case kMusicEventType_MIDIChannelMessage : {
                MIDIChannelMessage* channel_evt = (MIDIChannelMessage*)eventData;
                NSLog(@"channel event status %X", channel_evt->status);
                NSLog(@"channel event d1 %X", channel_evt->data1);
                NSLog(@"channel event d2 %X", channel_evt->data2);
                
                if(channel_evt->status == (0xC0 & 0xF0)) {
               //     [self setPresetNumber:channel_evt->data1];
                }
            }
                break ;
                
            case kMusicEventType_MIDIRawData : {
                MIDIRawData* raw_data_evt = (MIDIRawData*)eventData;
                NSLog(@"MIDIRawData, length %u", (unsigned int)raw_data_evt->length);
                
            }
                break ;
                
            case kMusicEventType_Parameter : {
                ParameterEvent* parameter_evt = (ParameterEvent*)eventData;
                NSLog(@"ParameterEvent, parameterid %u", (unsigned int)parameter_evt->parameterID);
                
            }
                break ;
                
            default :
                break ;
        }
        
        XThrowIfError(MusicEventIteratorHasNextEvent(iterator, &hasCurrentEvent), "MusicEventIteratorHasCurrentEvent");
        XThrowIfError(MusicEventIteratorNextEvent(iterator), "MusicEventIteratorNextEvent");
    }
}



const char * noteForMidiNumber(int midiNumber) {
    
    const char * const noteArraySharps[] = {
        
 //Ocatve                                 //Note Numbers
/*-1 */            "" ,  ""  ,  "" ,  ""  ,  "" ,  "" ,  "" ,   "" ,   "" ,  "" ,  ""  ,  "" ,
/* 0 */           "C0", "C#0", "D0", "D#0", "E0", "F0", "F#0", "G0", "G#0", "A0", "A#0", "B0",
/* 1 */           "C1", "C#1", "D1", "D#1", "E1", "F1", "F#1", "G1", "G#1", "A1", "A#1", "B1",
/* 2 */           "C2", "C#2", "D2", "D#2", "E2", "F2", "F#2", "G2", "G#2", "A2", "A#2", "B2",
/* 3 */           "C3", "C#3", "D3", "D#3", "E3", "F3", "F#3", "G3", "G#3", "A3", "A#3", "B3",
/* 4 */           "C4", "C#4", "D4", "D#4", "E4", "F4", "F#4", "G4", "G#4", "A4", "A#4", "B4",
/* 5 */           "C5", "C#5", "D5", "D#5", "E5", "F5", "F#5", "G5", "G#5", "A5", "A#5", "B5",
/* 6 */           "C6", "C#6", "D6", "D#6", "E6", "F6", "F#6", "G6", "G#6", "A6", "A#6", "B6",
/* 7 */           "C7", "C#7", "D7", "D#7", "E7", "F7", "F#7", "G7", "G#7", "A7", "A#7", "B7",
/* 8 */           "C8", "C#8", "D8", "D#8", "E8", "F8", "F#8", "G8", "G#8", "A8", "A#8", "B8",
/* 9 */           "C9", "C#9", "D9", "D#9", "E9", "F9", "F#9", "G9", "G#9", "A9", "A#9", "B9",
/* 10 */          "C10", "C#10", "D10", "D#10", "E10", "F10", "F#10", "G10", "G#10", "A10", "A#10", "B10"
        
    };
    return noteArraySharps[midiNumber];
}

-(NSString*)noteStringForMidiNumber : (int)number
{

    const char* string  = noteForMidiNumber(number);
    
    NSString * midiString = [NSString stringWithUTF8String:string];
    return midiString;
    

}



-(void) stop
{
    OSStatus result = noErr;
    
    if (_musicPlayer )
    {
        if (_Playing) {
        
        result = MusicPlayerStop(_musicPlayer);
        }
        result = DisposeMusicPlayer(_musicPlayer);
        
        _musicPlayer=nullptr;
    }
    

    if (musicSequence)
    {
    UInt32 trackCount;
    MusicSequenceGetTrackCount(musicSequence, &trackCount);
    
    MusicTrack track;
    for(int i=0;i<trackCount;i++)
    {
        MusicSequenceGetIndTrack (musicSequence, i, &track);
        result = MusicSequenceDisposeTrack(musicSequence, track);
    }
        result = DisposeMusicSequence(musicSequence);
        musicSequence= nullptr;
    }
    
}

-(Float64)timeStampToBeatStamp:(Float32)timeStamp {
    
    Float32 SingleBeatTime = MSPM / _tempoTrackBpm ;
        
    Float64 BeatTimestamp = timeStamp / SingleBeatTime;
    
    return BeatTimestamp;
         
}


//This is called to tell the sequence to use the built-in synth
- (void) useMIDIEndpoint
{
	if (_MidiEndPoint) //and instance variable
	{
		
		OSStatus err;
        
        err = MusicSequenceSetMIDIEndpoint(musicSequence, _MidiEndPoint);
		//midiEndpoint = nil;
			}
	
}
/*

//This is called to tell the sequence to use the endpoint with unique ID uid
//and seems to work ok.
- (id) useMIDIEndpoint:(SInt32) uid
{
	if (!midiEndpoint)
	{
		MIDIObjectRef endpoint;
		MIDIObjectType type;
		OSStatus err = MIDIObjectFindByUniqueID(uid, &endpoint, &type);
		if (!err && (type == kMIDIObjectType_ExternalDestination || type ==
                     kMIDIObjectType_Destination))
		{
			midiEndpoint = (MIDIEndpointRef) endpoint;
			Boolean wasPlaying;
			if (wasPlaying = [self isPlaying])
			{
				[self stop];
			}
			err = MusicSequenceSetMIDIEndpoint(sequence, midiEndpoint);
			err = MusicPlayerPreroll(player);
			if (wasPlaying)
			{
				[self play];
			}
		}
	}
	return self;
}
 */
/*
double ticksToSeconds(int ticks)
{
    double beats = double(ticks) / self->timeResolution;//ticksperbeat=timerResolution
    double seconds = beats / (beatsPerMinute / 60.f);
    return seconds;
}

double secondsToTicks(float seconds)
{
    double ticksPerSecond = (beatsPerMinute * ticksPerBeat) / 60.f;
    double ticks = ticksPerSecond * seconds;
    return (int)ticks;
}
 */
@end

