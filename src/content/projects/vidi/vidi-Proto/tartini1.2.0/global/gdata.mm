/***************************************************************************
                          gdata.cpp  -  
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
#include <stdio.h>

#include "gdata.h"
#include "Filter.h"
#include "mystring.h"
#include "channel.h"
#include "conversions.h"
#include "musicnotes.h"


int frame_window_sizes[NUM_WIN_SIZES] = { 512, 1024, 2048, 4096, 8192 };
const char *frame_window_strings[NUM_WIN_SIZES] = { "512", "1024", "2048", "4096", "8192" };

float step_sizes[NUM_STEP_SIZES] = { 1.0f, 0.5f, 0.25f, 0.2f, 0.1f, 0.05f };
const char *step_size_strings[NUM_STEP_SIZES] = { "100%", "50%", "25%", "20%", "10%", "5%" };

const char *pitch_method_strings[NUM_PITCH_METHODS] = { "FFT interpolation", "Fast-correlation",  "Correlation (squared error) 1", "Correlation (squared error) 2", "Correlation (abs error) 1", "Correlation (abs error) 2", "Correlation (multiplied) 1", "Correlation (multiplied) 2" };

const char *interpolating_type_strings[NUM_INTERPOLATING_TYPES] = { "Linear", "Cubic B-Spline", "Hermite Cubic" };
GData *gdata = NULL;

//Define the Phase function. This one is applicable to 
//accelerating sources since the phase goes as x^2.
float phase_function(float x)
{
  float phase;
  
  //phase = x*x;
  phase = x;
  return(phase);
}

GData::GData(/*int buffer_size_, int winfunc_, float step_size_*/)
{
  _polish = true;
  setDBFloor(-150.0);
  setTopPitch(128.0);
 
  amp_thresholds[AMPLITUDE_RMS][0]           = -85.0; amp_thresholds[AMPLITUDE_RMS][1]           = -0.0;
  amp_thresholds[AMPLITUDE_MAX_INTENSITY][0] = -30.0; amp_thresholds[AMPLITUDE_MAX_INTENSITY][1] = -20.0;
  amp_thresholds[AMPLITUDE_CORRELATION][0]   =  0.30; amp_thresholds[AMPLITUDE_CORRELATION][1]   =  1.00;
  amp_thresholds[FREQ_CHANGENESS][0]         =  0.50; amp_thresholds[FREQ_CHANGENESS][1]         =  0.02;
  amp_thresholds[DELTA_FREQ_CENTROID][0]     =  0.00; amp_thresholds[DELTA_FREQ_CENTROID][1]     =  0.10;
  amp_thresholds[NOTE_SCORE][0]              =  0.05; amp_thresholds[NOTE_SCORE][1]              =  0.20;
  amp_thresholds[NOTE_CHANGE_SCORE][0]       =  0.112; amp_thresholds[NOTE_CHANGE_SCORE][1]       =  0.277;

  amp_weights[0] = 0.2;
  amp_weights[1] = 0.2;
  amp_weights[2] = 0.2;
  amp_weights[3] = 0.2;
  amp_weights[4] = 0.2;
 
    activeChannel = NULL;
  _amplitudeMode = 0;
  _pitchContourMode = 0;
    _doingAutoNoiseFloor = true;
    
    peakThreshold = -60.0; //in dB
    correlationThreshold = 0.00001f; //0.5 in the other scale (log);
    frameCounter = 0;
    
    doingStuff = false; /**< Active/inactive */
    running = STREAM_STOP;
    
    interpolating_type = 2; //HERMITE_CUBIC;
    using_coefficients_table = true;
    cur_note = 0.0;

    sync_flag = 0;
    need_update = false;

    //view = new View();
    
  
    nextColorIndex = 0;
   _musicKeyType = 0; //ALL_NOTES
  _temperedType = 0; //EVEN_TEMPERED
  initMusicStuff();
}

GData::~GData()
{
   
    //Note: The soundFiles is responsible for cleaning up the data the channels point to
    channels.clear();
    
    std::vector<Filter*>::iterator fi;
    for(fi=filter_hp.begin(); fi!=filter_hp.end(); ++fi)
	    delete (*fi);
    filter_hp.clear();
    for(fi=filter_lp.begin(); fi!=filter_lp.end(); ++fi)
	    delete (*fi);

    filter_lp.clear();

  
#if 0
    free(fct_in_data);
    free(fct_out_data);
    free(fct_draw_data);
#endif

}



void GData::setTopPitch(double y)
{
  if(y != _topPitch) {
    _topPitch = y;
  }
}




int GData::getActiveIntThreshold()
{
  Channel* active = getActiveChannel();
  if(active) return toInt(active->threshold() * 75.0f);
    else return 93;
//  else return qsettings->value("Analysis/thresholdValue", 93).toInt();
}

void GData::setAmpThreshold(int mode, int index, double value)
{
  amp_thresholds[mode][index] = value;
  recalcScoreThresholds();
}

double GData::ampThreshold(int mode, int index)
{
  return amp_thresholds[mode][index];
}

void GData::setAmpWeight(int mode, double value)
{
  amp_weights[mode] = value;
  recalcScoreThresholds();
}

double GData::ampWeight(int mode)
{
  return amp_weights[mode];
}

void GData::recalcScoreThresholds()
{
  for(std::vector<Channel*>::iterator it1=channels.begin(); it1 != channels.end(); it1++) {
    (*it1)->recalcScoreThresholds();
  }
}

/*
void GData::setTemperedType(int type)
{
  if(_temperedType != type) {
    if(_temperedType == 0 && type > 0) { //remove out the minors
      //if(mainWindow->keyTypeComboBox->currentIndex() >= 2) mainWindow->keyTypeComboBox->setCurrentIndex(1);
      if(_musicKeyType >= 2) setMusicKeyType(0);
      for(int j=gMusicScales.size()-1; j>=2; j--) {
        mainWindow->keyTypeComboBox->removeItem(j);
      }
    } else if(_temperedType > 0 && type == 0) {
      QStringList s;
      for(unsigned int j=2; j<gMusicScales.size(); j++) s << gMusicScales[j].name();
      mainWindow->keyTypeComboBox->addItems(s);
    }
    _temperedType = type; emit; temperedTypeChanged(type);
  }
}
*/
void GData::setFreqA(double x)
{
	_freqA = x;
	_semitoneOffset = freq2pitch(x) - freq2pitch(440.0);
}
