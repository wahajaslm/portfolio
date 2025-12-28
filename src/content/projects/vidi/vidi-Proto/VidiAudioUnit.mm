//
//  VidiAudioUnit.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 20/05/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "VidiAudioUnit.h"
#import "CAXException.h"

@implementation VidiAudioUnit

@synthesize RemoteIoUnit;
@synthesize unitIsRunning;
@synthesize unitHasBeenCreated;
@synthesize RenderCallbackStruct;


- (id)init
{
    self = [super init];
    
    if (self)
    {
        fftBufferManager = new FFTBufferManager(1024);/////1024
        self->dcFilter = new DCRejectionFilter[vidiStreamBasicDescription.NumberChannels()];
        RenderCallbackStruct.inputProc=RemoteIoRenderCallbackFunction;
        RenderCallbackStruct.inputProcRefCon = (__bridge void*)self;
    }
    
    return self;
}

-(void)SetupAudioUnit

{
 	try {
        
		// Describe audio component
		AudioComponentDescription desc;
		desc.componentType = kAudioUnitType_Output;
		desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
		desc.componentManufacturer = kAudioUnitManufacturer_Apple;
		desc.componentFlags = 0;
		desc.componentFlagsMask = 0;
		
        
        // Get component
		AudioComponent inputComponent = AudioComponentFindNext(NULL, &desc);
		
        
        // Get audio units
		XThrowIfError(
        AudioComponentInstanceNew(inputComponent, &RemoteIoUnit), "couldn't open the remote I/O unit");
        
		
        // Enable IO for recording
        UInt32 enable = 1;
        UInt32 disable=0;
        
        
        
        // Enable IO for recording
        XThrowIfError(
                      AudioUnitSetProperty(RemoteIoUnit,
                                           kAudioOutputUnitProperty_EnableIO,
                                           kAudioUnitScope_Input,
                                           InputBus,
                                           &enable,
                                           sizeof(enable)),
                      "couldn't enable input on the remote I/O unit");
        
        // Enable AGC
        XThrowIfError(
                      AudioUnitSetProperty(RemoteIoUnit,
                                           kAUVoiceIOProperty_VoiceProcessingEnableAGC,
                                           kAudioUnitScope_Global,
                                           InputBus,
                                           &enable,
                                           sizeof(enable)),
                      "couldn't enable input on the remote I/O unit");
       

        
        // Enable IO for playback
        XThrowIfError(
                      AudioUnitSetProperty(RemoteIoUnit,
                                           kAudioOutputUnitProperty_EnableIO,
                                           kAudioUnitScope_Output,
                                           OutputBus,
                                           &disable,
                                           sizeof(disable)),
                      "couldn't disable input on the remote I/O unit");
        
        
        
        
        // set our required format - LPCM non-interleaved 32 bit floating point
        AudioStreamBasicDescription outFormat;
  
        
        /*
         double inSampleRate,
         UInt32 inFormatID,
         UInt32 inBytesPerPacket,
         UInt32 inFramesPerPacket,
         UInt32 inBytesPerFrame,
         UInt32 inChannelsPerFrame,
         UInt32 inBitsPerChannel,
         UInt32 inFormatFlags);
         */
        /*
         We need to specifie our format on which we want to work.
         We use Linear PCM cause its uncompressed and we work on raw data.
         for more informations check.
         
         We want 16 bits, 2 bytes per packet/frames at 44khz
         */
        
        /*
        outFormat=CAStreamBasicDescription(44100.00,
                                             kAudioFormatLinearPCM,
                                             4,
                                             1,
                                             4,
                                             1,
                                             32,
                                            kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat | kAudioFormatFlagIsNonInterleaved);
*/
        outFormat.mSampleRate			= 44100.00;
        outFormat.mFormatID			= kAudioFormatLinearPCM;
        outFormat.mFormatFlags		= kAudioFormatFlagsCanonical;
        outFormat.mFramesPerPacket	= 1;
        outFormat.mChannelsPerFrame	= 1;
        outFormat.mBitsPerChannel	= 16;
        outFormat.mBytesPerPacket	= 2;
        outFormat.mBytesPerFrame	= 2;

        // Apply format
        XThrowIfError(
                      AudioUnitSetProperty(RemoteIoUnit,
                                           kAudioUnitProperty_StreamFormat,
                                           kAudioUnitScope_Output,
                                           InputBus,
                                           &outFormat,
                                           sizeof(outFormat)),
                      "couldn't set the remote I/O unit's input client format");
        
        

        XThrowIfError(
        AudioUnitSetProperty(RemoteIoUnit,
                             kAudioUnitProperty_StreamFormat,
                             kAudioUnitScope_Input,
                             OutputBus,
                             &outFormat,
                             sizeof(outFormat)),
                      "couldn't set the remote I/O unit's output client format");
        
        
	       
        
        // Set input callback
		XThrowIfError(
                      AudioUnitSetProperty(RemoteIoUnit,
                                           kAudioOutputUnitProperty_SetInputCallback,
                                           kAudioUnitScope_Global,
                                           InputBus,
                                           &RenderCallbackStruct,
                                           sizeof(RenderCallbackStruct)),
                      "couldn't set remote i/o render callback");
		
        /*
         we need to tell the audio unit to allocate the render buffer,
         that we can directly write into it.
         */
		XThrowIfError(
        AudioUnitSetProperty(RemoteIoUnit,
                                      kAudioUnitProperty_ShouldAllocateBuffer,
                                      kAudioUnitScope_Output,
                                      InputBus,
                                      &disable,
                                      sizeof(disable)),"couldn't set buffer");
        
        
        
        
        
        /*
        we set the number of channels to mono and allocate our block size to
        1024 bytes.
        */
        audioBuffer.mNumberChannels = 1;
        audioBuffer.mDataByteSize = 512 * 2;
        audioBuffer.mData = malloc( 512 * 2 );
        
        
        
        
        
        
        
        
		XThrowIfError(AudioUnitInitialize(RemoteIoUnit), "couldn't initialize the remote I/O unit");
	}
	catch (CAXException &e) {
		char buf[256];
		fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
			}
	catch (...)
    {
		fprintf(stderr, "An unknown error occurred\n");
		
	
	}
}

