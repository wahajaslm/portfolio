/*
 
     File: FFTHelper.cpp
 Abstract: This class demonstrates how to use the Accelerate framework to take Fast Fourier Transforms (FFT) of the audio data. FFTs are used to perform analysis on the captured audio data
 
 */

#include "FFTHelper.h"
#include "musicnotes.h"
// Utility includes
#include "CABitOperations.h"
#include "analysisdata.h"
using std::ios;

//const Float32 kAdjust0DB = 1.5849e-13;


FFTHelper::FFTHelper(BufferManager*bufferManager, UInt32 inMaxFramesPerSlice ): mSpectrumAnalysis(NULL),mSpectrumAnalysisAutoCorr(NULL),
_bufferManager(bufferManager),
mFFTNormFactor(20.0/(2*inMaxFramesPerSlice)),
mFFTLength(inMaxFramesPerSlice/2),
mFFTInputLength(inMaxFramesPerSlice),
mLog2N(Log2Ceil(inMaxFramesPerSlice)),
k(mFFTInputLength/2),
size(mFFTInputLength+k),
sizeFFT(size/2),
chunk(0)

{
   
    mAutoCorrLog2N=Log2Ceil(size);
    mAutoCorrFFTNormFactor= (20.0/(2*size));
    mDspSplitComplex.realp = (Float32*) calloc(mFFTLength,sizeof(Float32));
    mDspSplitComplex.imagp = (Float32*) calloc(mFFTLength, sizeof(Float32));
    mDspSplitComplexAutoCorr.realp=(Float32*) calloc(sizeFFT,sizeof(Float32));
    mDspSplitComplexAutoCorr.imagp=(Float32*) calloc(sizeFFT,sizeof(Float32));
  
    
    mSpectrumAnalysis = vDSP_create_fftsetup(mLog2N, kFFTRadix2);
    
    
    nsdfBuf= (Float32*) calloc(mFFTLength, sizeof(Float32));
    inAudioDataNsdf = (Float32*) calloc(mFFTInputLength,sizeof(Float32)); //[0............1023] stft window buffer
    autocorrTime = (Float32*) calloc(size, sizeof(Float32));
    autocorrNsdfOutput = (Float32*) calloc(k, sizeof(Float32));
    autocorrFFT = (Float32*) calloc(sizeFFT, sizeof(Float32));
    
    
    
    hanningWindow = (Float32*) calloc(mFFTInputLength ,sizeof(Float32)); //Allocate space for hanning window
    //generate the window values and store them in hanningWindow
    vDSP_hann_window(hanningWindow,mFFTInputLength,0);

}


FFTHelper::~FFTHelper()
{
    vDSP_destroy_fftsetup(mSpectrumAnalysis);
    vDSP_destroy_fftsetup(mSpectrumAnalysisAutoCorr);

    free (mDspSplitComplex.realp);
    free (mDspSplitComplex.imagp);
    
    free (mDspSplitComplexAutoCorr.realp);
    free (mDspSplitComplexAutoCorr.imagp);
}


void FFTHelper::Pitch_CHPS(Float32 * InputFFTMag, Float32* OutPutVector)

