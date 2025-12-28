
#include "FFTBufferManager.h"
#include "CABitOperations.h"
#include "CAStreamBasicDescription.h"

#define min(x,y) (x < y) ? x : y

FFTBufferManager::FFTBufferManager(UInt32 inNumberSamples) :   //Max 

mNeedsAudioData(0),
mHasAudioData(0),
mFFTNormFactor(1.0/(2*inNumberSamples)),
mAdjust0DB(1.5849e-13),
m24BitFracScale(16777216.0f),

mFFTLength(inNumberSamples),        
mLog2N(Log2Ceil(inNumberSamples)),    // 10  (2^10=1024)

mNumberFrames(inNumberSamples),      
mAudioBufferSize(inNumberSamples * sizeof(Float32)), // 1024	4x 4 bytes
mAudioBufferCurrentIndex(0),

mPithScaleStep(1),
mPithScaleFac(2^(mPithScaleStep/12))


{
    PrevPhase=(Float32*) calloc(mFFTLength,sizeof(Float32));
    FrameLength=mFFTLength/2;
    mInHopSize=FrameLength/4; //Hope size is for the stft window 75% of Frame size
    FrameSize=FrameLength * sizeof(Float32);
    STFTWinSize=mFFTLength * sizeof(Float32); // * 4 bytes
    TStftFrames=inNumberSamples/mInHopSize; // 1024/256

    mOutHopSize=round(mInHopSize* mPithScaleFac);
    STFTWin = (Float32*) calloc(mFFTLength,sizeof(Float32)); //[0............1023] stft window buffer
    mAudioBuffer = (Float32*) calloc(mNumberFrames,sizeof(Float32));//[0...........2047] input data 
    mDspSplitComplex.realp = (Float32*) calloc(mFFTLength/2,sizeof(Float32));
    mDspSplitComplex.imagp = (Float32*) calloc(mFFTLength/2, sizeof(Float32));
    
    hanningWindow = (Float32*) calloc(mFFTLength ,sizeof(Float32)); //Allocate space for hanning window 
    //generate the window values and store them in hanningWindow
    vDSP_hann_window(hanningWindow,mFFTLength,0);
    
    BinPhase= new Float32[mFFTLength];
    
    for (int i=0; i<mFFTLength; i++) 
    {
        BinPhase[i]=(2*(M_PI)*i)/mFFTLength ;
    }
    
    mSpectrumAnalysis = vDSP_create_fftsetup(mLog2N, kFFTRadix2);
    
    OSAtomicIncrement32Barrier(&mNeedsAudioData);
    
}
    


FFTBufferManager::~FFTBufferManager()
{
    vDSP_destroy_fftsetup(mSpectrumAnalysis);
    free(mAudioBuffer);
    free (mDspSplitComplex.realp);
    free (mDspSplitComplex.imagp);
}

void FFTBufferManager::GrabAudioData(AudioBufferList *inBL)
{
	if (mAudioBufferSize < inBL->mBuffers[0].mDataByteSize)	return;
	
	UInt32 bytesToCopy = min(inBL->mBuffers[0].mDataByteSize, mAudioBufferSize - mAudioBufferCurrentIndex);
	memcpy(mAudioBuffer+mAudioBufferCurrentIndex, inBL->mBuffers[0].mData, bytesToCopy);
	
	mAudioBufferCurrentIndex += bytesToCopy / sizeof(Float32);
	if (mAudioBufferCurrentIndex >= mAudioBufferSize / sizeof(Float32))
	{
		OSAtomicIncrement32Barrier(&mHasAudioData);
		OSAtomicDecrement32Barrier(&mNeedsAudioData);
	}
}


void FFTBufferManager::Pitch_CHPS(DSPSplitComplex * InputSplitComplex, Float32* OutPutVector)