-(void)StartRemoteIO
{

    try
    {
        XThrowIfError(AudioOutputUnitStart(RemoteIoUnit), "couldn't start unit");
        self.unitIsRunning = true;

    }
    catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }

    
}
-(void)stop;
{
    try
    {
        XThrowIfError(AudioOutputUnitStop(RemoteIoUnit), "couldn't stop unit");
        self.unitIsRunning = true;
        
    }
    catch (CAXException e) {
        char buf[256];
        fprintf(stderr, "Error: %s (%s)\n", e.mOperation, e.FormatError(buf));
    }
    

    
}
        
        
        
static OSStatus	RemoteIoRenderCallbackFunction(
                                               void						*inRefCon,
                                               AudioUnitRenderActionFlags 	*ioActionFlags,
                                               const AudioTimeStamp 		*inTimeStamp,
                                               UInt32 						inBusNumber,
                                               UInt32 						inNumberFrames,
                                               AudioBufferList 			*ioData)
{

 /*
 on this point we define the number of channels, which is mono
 for the iphone. the number of frames is usally 512 or 1024.
 */
    // the data gets rendered here
    AudioBuffer buffer;
    
    buffer.mDataByteSize = inNumberFrames * 2; // sample size
    buffer.mNumberChannels = 1; // one channel
    buffer.mData = malloc( inNumberFrames * 2 ); // buffer size
    
    // we put our buffer into a bufferlist array for rendering
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0] = buffer;
    

    VidiAudioUnit *THIS = (__bridge VidiAudioUnit *)inRefCon;
	
    OSStatus err = AudioUnitRender(THIS->RemoteIoUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames,&bufferList);
    	if (err)
        {
            printf("RemoteIoRenderCallbackFunction %d\n", (int)err); return err; }
	
    
    // process the bufferlist in the audio processor
    [THIS processBuffer:&bufferList];
    
    // clean up the buffer
    free(bufferList.mBuffers[0].mData);
    
    
    
    
    
	 //Remove DC component
    //	for(UInt32 i = 0; i < ioData->mNumberBuffers; ++i)
    //		THIS->dcFilter[i].InplaceFilter((Float32*)(ioData->mBuffers[i].mData), inNumberFrames);
	
    //Convert the floating point audio data to integer (Q7.24)
    //   err = AudioConverterConvertComplexBuffer(THIS->audioConverter, inNumberFrames, ioData, THIS->drawABL);
    //  if (err) { printf("AudioConverterConvertComplexBuffer: error %d\n", (int)err); return err; }
    
    // if (THIS->fftBufferManager == NULL) return noErr;
    
     // if (THIS->fftBufferManager->NeedsNewAudioData())
       // THIS->fftBufferManager->GrabAudioData(ioData);
	
    return noErr;
    
}



#pragma mark processing

-(void)processBuffer: (AudioBufferList*) audioBufferList
{
    AudioBuffer sourceBuffer = audioBufferList->mBuffers[0];
    
    // we check here if the input data byte size has changed
    if (audioBuffer.mDataByteSize != sourceBuffer.mDataByteSize) {
        // clear old buffer
        free(audioBuffer.mData);
        // assing new byte size and allocate them on mData
        audioBuffer.mDataByteSize = sourceBuffer.mDataByteSize;
        audioBuffer.mData = malloc(sourceBuffer.mDataByteSize);
    }
    
    
    /**
     Here we modify the raw data buffer now.
     In my example this is a simple input volume gain.
     iOS 5 has this on board now, but as example quite good.
     */
    SInt16 *editBuffer = (SInt16*)audioBufferList->mBuffers[0].mData;
    
    // loop over every packet
    for (int nb = 0; nb < audioBuffer.mDataByteSize; nb++) {
        NSLog(@"Data : %hd",editBuffer[nb]);
        
              }
    }

@end
