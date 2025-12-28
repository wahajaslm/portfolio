//
//  PlotViewController.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 27/06/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "EZAudio.h"
#import "BufferManager.h"
#import "AudioController.h"
#pragma mark - Interface Components
#import "EZPlot.h"
#import "EZAudioPlot.h"
#import "EZAudioPlotGL.h"
#import "EZAudioPlotGLKViewController.h"

@interface PlotViewController : UIViewController
{
    
}


@property (strong, nonatomic) IBOutlet UIView *Plotview;

@property (weak, nonatomic) IBOutlet EZAudioPlotGL *audioPlotTime;
@property (weak, nonatomic) IBOutlet EZAudioPlot *audioPlotFreq;
@property (weak, nonatomic) IBOutlet EZAudioPlot *audioPlotLogSpectrum;
@property (weak, nonatomic) IBOutlet EZAudioPlot *audioPlotCepstrum;

-(void)SetupPlot:(BufferManager *) bufferManager;

@end