{
    //HPS Parameters
    Float32 *TempHps=new float[mFFTLength];
    Float32 *Hps=new float[mFFTLength];
    int Harmonic=15;
    
    //Cepstrum Parameters
   // Float32 * Mag= new Float32[mFFTLength];
   // Float32 * Cepstrum=new Float32[mFFTLength];
   // Float32 * LogMag=new Float32[mFFTLength];
   // Float32 * CurrentPhase = new Float32[mFFTLength];
    DSPSplitComplex * tempSplitComplex = new DSPSplitComplex;
    tempSplitComplex->realp=new Float32[mFFTLength];
    tempSplitComplex->imagp=new Float32[mFFTLength];
   // DSPComplex * tempComplex= new DSPComplex ;
    
    ////////////////////////////////////////////////////////////Cepstrum//////////////////
  /*
    
    vDSP_zvabs(InputSplitComplex, 1, Mag, 1, mFFTLength);
    vDSP_zvphas(InputSplitComplex, 1,CurrentPhase, 1, mFFTLength);
    
  */
    /*
    for (int i=0; i<mFFTLength; i++)
    {
        LogMag[i]=logf(InputFFTMag[i]);
    }
  
    tempSplitComplex->realp=LogMag;
    tempSplitComplex->imagp=CurrentPhase;
    
    vDSP_ztoc(tempSplitComplex, 1, tempComplex, 1, mFFTLength);
    vDSP_rect((float*)tempComplex, 1, (float*)tempComplex, 1, mFFTLength);
    vDSP_ctoz(tempComplex, 1, tempSplitComplex, 1, mFFTLength);
    
    // ----------------------------------------------------------------
    // Do Inverse FFT
    
    // Do complex->real inverse FFT.
    vDSP_fft_zrip(mSpectrumAnalysis, tempSplitComplex, 1, mLog2N, kFFTDirection_Inverse);
    
    // This leaves result in packed format. Here we unpack it into a real vector.
    vDSP_ztoc(tempSplitComplex, 1, (DSPComplex*)Cepstrum, 1, mFFTLength);
    
    // Neither the forward nor inverse FFT d;oes any scaling. Here we compensate for that.
    float scale = 0.5/mFFTLength    ;
    vDSP_vsmul(Cepstrum, 1, &scale, Cepstrum, 1, mFFTLength);
    
    */
    
    //////////////////////////////////////////// HPS ////////////////////////////////////////
   // Hps=Mag;
    
    for (int n=1; n<=Harmonic ; n++)
    {
        int number=floorf(mFFTLength/n);
        
        memset(TempHps,0,mFFTLength *sizeof(float));
        
        for (int x=0 ; x<number; x++)
        {
            int FIC=x*n;
            TempHps[x]=InputFFTMag[FIC];
            
        }
        
        vDSP_vmul(TempHps, 1, Hps, 1, Hps, 1, mFFTLength);
        
    }
    
    for (int i=0; i<mFFTLength; i++) {
        Hps[i]=logf(Hps[i]);
    }
    
    
    //////////////////////////////////////////////////////////CHPS///////////
    
    
    memcpy(Hps, OutPutVector, mFFTLength);
    
  //  vDSP_vmul(Hps , 1, Cepstrum, 1, OutPutVector, 1, mFFTLength);
    
    
    
}


void FFTHelper::AdvanceProcessing(Float32 *outFFTData)
{
    
 
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
        
}
    

