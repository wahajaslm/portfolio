/***************************************************************************
                          channel.h  -  description
                             -------------------
    begin                : Sat Jul 10 2004
    copyright            : (C) 2004-2005 by Philip McLeod
    email                : pmcleod@cs.otago.ac.nz
 
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   Please read LICENSE.txt for details.
 ***************************************************************************/

#ifndef CHANNEL_H
#define CHANNEL_H

#include "array1d.h"
#include "array2d.h"
#include <vector>
#include "analysisdata.h"
#include "notedata.h"
#include "large_vector.h"
#include "Filter.h"
#include "fast_smooth.h"
#include "BufferManager.h"
#include "gdata.h"
#include "useful.h"

class BufferManager;

class Channel/* : public Array1d<float>*/
{
private:

  BufferManager *parent;

    
  float freq; /**< Channel's frequency */
  int _pitch_method;
  bool visible;
  bool noteIsPlaying;
  int framesperchunk;
  double timeperchunk;
  
  large_vector<AnalysisData> lookup;
  float _threshold;
    
  bool isLocked;
  fast_smooth *fastSmooth;

public:
  large_vector<float> pitchLookup;
  large_vector<float> pitchLookupSmoothed;
  Array1d<float> directInput;
  Array1d<float> filteredInput;
  Array1d<float> coefficients_table;
  Array1d<float> nsdfData;
  Array1d<float> nsdfAggregateData;
  Array1d<float> nsdfAggregateDataScaled;
  double nsdfAggregateRoof; //keeps the sum of scalers. i.e. The highest possible aggregate value
  Array1d<float> fftData1;
  Array1d<float> fftData2;
  Array1d<float> fftData3;
  Array1d<float> cepstrumData;
  Array1d<float> detailedPitchData;
  Array1d<float> detailedPitchDataSmoothed;
  large_vector<NoteData> noteData;
  Filter *highPassFilter;
  Filter *pitchSmallSmoothingFilter;
  Filter *pitchBigSmoothingFilter;
  double rmsFloor; //in dB
  double rmsCeiling; //in dB
  double chSampleRate;

  bool equalLoudness;
  
  //Channel();
  Channel(BufferManager *parent_, int size_, int k_=0);
  
  virtual ~Channel();
  float *begin() { return directInput.begin(); }
  float *end() { return directInput.end(); }
  int size() { return directInput.size(); }
  float &at(int pos) { return directInput.at(pos); }
  virtual void resize(int newSize, int k_=0);
  virtual void shift_left(int n);
  void setParent(BufferManager *parent_) { parent = parent_; }

  int curChunk=0;
  int framesPerChunk() { return framesperchunk; }
  void SetframesPerChunk(UInt32 frames) { framesperchunk=frames; }
  void setPitchMethod(int pitch_method) { _pitch_method = pitch_method; }
  int pitchMethod() { return _pitch_method; }
  void calc_last_n_coefficients(int n);
  void processNewChunk(FilterState *filterState);
  void processChunk(int chunk);
  bool isVisible() { return visible; }
  void setVisible(bool state=true) { visible = state; }
  void reset();
  void   setTimePerChunk(double timechunk){timeperchunk = timechunk;}
  double   chRate() { return chSampleRate ;}
  void   setChSampleRate(double samplerate){chSampleRate = samplerate;}
  double timePerChunk() { return timeperchunk; }
  int previousnote;
  int totalChunks() { return (int)lookup.size(); }
  double timeAtChunk(int chunk) { return double(chunk) * timePerChunk(); }

    //  double finishTime() { return startTime() + totalTime(); }
  double totalTime() { return double(MAX(totalChunks()-1, 0)) * timePerChunk(); }
 // void jumpToTime(double t) { parent->jumpToTime(t); }
 // int chunkAtTime(double t) { return parent->chunkAtTime(t); }/
//  double chunkFractionAtTime(double t) { return parent->chunkFractionAtTime(t); }
//  int chunkAtCurrentTime() { return parent->chunkAtCurrentTime(); }
  int currentChunk() { return curChunk; } //this one should be use to retrieve current info
 
  
  AnalysisData *dataAtChunk(int chunk) { return (isValidChunk(chunk)) ? &lookup[chunk] : NULL; }
  AnalysisData *dataAtCurrentChunk() { return dataAtChunk(currentChunk()); }
 // AnalysisData *dataAtTime(double t) { return dataAtChunk(chunkAtTime(t)); }
  large_vector<AnalysisData>::iterator dataIteratorAtChunk(int chunk) { return lookup.iterator_at(chunk); }
  
  bool hasAnalysisData() { return !lookup.empty(); }
  bool isValidChunk(int chunk) { return (chunk >= 0); }
 // bool isValidTime(double t) { return isValidChunk(chunkAtTime(t)); }
  //bool isValidCurrentTime() { return isValidChunk(chunkAtCurrentTime()); }
  
  float averagePitch(int begin, int end);
  float averageMaxCorrelation(int begin, int end);

  float threshold() { return _threshold; }
  void setIntThreshold(int thresholdPercentage) { _threshold = float(thresholdPercentage) / 100.0f; }
  void resetIntThreshold(int thresholdPercentage);
  
  bool isNotePlaying() { return noteIsPlaying; }
  bool isVisibleNote(int noteIndex_);
  bool isVisibleChunk(int chunk_) { return isVisibleChunk(dataAtChunk(chunk_)); }
  bool isVisibleChunk(AnalysisData *data);
  bool isChangingChunk(AnalysisData *data);
  bool isNoteChanging(int chunk);
  bool isLabelNote(int noteIndex_);
  void recalcScoreThresholds();

  
  
  NoteData *getLastNote();
  NoteData *getCurrentNote();
  NoteData *getNote(int noteIndex);
  int getCurrentNoteIndex() { return int(noteData.size())-1; }
  void backTrackNoteChange(int chunk);
  void processNoteDecisions(int chunk, float periodDiff);
  void noteBeginning(int chunk);
  void noteEnding(int chunk);
  float calcOctaveEstimate();
  void recalcNotePitches(int chunk);
  void chooseCorrelationIndex1(int chunk);
  bool chooseCorrelationIndex(int chunk, float periodOctaveEstimate);
  void calcDeviation(int chunk);
  bool isFirstChunkInNote(int chunk);
  void resetNSDFAggregate(float period);
  void addToNSDFAggregate(const float scaler, float periodDiff);
    float calcDetailedPitch(float *input, double period, int /*chunk*/);
  
  float periodOctaveEstimate(int chunk); /*< A estimate from over the whole duration of the note, to help get the correct octave */


    
     double shortTime = 1; //0.08; //0.18;
     float shortBase = 0.2f;
     float shortStretch = 0.8; //1.0f; //3.5f;
    
     double longTime = 2;
     float longBase = 0.05f; //0.1f;
     float longStretch = 0.8f; //0.3f; //1.0f;

    float NoteNumChunks =5;
    float DiffParam = 0.5;
    
    
};

/** Create a ChannelLocker on the stack, the channel will be freed automaticly when
  the ChannelLocker goes out of scope
*/
class ChannelLocker
{
  Channel *channel;
  
};

#endif
