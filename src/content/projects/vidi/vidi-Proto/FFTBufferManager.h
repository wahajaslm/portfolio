
#include <AudioToolbox/AudioToolbox.h>
#include <libkern/OSAtomic.h>
#include <Accelerate/Accelerate.h>

class FFTBufferManager
{
public:
	FFTBufferManager(UInt32 inNumberFrames);
	~FFTBufferManager();
	
	volatile int32_t	HasNewAudioData()	{ return mHasAudioData; }
	volatile int32_t	NeedsNewAudioData() { return mNeedsAudioData; }
    
	UInt32				GetNumberFrames() { return mNumberFrames; }
    
	void				GrabAudioData(AudioBufferList *inBL);
	Boolean				ComputeFFT(int32_t *outFFTData);
    void                Pitch_CHPS(DSPSplitComplex * InputSplitComplex, Float32* OutPutVector);
    void                ClearBuffer(void* buffer, UInt32 numBytes);
	
private:
	volatile int32_t	mNeedsAudioData;
	volatile int32_t	mHasAudioData;
	
    FFTSetup            mSpectrumAnalysis;
    DSPSplitComplex     mDspSplitComplex;   
    
    Float32             mFFTNormFactor;
    Float32             mAdjust0DB;
    Float32             m24BitFracScale;
	
	Float32*			mAudioBuffer;  //Pointer to the data received from call back GrabAudioData
	UInt32				mNumberFrames;
    UInt32              FrameSize;
    UInt32              mFFTLength;
    UInt32              mLog2N;
	UInt32				mAudioBufferSize;
	int32_t				mAudioBufferCurrentIndex;
    UInt32              FrameLength;
    
    UInt32              mInHopSize;    //Input Data Hope size for overlapping
    UInt32              mOutHopSize;  //Synthesised Hope Data
    UInt32              mPithScaleFac; //Pitch scaling factor
    UInt32              mPithScaleStep;

    int32_t             TStftFrames; //Total number of STFT frames that can be obtained
    Float32*            STFTWin; //Each STFT frame buffer window , 1024    
    UInt32              STFTWinSize;
    Float32*            hanningWindow;
    Float32*            PrevPhase;
    Float32*            BinPhase;
};