void FFTHelper::AudioProcessingSystem(int chunk , Channel * ch )
{
    Float32 *output = ch->nsdfData.begin();

    Float32*inAudioData   = _bufferManager->mFFTInputBuffer;
    Float32* mFFTSpectrum = _bufferManager->mFFTSpectrum;
    Float32* mLogSpectrum = _bufferManager->mLogPowerSpectrum;
    Float32* mCepstrum =_bufferManager->mCepstrum;
    Float32* outFFTData = _bufferManager->mFFTOutputBuffer;
    
    std::vector<int> nsdfMaxPositions;
    
    myassert(ch);
    myassert(ch->dataAtChunk(chunk));
    AnalysisData &analysisData = *ch->dataAtChunk(chunk);
    AnalysisData *prevAnalysisData = ch->dataAtChunk(chunk-1);
 //   float *curInput = (ch->equalLoudness) ? ch->filteredInput.begin() : ch->directInput.begin();
    
 //   analysisData.maxIntensityDB() = linear2dB(fabs(*std::max_element(curInput, curInput+mFFTInputLength, absoluteLess<float>())));
    
	if (inAudioData == NULL || outFFTData == NULL) return;
   
    memcpy(inAudioDataNsdf, inAudioData, mFFTInputLength*sizeof(Float32));

    
    
    vDSP_vmul(inAudioData, 1, hanningWindow, 1, inAudioData, 1, mFFTInputLength);
       //Generate a split complex vector from the real data
    vDSP_ctoz((COMPLEX *)inAudioData, 2, &mDspSplitComplex, 1, mFFTLength);
    
    //Take the fft and scale appropriately
    vDSP_fft_zrip(mSpectrumAnalysis, &mDspSplitComplex, 1, mLog2N, kFFTDirection_Forward);
    vDSP_vsmul(mDspSplitComplex.realp, 1, &mFFTNormFactor, mDspSplitComplex.realp, 1, mFFTLength);
    vDSP_vsmul(mDspSplitComplex.imagp, 1, &mFFTNormFactor, mDspSplitComplex.imagp, 1, mFFTLength);
    
    //Zero out the nyquist value
    mDspSplitComplex.imagp[0] = 0.0;


    
    
    /* "Cepstrum" is a play on the word spectrum as one might suspect and is simply a spectrum of a spectrum. The original time signal is transformed using a Fast Fourier Transform (FFT) algorithm and the resulting spectrum is converted to a logarithmic scale. This log scale spectrum is then transformed using the same FFT algorithm to obtain the power cepstrum.
    
    */
   
    //Convert the fft data to dB
    vDSP_zvmags(&mDspSplitComplex, 1, mFFTSpectrum, 1, mFFTLength);
    
    
   /* log(1 + |X(f)|)*/
    for (int i=0; i<mFFTLength; i++)
    {
        //Taking log of each element
        mLogSpectrum[i]= log10f(1+ mFFTSpectrum[i]);
    }
    
    
    
    // save this into spectrum buffer
    memcpy(mDspSplitComplex.realp, mLogSpectrum, mFFTLength*sizeof(Float32));
    
    //Generate a split complex vector from the real data
  //  vDSP_ctoz((COMPLEX *)interimBuffer, 2, &mDspSplitComplex, 1, mFFTLength);
    bzero(mDspSplitComplex.imagp, (mFFTLength) * sizeof(Float32));
   // mDspSplitComplex.imagp[0] = 0.0;

    vDSP_fft_zrip(mSpectrumAnalysis, &mDspSplitComplex, 1, mLog2N, kFFTDirection_Inverse);
    //convert complex split to real
    vDSP_ztoc(&mDspSplitComplex, 1, (COMPLEX*)mCepstrum, 2, mFFTLength);

    // Normalize
    float scale = 1.f/mCepstrum[0];
    vDSP_vsmul(mCepstrum, 1, &scale, mCepstrum, 1, mFFTInputLength);
    
    cepstrumIndex = findNSDFsubMaximum(mCepstrum, mFFTLength, CepstrumThreshold);
    cepstrumPitch=freq2pitch((ch->chSampleRate/cepstrumIndex));
    // NSLog(@"cepstrum pith: %d ",cepstrumPitch);
    
    //NSLog(@"cepstrumPitch: %d ",cepstrumPitch);
    //analysisData.cepstrumIndex = findCepstrumMaximum(dataTime, nDiv2, 0.8f);
    analysisData.cepstrumIndex = cepstrumIndex;
    analysisData.cepstrumPitch = cepstrumPitch;
    
    
    /*
    
    ///Calculate/////////////////////////////////////////////////////////////////////////////// NSDF /////////////////////////////////////////////////////////////
                                                  */
    double logrms =linear2dB(nsdf(inAudioDataNsdf,ch->nsdfData.begin()) / double(mFFTInputLength)); /**< Do the NSDF calculation */
    analysisData.logrms() = logrms;
  /*
    if(gdata->doingAutoNoiseFloor() && !analysisData.done) {
        //do it for gdata. this is only here for old code. remove some stage
        if(chunk == 0) { gdata->rmsFloor() = 0.0; gdata->rmsCeiling() = gdata->dBFloor(); }
        if(logrms+15 < gdata->rmsFloor()) gdata->rmsFloor() = logrms+15;
        if(logrms > gdata->rmsCeiling()) gdata->rmsCeiling() = logrms;
    }
    */
    analysisData.freqCentroid() = calcFreqCentroidFromLogMagnitudes(mLogSpectrum, mFFTLength);
    
    if(prevAnalysisData)
        analysisData.deltaFreqCentroid() = bound(fabs(analysisData.freqCentroid() - prevAnalysisData->freqCentroid())*20.0, 0.0, 1.0);
    else
        analysisData.deltaFreqCentroid() = 0.0;
    
    findNSDFMaxima(ch->nsdfData.begin(), k, nsdfMaxPositions);
    
    
    
    //store some of the best period estimates
    analysisData.periodEstimates.clear();
    analysisData.periodEstimatesAmp.clear();
   
    //float smallCutoff = 0.5;
    
    for(std::vector<int>::iterator iter = nsdfMaxPositions.begin(); iter < nsdfMaxPositions.end(); iter++)
    {
        if(output[*iter] >= NsdfsmallCutoff)
        {
            //analysisData.periodEstimatesAmp.push_back(output[*iter]); //TODO: These should be calculated more accurately
            float x, y;
            //do a parabola fit to find the maximum
            parabolaTurningPoint2(output[*iter-1], output[*iter], output[*iter+1], float(*iter + 1), &x, &y);
            y = bound(y, -1.0f, 1.0f);
            analysisData.periodEstimates.push_back(x);
            analysisData.periodEstimatesAmp.push_back(y);
        }
        
    }
    
    float periodDiff = 0.0f;
    
    if(analysisData.periodEstimates.empty())
    { //no period found
        analysisData.correlation() = 0.0f;
      //  analysisData.calcScores();
      // analysisData.done = true;
    }
    
 /////////////////////////////////////////////////////////////
    else
    {
        //calc the periodDiff
        if(chunk > 0 && (prevAnalysisData->highestCorrelationIndex!=-1))
        {
            if (prevAnalysisData->periodEstimates.size()!=0)
            {
                
            float prevPeriod = prevAnalysisData->periodEstimates[prevAnalysisData->highestCorrelationIndex];
            std::vector<float>::iterator closestIter = binary_search_closest(analysisData.periodEstimates.begin(), analysisData.periodEstimates.end(), prevPeriod);
            periodDiff = *closestIter - prevPeriod;
            if(absolute(periodDiff) > 8.0f) periodDiff = 0.0f;
            }
        }
        int nsdfMaxIndex = int(std::max_element(analysisData.periodEstimatesAmp.begin(), analysisData.periodEstimatesAmp.end())-analysisData.periodEstimatesAmp.begin());
        
        analysisData.highestCorrelationIndex = nsdfMaxIndex;

        if(!analysisData.done)
        {
            
           /* if MPM_MODIFIED_CEPSTRUM*/
            
            ch->chooseCorrelationIndex(chunk, float(analysisData.cepstrumIndex)); //calculate pitch
            ch->calcDeviation(chunk);
            
        }
        
        analysisData.changeness() = 0.0f;
        
    }
    
 //////////////////////////////////////////////////////////////////
   
    //float periodDiff = 0.0f;
    if(chunk >=0)//1st time through
    {
        //periodDiff = ch->calcDetailedPitch(curInput, analysisData.period, chunk);
        float periodDiff2 = ch->calcDetailedPitch(inAudioDataNsdf, analysisData.period, chunk);
        //printf("chunk=%d, %f, %f\n", chunk, periodDiff, periodDiff2);
        periodDiff = periodDiff2;
        
        ch->pitchLookup.push_back(ch->detailedPitchData.begin(), ch->detailedPitchData.size());
        ch->pitchLookupSmoothed.push_back(ch->detailedPitchDataSmoothed.begin(), ch->detailedPitchDataSmoothed.size());
        /*      float periodDiff1 = (rate / pitch2freq(ch->detailedPitchData.back()));
         float periodDiff2 = (rate / pitch2freq(ch->detailedPitchData.front()));
         periodDiff = periodDiff1 - periodDiff2;
         printf("%f, %f, %f\n", periodDiff1, periodDiff2, periodDiff);
         */
    }
    
   /* else if (chunk>0)
    {
    //   ch->pitchLookup.copyTo(ch->detailedPitchData.begin(), chunk*ch->detailedPitchData.size(), ch->detailedPitchData.size());
     //  ch->pitchLookupSmoothed.copyTo(ch->detailedPitchDataSmoothed.begin(), chunk*ch->detailedPitchDataSmoothed.size(), ch->detailedPitchDataSmoothed.size());
    }
    */
    
    if(!analysisData.done)
    {
       analysisData.calcScores();
       ch->processNoteDecisions(chunk, periodDiff);
       analysisData.done = true;
    }
   

/*

    if(!analysisDatadone)

   {
    int j;
    //calc rms by hand
    double rms = 0.0;
    for(j=0; j<n; j++) {
        rms += sq(dataTime[j]);
    }
    //analysisData.rms = sqrt(analysisData.rms);
    analysisData.logrms() = linear2dB(rms / float(n));
    analysisData.calcScores();
    analysisData.done = true;
}

}
*/
}

