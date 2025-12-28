//
//  AdvancedSettingViewController.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 09/08/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "AdvancedSettingViewController.h"

@interface AdvancedSettingViewController ()

@end

@implementation AdvancedSettingViewController

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

    bufferManager = [[AudioController sharedInstance]getBufferManagerInstance];
    channel = bufferManager->channel;


    _SlNSDF.value=  bufferManager->mFFTHelper->NsdfsmallCutoff;
    _LbNsdf.text= [NSString stringWithFormat:@"%f",_SlNSDF.value];
    
    _SlCepstrum.value=bufferManager->mFFTHelper->CepstrumThreshold;
    _LbCepstrum.text= [NSString stringWithFormat:@"%f",_SlCepstrum.value];
    
    _SlShTime.value=channel->shortTime;
    _LbShortTime.text= [NSString stringWithFormat:@"%f",_SlShTime.value];
    
    _SlShBase.value = channel->shortBase;
    _LbShortBase.text= [NSString stringWithFormat:@"%f",_SlShBase.value];
    
     _SlShStretch.value =channel->shortStretch;
    _LbShortStretch.text= [NSString stringWithFormat:@"%f",_SlShStretch.value];
    
    _SlLoTime.value=channel->longTime;
    _LbLongTime.text= [NSString stringWithFormat:@"%f",_SlLoTime.value];
    
    _SlLoBase.value =channel->longBase ;
    _LbLongBase.text= [NSString stringWithFormat:@"%f",_SlLoBase.value];
    
     _SlLoStretch.value=channel->longStretch ;
    _LbLongStretch.text= [NSString stringWithFormat:@"%f",_SlLoStretch.value];
    
     _TChunks.value=channel->NoteNumChunks ;
    _LbTChunks.text= [NSString stringWithFormat:@"%f",_TChunks.value];
    
    channel->DiffParam = _DiffParam.value;
    _LbDiffParam.text= [NSString stringWithFormat:@"%f",_DiffParam.value];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






- (IBAction)SliderValueChanged:(id)sender {

    
    switch ([sender tag] ) {
      
        case enum_NSDF:
            
            bufferManager->mFFTHelper->NsdfsmallCutoff = _SlNSDF.value;
            _LbNsdf.text= [NSString stringWithFormat:@"%f",_SlNSDF.value];
            break;
        
        case enum_Cepstrum :
            bufferManager->mFFTHelper->CepstrumThreshold = _SlCepstrum.value;
            _LbCepstrum.text= [NSString stringWithFormat:@"%f",_SlCepstrum.value];
            
            
            break;
        
        case enum_ShortTime:
       
            channel->shortTime = _SlShTime.value;
            _LbShortTime.text= [NSString stringWithFormat:@"%f",_SlShTime.value];
            
            break;
        
        case enum_ShortBase:
        
            channel->shortBase = _SlShBase.value;
          
            _LbShortBase.text= [NSString stringWithFormat:@"%f",_SlShBase.value];
            
            break;
        
        case enum_ShortStretch:
            channel->shortStretch = _SlShStretch.value;
        
            _LbShortStretch.text= [NSString stringWithFormat:@"%f",_SlShStretch.value];
            
            break;
        
        case enum_LongTime:
            channel->longTime = _SlLoTime.value;
            _LbLongTime.text= [NSString stringWithFormat:@"%f",_SlLoTime.value];
            
            break;
        
        case enum_LongBase:
            channel->longBase = _SlLoBase.value;
            _LbLongBase.text= [NSString stringWithFormat:@"%f",_SlLoBase.value];
            
            break;
        
        case enum_LongStretch:
            channel->longStretch = _SlLoStretch.value;
            _LbLongStretch.text= [NSString stringWithFormat:@"%f",_SlLoStretch.value];
            
            break;
     
        case enum_Tchunks:
            channel->NoteNumChunks = _TChunks.value;
            _LbTChunks.text= [NSString stringWithFormat:@"%f",_TChunks.value];
            
            break;
            
        case enum_DiffParam:
            channel->DiffParam = _DiffParam.value;
            _LbDiffParam.text= [NSString stringWithFormat:@"%f",_DiffParam.value];
            
            break;
            
        default:
            break;
    }
}
@end