{
    //HPS Parameters
    Float32 *TempHps=new float[1024];
    Float32 *Hps=new float[1024];
    int Harmonic=5;
    
    //Cepstrum Parameters
    Float32 * Mag= new Float32[mFFTLength];
    Float32 * Cepstrum=new Float32[mFFTLength];
    Float32 * LogMag=new Float32[mFFTLength]; 
    Float32 * CurrentPhase = new Float32[mFFTLength]; 
    DSPSplitComplex * tempSplitComplex = new DSPSplitComplex;
    tempSplitComplex->realp=new Float32[mFFTLength/2];
    tempSplitComplex->imagp=new Float32[mFFTLength/2];
    DSPComplex * tempComplex= new DSPComplex ;

    ////////////////////////////////////////////////////////////Cepstrum//////////////////

    
    vDSP_zvabs(InputSplitComplex, 1, Mag, 1, mFFTLength);
    vDSP_zvphas(InputSplitComplex, 1,CurrentPhase, 1, mFFTLength);  
    

    for (int i=0; i<mFFTLength; i++) {
        LogMag[i]=logf(Mag[i]);
    }
    
    tempSplitComplex->realp=LogMag;
    tempSplitComplex->imagp=CurrentPhase;
    
    vDSP_ztoc(tempSplitComplex, 1, tempComplex, 2, mFFTLength/2);
    vDSP_rect((float*)tempComplex, 2, (float*)tempComplex, 2, mFFTLength/2);
    vDSP_ctoz(tempComplex, 2, tempSplitComplex, 1, mFFTLength/2);
    
    // ----------------------------------------------------------------
    // Do Inverse FFT
    
    // Do complex->real inverse FFT.
    vDSP_fft_zrip(mSpectrumAnalysis, tempSplitComplex, 1, mLog2N, kFFTDirection_Inverse);
    
    // This leaves result in packed format. Here we unpack it into a real vector.
    vDSP_ztoc(tempSplitComplex, 1, (DSPComplex*)Cepstrum, 2, mFFTLength/2);
    
    // Neither the forward nor inverse FFT d;oes any scaling. Here we compensate for that.
    float scale = 0.5/mFFTLength    ;
    vDSP_vsmul(Cepstrum, 1, &scale, Cepstrum, 1, mFFTLength);


    
   //////////////////////////////////////////// HPS ////////////////////////////////////////
    Hps=Mag;
    
    for (int n=1; n<=Harmonic ; n++)
    {
        int number=floorf(mFFTLength/n);
        
        memset(TempHps,0,mFFTLength *sizeof(float));
        
        for (int x=0 ; x<number; x++) 
        {
            int FIC=x*n;
        TempHps[x]=Mag[FIC];
            
        }
        
        vDSP_vmul(TempHps, 1, Hps, 1, Hps, 1, mFFTLength);

    }
    
    for (int i=0; i<mFFTLength; i++) {
        Hps[i]=logf(Hps[i]);
    }

    
    //////////////////////////////////////////////////////////CHPS///////////
    
    vDSP_vmul(Hps , 1, Cepstrum, 1, OutPutVector, 1, mFFTLength);

    

}