/** @return The index of the first sub maximum.
 This is now scaled from (threshold * overallMax) to 0.
 */
int FFTHelper::findNSDFsubMaximum(float *input, int len, float threshold)
{
    std::vector<int> indices;
    int overallMaxIndex = findNSDFMaxima(input, len, indices);
    threshold += (1.0 - threshold) * (1.0 - input[overallMaxIndex]);
    float cutoff = input[overallMaxIndex] * threshold;
    for(uint j=0; j<indices.size(); j++) {
        if(input[indices[j]] >= cutoff)
            return indices[j];
    }
    //should never get here
    return 0; //stop the compiler warning
}



/*
Float32 FFTHelper::freq2pitch(double freq)
{
	//From log rules  log_b(x) = log_a(x) / log_a(b)
	//return 69 + 39.8631371386483481*log10(freq / 440);
	return -36.3763165622959152488 + 39.8631371386483481*log10(freq);
}
*/
    /**
     Find the highest maxima between each pair of positive zero crossings.
     Including the highest maxima between the last +ve zero crossing and the end if any.
     Ignoring the first (which is at zero)
     In this diagram the disired maxima are marked with a *
     
     *             *
     \      *     /\      *     /\
     _\____/\____/__\/\__/\____/__
     \  /  \  /      \/  \  /
     \/    \/            \/
     
     @param input The array to look for maxima in
     @param len Then length of the input array
     @param maxPositions The resulting maxima positions are pushed back to this vector
     @return The index of the overall maximum
     */
