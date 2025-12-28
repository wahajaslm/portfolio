//
//  PlotViewController.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 27/06/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "PlotViewController.h"

@interface PlotViewController ()

@end

@implementation PlotViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    
    

   // Customizing the audio plot's look
    // Setup time domain audio plot
    self.audioPlotTime.backgroundColor = [UIColor colorWithRed: 0.569 green: 0.88 blue: 0.478 alpha: 1];
    self.audioPlotTime.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    self.audioPlotTime.shouldFill      = YES;
    self.audioPlotTime.shouldMirror    = YES;
    self.audioPlotTime.plotType        = EZPlotTypeRolling;
    
    // Setup frequency domain audio plot
    self.audioPlotFreq.backgroundColor = [UIColor colorWithRed: 0.569 green: 0.88 blue: 0.478 alpha: 1];
    self.audioPlotFreq.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    //  self.audioPlotFreq.shouldFill      = YES;
    self.audioPlotFreq.plotType        = EZPlotTypeBuffer;
    // self.audioPlotFreq.gain            = 5;
    
    // Setup frequency domain audio plot
    self.audioPlotLogSpectrum.backgroundColor = [UIColor colorWithRed: 0.569 green: 0.88 blue: 0.478 alpha: 1];
    self.audioPlotLogSpectrum.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    //  self.audioPlotLogSpectrum.shouldFill      = YES;
    self.audioPlotLogSpectrum.plotType        = EZPlotTypeBuffer;
    //  self.audioPlotLogSpectrum.gain            = 5;
    
    // Setup frequency domain audio plot
    self.audioPlotCepstrum.backgroundColor = [UIColor colorWithRed: 0.569 green: 0.88 blue: 0.478 alpha: 1];
    self.audioPlotCepstrum.color           = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    //   self.audioPlotCepstrum.shouldFill      = YES;
    self.audioPlotCepstrum.plotType        = EZPlotTypeBuffer;
    // self.audioPlotCepstrum.gain            = 0;
    
   // NSTimeInterval timer= [audioController getBufferManagerInstance]->GetFFTInputBufferLength() /[[AVAudioSession sharedInstance] sampleRate];
    
   // [NSTimer scheduledTimerWithTimeInterval:timer  target: self
        //                           selector: @selector(SetupPlot) userInfo: nil repeats: YES];
    
    
    [self.view addSubview:_Plotview];
    
    
}

-(void)SetupPlot:(BufferManager *) bufferManager
{
    //Check and plot if input buffer is filled
    if (bufferManager->HasNewFFTData())
    {
        //Plot time domain graph
        [self updateAudioWithBufferSize:bufferManager->mFFTInputBufferLen withAudioData:bufferManager->mFFTInputBuffer];
    }
        //Check and plot if FFT buffer has been filled
       if (bufferManager->NeedsNewFFTData())
        {
            [self updateAudioWithBufferSize:bufferManager->mFFTInputBufferLen withAudioData:bufferManager->mFFTInputBuffer];
            //Plot frequency spectrum
            [self updateFFTWithBufferSize:bufferManager->GetFFTOutputBufferLength() withAudioData:bufferManager->mFFTSpectrum];
            //Plot Log spectrum
            [self updateLogSpectrumWithBufferSize:bufferManager->GetFFTOutputBufferLength() withAudioData:bufferManager->mLogPowerSpectrum];
            
            //Plot Log spectrum
            [self updateCepstrumWithBufferSize:bufferManager->GetFFTOutputBufferLength() withAudioData:bufferManager->mCepstrum];
        }
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)updateFFTWithBufferSize:(UInt32)bufferSize withAudioData:(float*)data {
    
    // Update the frequency domain plot
    [self.audioPlotFreq updateBuffer:data
                      withBufferSize:bufferSize];
    
}

-(void)updateLogSpectrumWithBufferSize:(UInt32)bufferSize withAudioData:(float*)data {
    
    // Update the frequency domain plot
    [self.audioPlotLogSpectrum updateBuffer:data
                             withBufferSize:bufferSize];
    
}

-(void)updateCepstrumWithBufferSize:(UInt32)bufferSize withAudioData:(float*)data {
    
    // Update the frequency domain plot
    [self.audioPlotCepstrum updateBuffer:data
                          withBufferSize:bufferSize];
    
}

-(void)updateAudioWithBufferSize:(UInt32)bufferSize withAudioData:(float*)data {
    
    // Update time domain plot
    [self.audioPlotTime updateBuffer:data
                      withBufferSize:bufferSize];
    
}




@end
