/***************************************************************************
                          gdata.h  -  
                             -------------------
    begin                : 2003
    copyright            : (C) 2003-2005 by Philip McLeod
    email                : pmcleod@cs.otago.ac.nz
 
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   Please read LICENSE.txt for details.
 ***************************************************************************/
#ifndef GDATA_H
#define GDATA_H



#include <vector>

#include "array2d.h"
#include "useful.h"
#include "analysisdata.h"

extern int gMusicKey;

#ifndef WINDOWS
//for multi-threaded profiling
extern struct itimerval profiler_value;
extern struct itimerval profiler_ovalue;
#endif

#define STREAM_STOP     0
#define STREAM_FORWARD  1
#define STREAM_PAUSE    2
#define STREAM_UPDATE   3

#define SOUND_PLAY      0x01
#define SOUND_REC       0x02
#define SOUND_PLAY_REC  0x03

enum AnalysisModes { MPM, AUTOCORRELATION, MPM_MODIFIED_CEPSTRUM };

#define NUM_WIN_SIZES 5
extern int frame_window_sizes[NUM_WIN_SIZES];
extern const char *frame_window_strings[NUM_WIN_SIZES];

#define NUM_STEP_SIZES 6
extern float step_sizes[NUM_STEP_SIZES];
extern const char *step_size_strings[NUM_STEP_SIZES];

#define NUM_PITCH_METHODS 8
extern const char *pitch_method_strings[NUM_PITCH_METHODS];

#define NUM_INTERPOLATING_TYPES 3
extern const char *interpolating_type_strings[NUM_INTERPOLATING_TYPES];

class Channel;

class GData
{
 
    
public:
  enum SavingModes { ALWAYS_ASK, NEVER_SAVE, ALWAYS_SAVE };

  GData(/*int buffer_size_, int winfunc_, float step_size_*/);
  virtual ~GData();


  int soundMode;

  bool need_update;

  std::vector<Filter*> filter_hp; //highpass filter
  std::vector<Filter*> filter_lp; //lowpass filter
  double cur_note;
  float peakThreshold;
  float correlationThreshold;

  bool doingStuff;
  int sync_flag;

  int frameCounter;

   int interpolating_type;
  int bisection_steps;
  int fast_correlation_repeats;
  int running;
  bool using_coefficients_table;
 
  std::vector<Channel*> channels;
  int nextColorIndex;

 
  void setActiveChannel(Channel *toActive);
  Channel* getActiveChannel() { return activeChannel; }
  
private:
  Channel *activeChannel; /**< Pointer to the active channel */ 
  int _fastUpdateSpeed;
  int _slowUpdateSpeed;
  bool _polish;
  bool _showMeanVarianceBars;
  int _savingMode;
  bool _vibratoSineStyle;
  int _musicKeyType;
  int _temperedType;
  double _freqA;
  double _semitoneOffset;
  bool _doingAutoNoiseFloor;

  int _amplitudeMode;
  int _pitchContourMode;
  int _analysisType;
  double _dBFloor;
  double amp_thresholds[NUM_AMP_MODES][2];
  double amp_weights[NUM_AMP_MODES];

  
  double _leftTime; /**< The lower bound of the start times of all channels */
  double _rightTime; /**< The upper bound of the finish times of all channels */
  double _topPitch; /**< The highest possible note pitch allowed (lowest possible is 0) */

public:
    
double    totalTime() { return _rightTime - _leftTime; } /**< Returns the total number of seconds the files take up */
  double    topPitch() { return _topPitch; } /**< Returns the top note pitch the programme allows */
  void      setTopPitch(double y); /**< Allows you to specify the top note pitch the programme should allow */
   
  int       getAnalysisBufferSize(int rate);
  int       getAnalysisStepSize(int rate);
  int       amplitudeMode() { return _amplitudeMode; }
  int       pitchContourMode() { return _pitchContourMode; }
  int       fastUpdateSpeed() { return _fastUpdateSpeed; }
  int       slowUpdateSpeed() { return _slowUpdateSpeed; }
  void      setAmpThreshold(int mode, int index, double value);
  double    ampThreshold(int mode, int index);
  void      setAmpWeight(int mode, double value);
  double    ampWeight(int mode);
  int       analysisType() { return _analysisType; }
  bool      polish() { return _polish; }
  bool      showMeanVarianceBars() { return _showMeanVarianceBars; }
  int       savingMode() { return _savingMode; }

  bool      doingAutoNoiseFloor() { return _doingAutoNoiseFloor; }

  void      clearFreqLookup();
  void      clearAmplitudeLookup();
  void      recalcScoreThresholds();
  int       getActiveIntThreshold();
  double    dBFloor() { return _dBFloor; }
  void      setDBFloor(double dBFloor_) { _dBFloor = dBFloor_; }
  double&   rmsFloor() { return amp_thresholds[AMPLITUDE_RMS][0]; } //in dB
  double&   rmsCeiling() { return amp_thresholds[AMPLITUDE_RMS][1]; } //in dB

  int       musicKey()     { return gMusicKey; }
  int       musicKeyType() { return _musicKeyType; }
  int       temperedType() { return _temperedType; }
  double    freqA() { return _freqA; }
  double    semitoneOffset() { return _semitoneOffset; }

  void      activeChannelChanged(Channel *active);
  void      activeIntThresholdChanged(int thresholdPercentage);
  void      leftTimeChanged(double x);
  void      rightTimeChanged(double x);
  void      timeRangeChanged(double leftTime_, double rightTime_);
  void      channelsChanged();
  void      onChunkUpdate();

  void      musicKeyChanged(int key);
  void      musicKeyTypeChanged(int type);
  void      temperedTypeChanged(int type);

 void      setInterpolatingType(int type) { interpolating_type = type; }
  void      setBisectionSteps(int num_steps) { bisection_steps = num_steps; }
  void      setFastRepeats(int num_repeats) { fast_correlation_repeats = num_repeats; }
  void      setAmplitudeMode(int amplitudeMode);
  void      setPitchContourMode(int pitchContourMode);

 // void      setMusicKey(int key)      { if(gMusicKey != key) { gMusicKey = key; exit; musicKeyChanged(key); } }
 // void      setMusicKeyType(int type) { if(_musicKeyType != type) { _musicKeyType = type; exit; musicKeyTypeChanged(type); } }
  void      setTemperedType(int type);
  void      setFreqA(double x);
  void      setFreqA(int x) { setFreqA(double(x)); }

  void      updateActiveChunkTime(double t);
  

  void      doChunkUpdate();
};

extern GData *gdata;

#endif