int FFTHelper::findNSDFMaxima(float *input, int len, std::vector<int> &maxPositions)
{
        int pos = 0;
        int curMaxPos = 0;
        int overallMaxIndex = 0;
        
        while(pos < (len-1)/3 && input[pos] > 0.0f) pos++; //find the first negitive zero crossing
        while(pos < len-1 && input[pos] <= 0.0f) pos++; //loop over all the values below zero
        if(pos == 0) pos = 1; // can happen if output[0] is NAN
        
        while(pos < len-1) {
           // myassert(!(input[pos] < 0)); //don't assert on NAN
            if(input[pos] > input[pos-1] && input[pos] >= input[pos+1]) { //a local maxima
                if(curMaxPos == 0) curMaxPos = pos; //the first maxima (between zero crossings)
                else if(input[pos] > input[curMaxPos]) curMaxPos = pos; //a higher maxima (between the zero crossings)
            }
            pos++;
            if(pos < len-1 && input[pos] <= 0.0f) { //a negative zero crossing
                if(curMaxPos > 0) { //if there was a maximum
                    maxPositions.push_back(curMaxPos); //add it to the vector of maxima
                    if(overallMaxIndex == 0) overallMaxIndex = curMaxPos;
                    else if(input[curMaxPos] > input[overallMaxIndex]) overallMaxIndex = curMaxPos;
                    curMaxPos = 0; //clear the maximum position, so we start looking for a new ones
                }
                while(pos < len-1 && input[pos] <= 0.0f) pos++; //loop over all the values below zero
            }
        }
        
        if(curMaxPos > 0) { //if there was a maximum in the last part
            maxPositions.push_back(curMaxPos); //add it to the vector of maxima
            if(overallMaxIndex == 0) overallMaxIndex = curMaxPos;
            else if(input[curMaxPos] > input[overallMaxIndex]) overallMaxIndex = curMaxPos;
            curMaxPos = 0; //clear the maximum position, so we start looking for a new ones
        }
        return overallMaxIndex;
}
    


/** The Normalised Square Difference Function.
 @param input. An array of length n, in which the ASDF is taken
 @param ouput. This should be an array of length k
 @return The sum of square
 */
double FFTHelper::nsdf(float *input, float *output)
{
    double sumSq = autocorr(input, output); //the sum of squares of the input
    
    //double sumRightSq = sumSq, sumLeftSq = sumSq;
    double totalSumSq = sumSq * 2.0;
  
          for(int j=0; j<k; j++)
          {
          
            totalSumSq  -= pow(input[mFFTInputLength-1-j],2) + pow(input[j],2);
            //dividing by zero is very slow, so deal with it seperately
            if(totalSumSq > 0.0) output[j] *= 2.0 / totalSumSq;
            else output[j] = 0.0;
          }
    
    return sumSq;
}






