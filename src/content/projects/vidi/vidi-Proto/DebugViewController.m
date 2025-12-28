//
//  DebugViewController.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 27/06/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "DebugViewController.h"

@interface DebugViewController ()

@end

@implementation DebugViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)SetupDebugView:(BufferManager*) bufferManager
{

    if (bufferManager->currentChunk()>=0) {
        
    Channel *ch = bufferManager->channel;
    
    AnalysisData * Adata = ch->dataAtChunk(bufferManager->currentChunk());
    
_chunk.text = [NSString stringWithFormat:@"%d" , bufferManager->currentChunk() ];
_period.text = [NSString stringWithFormat:@"%f" ,Adata->period];
_fundamentalFreq.text = [NSString stringWithFormat:@"%f" ,Adata->fundamentalFreq];
_pitch.text = [NSString stringWithFormat:@"%f" ,Adata->pitch];
_pitchSum.text = [NSString stringWithFormat:@"%f" ,Adata->pitchSum];
_pitch2Sum.text = [NSString stringWithFormat:@"%f" ,Adata->pitch2Sum];
_freqCentroid.text = [NSString stringWithFormat:@"%f" ,Adata->freqCentroid()];
_shortTermMean.text = [NSString stringWithFormat:@"%f" ,Adata->shortTermMean];
_shortTermDeviation.text = [NSString stringWithFormat:@"%f" ,Adata->shortTermDeviation];
_longTermMean.text = [NSString stringWithFormat:@"%f" ,Adata->longTermMean];
_longTermDeviation.text = [NSString stringWithFormat:@"%f" ,Adata->longTermDeviation];
_highestCorelationIndex.text = [NSString stringWithFormat:@"%d" ,Adata->highestCorrelationIndex];
_chosenCorrelationIndex.text = [NSString stringWithFormat:@"%d" ,Adata->chosenCorrelationIndex];
_periodicOctaveEstimate.text = [NSString stringWithFormat:@"%f" ,ch->periodOctaveEstimate(bufferManager->currentChunk())];

_noteIndex.text = [NSString stringWithFormat:@"%d" ,Adata->noteIndex];
_done.text = [NSString stringWithFormat:@"%s" , Adata->done ? "true" : "false"];
_reason.text = [NSString stringWithFormat:@"%d" ,Adata->reason];
_notePlaying.text = [NSString stringWithFormat:@"%s" , Adata->notePlaying ? "1" : "0"];
    }
}

@end