Boolean	FFTBufferManager::ComputeFFT(int32_t *outFFTData)
{
    
	if (HasNewAudioData())
	{
      
   
    //    DSPComplex * tempComplex= new DSPComplex ;
        Float32 *outFrame= new Float32[mFFTLength];
        Float32 MaxMag,Pitch,Pitch_Note;
        UInt32 MaxMagIndex;
        
        memset(STFTWin, 0, sizeof(Float32));
        memcpy(STFTWin , mAudioBuffer, mAudioBufferSize);
        
        vDSP_vmul(STFTWin, 1, hanningWindow, 1, STFTWin, 1, mFFTLength);
        
        
        //Generate a split complex vector from the real data
        vDSP_ctoz((COMPLEX *)STFTWin, 2, &mDspSplitComplex, 1, mFFTLength);
        
        //Take the fft and scale appropriately
        vDSP_fft_zrip(mSpectrumAnalysis, &mDspSplitComplex, 1, mLog2N, kFFTDirection_Forward);
        vDSP_vsmul(mDspSplitComplex.realp, 1, &mFFTNormFactor, mDspSplitComplex.realp, 1, mFFTLength/2);
        vDSP_vsmul(mDspSplitComplex.imagp, 1, &mFFTNormFactor, mDspSplitComplex.imagp, 1, mFFTLength/2);
        
        //Zero out the nyquist value
        mDspSplitComplex.imagp[0] = 0.0;
         
        
        
        Pitch_CHPS(&mDspSplitComplex, outFrame);
        
        vDSP_maxmgvi(outFrame, 1, &MaxMag, &MaxMagIndex, mFFTLength);
        
        
        Pitch= 8000/mFFTLength *MaxMagIndex;
        
        Pitch_Note=69 + 12* log2f(Pitch/440.0);
        
        
        
        //Vocoder
        
        /*
        Float32 * DeltaPhi = new Float32[mFFTLength]; 
        Float32 * PhaseCumulative = new Float32[mFFTLength];
        DSPComplex * tempComplex= new DSPComplex ;
        DSPSplitComplex * tempSplitComplex = new DSPSplitComplex;
        tempSplitComplex->realp=new Float32[mFFTLength/2];
        tempSplitComplex->imagp=new Float32[mFFTLength/2];
        Float32 *outFrame= new Float32[mFFTLength];
        
            
        
             
        for (int32_t Frame=0 ; Frame<=TStftFrames ; Frame++)
        {            
                   
            memset(STFTWin, 0, sizeof(Float32));
            memcpy(STFTWin , mAudioBuffer+(Frame * mInHopSize), FrameSize);
            
            vDSP_vmul(STFTWin, 1, hanningWindow, 1, STFTWin, 1, mFFTLength);
            
            
            //Generate a split complex vector from the real data
            vDSP_ctoz((COMPLEX *)STFTWin, 2, &mDspSplitComplex, 1, mFFTLength);
            
            //Take the fft and scale appropriately
            vDSP_fft_zrip(mSpectrumAnalysis, &mDspSplitComplex, 1, mLog2N, kFFTDirection_Forward);
            vDSP_vsmul(mDspSplitComplex.realp, 1, &mFFTNormFactor, mDspSplitComplex.realp, 1, mFFTLength/2);
            vDSP_vsmul(mDspSplitComplex.imagp, 1, &mFFTNormFactor, mDspSplitComplex.imagp, 1, mFFTLength/2);
            
            //Zero out the nyquist value
            mDspSplitComplex.imagp[0] = 0.0;
    
            
            
            vDSP_zvabs(&mDspSplitComplex, 1, Mag, 1, mFFTLength);
            vDSP_zvphas(&mDspSplitComplex, 1,CurrentPhase, 1, mFFTLength);    
            
            vDSP_vsub(CurrentPhase, 1, PrevPhase, 1 , DeltaPhi, 1, mFFTLength);
            vDSP_mmov(CurrentPhase, PrevPhase, mFFTLength, 1, mFFTLength, mFFTLength);
            vDSP_vsub(DeltaPhi, 1, BinPhase, 1, DeltaPhi, 1, mFFTLength);
            
            for (int i=0; i<mFFTLength; i++) 
            {
                DeltaPhi[i]=(fmodf(DeltaPhi[i]+M_PI , 2*M_PI)-M_PI)/mInHopSize;
            }
            
            //True-Frequrmcy=Bin Phase
            vDSP_vadd(BinPhase, 1, DeltaPhi, 1, DeltaPhi, 1, mFFTLength);
            
            //Hopout=1;
            vDSP_vadd(PhaseCumulative,1,DeltaPhi,1, PhaseCumulative, 1, mFFTLength);
            
            
            
            
    
           // IFFT
           tempSplitComplex->realp=Mag;
           tempSplitComplex->imagp=PhaseCumulative;
            
            
            
            vDSP_ztoc(tempSplitComplex, 1, tempComplex, 2, mFFTLength/2);
            vDSP_rect((float*)tempComplex, 2, (float*)tempComplex, 2, mFFTLength/2);
            vDSP_ctoz(tempComplex, 2, tempSplitComplex, 1, mFFTLength/2);
            
            // ----------------------------------------------------------------
            // Do Inverse FFT
            
            // Do complex->real inverse FFT.
            vDSP_fft_zrip(mSpectrumAnalysis, tempSplitComplex, 1, mLog2N, kFFTDirection_Inverse);
            
            // This leaves result in packed format. Here we unpack it into a real vector.
            vDSP_ztoc(tempSplitComplex, 1, (DSPComplex*)outFrame, 2, mFFTLength/2);
            
            // Neither the forward nor inverse FFT does any scaling. Here we compensate for that.
            float scale = 0.5/mFFTLength    ;
            vDSP_vsmul(outFrame, 1, &scale, outFrame, 1, mFFTLength);
            
            
            
          */  
            
            
          
        
        
        
        
        
        /*
        //Convert the fft data to dB
        Float32 tmpData[mFFTLength];
        vDSP_zvmags(&mDspSplitComplex, 1, tmpData, 1, mFFTLength);
        
        //In order to avoid taking log10 of zero, an adjusting factor is added in to make the minimum value equal -128dB
        vDSP_vsadd(tmpData, 1, &mAdjust0DB, tmpData, 1, mFFTLength);
        Float32 one = 1;
        vDSP_vdbcon(tmpData, 1, &one, tmpData, 1, mFFTLength, 0);
        
        //Convert floating point data to integer (Q7.24)
        vDSP_vsmul(tmpData, 1, &m24BitFracScale, tmpData, 1, mFFTLength);
        for(UInt32 i=0; i<mFFTLength; ++i)
            outFFTData[i] = (SInt32) tmpData[i];
        */
        OSAtomicDecrement32Barrier(&mHasAudioData);
		OSAtomicIncrement32Barrier(&mNeedsAudioData);
		mAudioBufferCurrentIndex = 0;
		return true;
	}
	else if (mNeedsAudioData == 0)
		OSAtomicIncrement32Barrier(&mNeedsAudioData);
	
	return false;
}