/** Performs an autocorrelation on the input via FFT
 @param input An array of length n, in which the autocorrelation is taken
 @param ouput This should be an array of length k.
 This is the correlation of the signal with itself
 for delays 1 to k (stored in elements 0 to k-1)
 @return The sum of squares of the input. (ie the zero delay correlation)
 Note: Use the init function to set values of n and k before calling this.
 */
double FFTHelper::autocorr(Float32 *input, Float32 *output)
{
   // myassert(beenInit);
    int fsize = int(size);
    
    //pack the data into an array which is zero padded by k elements
    memcpy(autocorrTime, input, mFFTInputLength* sizeof(Float32));
    memset((autocorrTime+mFFTInputLength), 0, k *sizeof(Float32));
    

    
    //Do a forward FFT
    
    //Generate a split complex vector from the real data
    vDSP_ctoz((COMPLEX *)autocorrTime, 2, &mDspSplitComplexAutoCorr, 1, sizeFFT);   //1536
    
    
    //Take the fft and scale appropriately
    vDSP_fft_zrip(mSpectrumAnalysis, &mDspSplitComplexAutoCorr, 1, mLog2N , kFFTDirection_Forward);
       //Zero out the nyquist value
    mDspSplitComplexAutoCorr.imagp[0] = 0.0;

    //calculate the (real*real + ima*imag) for each coefficient
    //Note: The numbers are packed in half_complex form (refer fftw)
    //ie. R[0], R[1], R[2], ... R[size/2], I[(size+1)/2+1], ... I[3], I[2], I[1]
    
    vDSP_zvmags(&mDspSplitComplexAutoCorr, 1, autocorrFFT, 1, sizeFFT);
  
    
    //Do an inverse FFT
    // save this into spectrum buffer
    memcpy(mDspSplitComplexAutoCorr.realp, autocorrFFT, sizeFFT*sizeof(Float32));
    //Generate a split complex vector from the real data
   bzero(mDspSplitComplexAutoCorr.imagp, sizeFFT * sizeof(Float32));
    
    vDSP_fft_zrip(mSpectrumAnalysis, &mDspSplitComplexAutoCorr, 1, mLog2N, kFFTDirection_Inverse);
    //convert complex split to real
    vDSP_ztoc(&mDspSplitComplexAutoCorr, 1, (COMPLEX*)autocorrTime, 2, sizeFFT);
   
    
    for(float *p1=output, *p2=autocorrTime+1; p1<output+k;)
        *p1++ = *p2++ / fsize;
    
    
    return double(autocorrTime[0]) / double(size);
}


void FFTHelper::parabolaTurningPoint2(float y_1, float y0, float y1, float xOffset, float *x, float *y)
{
	float yTop = y_1 - y1;
	float yBottom = y1 + y_1 - 2 * y0;
	if(yBottom != 0.0) {
		*x = xOffset + yTop / (2 * yBottom);
		*y = y0 - ((yTop*yTop) / (8 * yBottom));
	} else {
		*x = xOffset;
		*y = y0;
	}
}

float FFTHelper::bound(float var, float lowerBound, float upperBound)
{
    /*
     if(var < lowerBound) var = lowerBound;
     if(var > upperBound) var = upperBound;
     return var;
     */
    //this way will deal with NAN, setting it to lowerBound
    if(var >= lowerBound) {
        if(var <= upperBound) return var;
        else return upperBound;
    } else return lowerBound;
}



double FFTHelper::calcFreqCentroidFromLogMagnitudes(float *buffer, int len)
{
    double centroid = 0.0;
    double totalWeight = 0.0;
    for(int j=1; j<len; j++) { //ignore the end freq bins, ie j=0
        //calculate centroid
        centroid += double(j)*buffer[j];
        totalWeight += buffer[j];
    }
    return centroid;
    //if(centroid == 0.0) return 0.0;
    //return centroid / (totalWeight * double(len));
}
