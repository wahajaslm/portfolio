/*
 
 File: BufferManager.h
 Abstract: This class handles buffering of audio data that is shared between the view and audio controller
 */

#ifndef __vidi__BufferManager__
#define __vidi__BufferManager__

#import "VidiTimer.h"
#include <AudioToolbox/AudioToolbox.h>
#include <libkern/OSAtomic.h>
#include "gdata.h"
#include "FFTHelper.h"

class FFTHelper;
class Channel;




class BufferManager
{
public:
    BufferManager( UInt32 inMaxFramesPerSlice , double SampleRate);
    ~BufferManager();
    
    Channel*    channel;
    
    
    UInt32          mHopFrameSize, mHopSize , Frames;
    Float32*        TempOLABuffer;
    Float32*        OLABuffer;
    Float32*        mFFTInputBuffer;
    Float32*        mFFTSpectrum;
    Float32*        mFFTOutputBuffer;
    Float32*        mLogPowerSpectrum;
    Float32*        mCepstrum;
    UInt32          mFFTInputBufferFrameIndex;
    UInt32          mFFTInputBufferLen;
    UInt32          mFFTOutputBufferLen;
    volatile int32_t mHasNewFFTData;
    volatile
    
    bool            HasNewFFTData()     { return static_cast<bool>(mHasNewFFTData); };
    bool            NeedsNewFFTData()   { return static_cast<bool>(mNeedsNewFFTData); };
    
    void            CopyAudioDataToFFTInputBuffer( Float32* inData, UInt32 numFrames );
    UInt32          GetFFTOutputBufferLength() { return mFFTOutputBufferLen; }
    UInt32          GetFFTInputBufferLength() { return mFFTInputBufferLen; }
    void            AudioProcessing ();
    double          samplerate;
    int             curChunk=-1;

    VidiTimer * viditimer;
    
    double          SampleRate(){return samplerate;}
    int             currentChunk(){return curChunk;}
    UInt32          framesPerChunk(){return mFFTInputBufferLen ;}
    double          timePerChunk() { return double(framesPerChunk()/SampleRate());}
  
    
 int32_t mNeedsNewFFTData;
        
    FFTHelper*      mFFTHelper;
};

#endif /* defined(__vidi__BufferManager__) */
