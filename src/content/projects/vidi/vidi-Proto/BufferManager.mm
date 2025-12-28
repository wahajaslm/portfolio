/*
 
     File: BufferManager.cpp
 Abstract: This class handles buffering of audio data that is shared between the view and audio controller

 */

#include "BufferManager.h"

#include "myassert.h"
#include "mystring.h"
#include "array1d.h"
#include "useful.h"
#include "gdata.h"
#include <algorithm>
#include "channel.h"
#include <math.h>




#define min(x,y) (x < y) ? x : y


BufferManager::BufferManager( UInt32 inMaxFramesPerSlice  , double SampleRate) :

mFFTInputBuffer(NULL),
mFFTInputBufferFrameIndex(0),
mFFTInputBufferLen(inMaxFramesPerSlice),
mHasNewFFTData(0),
mNeedsNewFFTData(0),
mFFTOutputBufferLen(mFFTInputBufferLen/2),
mFFTHelper(NULL),
samplerate(SampleRate)

{
 
    viditimer= [VidiTimer sharedInstance ];
    mFFTInputBuffer = (Float32*) calloc(inMaxFramesPerSlice, sizeof(Float32));
    mFFTOutputBuffer = (Float32*) calloc(mFFTOutputBufferLen, sizeof(Float32));
    mLogPowerSpectrum = (Float32*) calloc(mFFTOutputBufferLen, sizeof(Float32));
    mCepstrum = (Float32*) calloc(mFFTInputBufferLen, sizeof(Float32));
    mFFTSpectrum= (Float32*) calloc(mFFTOutputBufferLen, sizeof(Float32));
   
    TempOLABuffer=(Float32*) calloc(inMaxFramesPerSlice, sizeof(Float32));
    OLABuffer=(Float32*) calloc(inMaxFramesPerSlice, sizeof(Float32));
    
    channel = new Channel(this,inMaxFramesPerSlice);

    mFFTHelper = new FFTHelper(this,inMaxFramesPerSlice);
 	
    
    
    OSAtomicIncrement32Barrier(&mNeedsNewFFTData);
}


BufferManager::~BufferManager()
{
    
    free(mFFTInputBuffer);
    delete mFFTHelper; mFFTHelper = NULL;
}

void BufferManager::CopyAudioDataToFFTInputBuffer( Float32* inData, UInt32 numFrames )
{
    UInt32 framesToCopy = min(numFrames, mFFTInputBufferLen - mFFTInputBufferFrameIndex);
    memcpy(mFFTInputBuffer + mFFTInputBufferFrameIndex, inData, framesToCopy * sizeof(Float32));
    mFFTInputBufferFrameIndex += framesToCopy ;
    
    
   if (mFFTInputBufferFrameIndex >= mFFTInputBufferLen) {
      
        float scale=10;
        vDSP_vsmul(mFFTInputBuffer, 1, &scale, mFFTInputBuffer, 1, mFFTInputBufferLen);
    
      /* for(int i = 0 ; i<2 ; i++)
       {
           memcpy(TempOLABuffer+(i* 256), mFFTInputBuffer+(i* 256), mFFTInputBufferLen * sizeof(Float32));
           vDSP_vadd(OLABuffer ,1, TempOLABuffer,1, OLABuffer,1, mFFTInputBufferLen);
           memset(TempOLABuffer, 0, mFFTInputBufferLen*sizeof(Float32));
       }
    
       memcpy(mFFTInputBuffer, OLABuffer, mFFTInputBufferLen * sizeof(Float32));
       memset(OLABuffer, 0, mFFTInputBufferLen*sizeof(Float32));

      */
        OSAtomicIncrement32(&mHasNewFFTData);
        OSAtomicDecrement32(&mNeedsNewFFTData);
        }
}


void BufferManager::AudioProcessing()
{
    if (HasNewFFTData())
     
    {
    curChunk++;
    channel->processChunk(curChunk);
    
    
 //   NSString * timestamp= viditimer.TimeStamp;
  //  NSLog(@"Buffer %@", timestamp );
    
    mFFTInputBufferFrameIndex = 0;
    
    OSAtomicDecrement32Barrier(&mHasNewFFTData);
    OSAtomicIncrement32Barrier(&mNeedsNewFFTData);
    }
    
}

