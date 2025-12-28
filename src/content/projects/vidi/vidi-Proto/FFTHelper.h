/*
 
     File: FFTHelper.h
 Abstract: This class demonstrates how to use the Accelerate framework to take Fast Fourier Transforms (FFT) of the audio data. FFTs are used to perform analysis on the captured audio data
 
 */

#ifndef __aurioTouch3__FFTHelper__
#define __aurioTouch3__FFTHelper__


#include <Accelerate/Accelerate.h>
#import "NetworkMidiController.h"
#include <vector>
#include <math.h>
#include <algorithm>
#include <numeric>
#include <float.h>
#include "channel.h"
#include "gdata.h"

//#include "analysisdata.h"
#import "BufferManager.h"

class BufferManager;

class FFTHelper
{
public:
    GData * gdata;
    FFTHelper(BufferManager*bufferManager, UInt32 inMaxFramesPerSlice );
    ~FFTHelper();
    BufferManager* bufferManager ;
    void AudioProcessingSystem( int chunk , Channel * ch );
    void AdvanceProcessing(Float32 *outFFTData);
    void  Pitch_CHPS(Float32 * InputFFTMag, Float32* OutPutVector);
    void ModifiedCepstrumAnalysis(Float32* inAudioData, Float32* outFFTData);
    int  findNSDFsubMaximum(Float32 *input, int len, float threshold);
    int  findNSDFMaxima(float *input, int len, std::vector<int> &maxPositions);
    void  nsdf(Float32 *input , int len ,Float32 *output);
    void peakpicking(Float32 * input , int len) ;
    double nsdf(float *input, float *output);
    double autocorr(float *input, float *output);
    void parabolaTurningPoint2(float y_1, float y0, float y1, float xOffset, float *x, float *y);
    float bound(float var, float lowerBound, float upperBound);
    bool chooseCorrelationIndex(int chunk, float periodOctaveEstimate);
    static double calcFreqCentroidFromLogMagnitudes(float *buffer, int len);

    BufferManager * _bufferManager;
    float NsdfsmallCutoff = 0.5;
    float CepstrumThreshold = 0.5;
private:
    FFTSetup            mSpectrumAnalysis,mSpectrumAnalysisAutoCorr;
    DSPSplitComplex     mDspSplitComplex,mDspSplitComplexAutoCorr;
    Float32             mFFTNormFactor,mAutoCorrFFTNormFactor;
    UInt32              mFFTLength;
    UInt32              mFFTInputLength;
    UInt32              mLog2N,mAutoCorrLog2N,m_whichfftindex;
    UInt32              k,size,sizeFFT; //Lag factor for autocorelation
    Float32*            STFTWin;
    Float32*            hanningWindow;
    Float32             *nsdfBuf,*autocorrTime,*autocorrFFT,*autocorrNsdfOutput,*inAudioDataNsdf;

    float period; /*< The period of the fundamental (in samples) */
    float fundamentalFreq; /*< The fundamental frequency in hertz */
    float pitch; /*< The pitch in semi-tones */
    bool    analysisDatadone;
    int cepstrumIndex,cepstrumPitch;
    int highestCorrelationIndex = -1;
    int chosenCorrelationIndex = -1;
    int chunk;
    std::vector<float> periodEstimates;
    std::vector<float> periodEstimatesAmp;
    UInt32  CurrentNote,PreviousNote=0;
    float CurrentMag,PreviousMag=0;
};

#endif /* defined(__aurioTouch3__FFTHelper__) */
