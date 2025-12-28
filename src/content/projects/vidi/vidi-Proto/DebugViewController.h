//
//  DebugViewController.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 27/06/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BufferManager.h"
#import "channel.h"
#import "analysisdata.h"

@interface DebugViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *DebugView;

@property (weak, nonatomic) IBOutlet UILabel *chunk;
@property (weak, nonatomic) IBOutlet UILabel *period;
@property (weak, nonatomic) IBOutlet UILabel *fundamentalFreq;
@property (weak, nonatomic) IBOutlet UILabel *pitch;
@property (weak, nonatomic) IBOutlet UILabel *pitchSum;
@property (weak, nonatomic) IBOutlet UILabel *pitch2Sum;
@property (weak, nonatomic) IBOutlet UILabel *freqCentroid;
@property (weak, nonatomic) IBOutlet UILabel *shortTermMean;
@property (weak, nonatomic) IBOutlet UILabel *shortTermDeviation;
@property (weak, nonatomic) IBOutlet UILabel *longTermMean;
@property (weak, nonatomic) IBOutlet UILabel *longTermDeviation;
@property (weak, nonatomic) IBOutlet UILabel *highestCorelationIndex;
@property (weak, nonatomic) IBOutlet UILabel *chosenCorrelationIndex;

@property (weak, nonatomic) IBOutlet UILabel *periodicOctaveEstimate;
@property (weak, nonatomic) IBOutlet UILabel *noteIndex;
@property (weak, nonatomic) IBOutlet UILabel *done;
@property (weak, nonatomic) IBOutlet UILabel *reason;
@property (weak, nonatomic) IBOutlet UILabel *notePlaying;
- (void)SetupDebugView:(BufferManager*) bufferManager;


@end
