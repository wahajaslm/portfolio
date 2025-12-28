//
//  AdvancedSettingViewController.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 09/08/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"
#import "BufferManager.h"
#import "channel.h"

typedef enum{
enum_NSDF,
enum_Cepstrum,
enum_ShortTime,
enum_ShortBase,
enum_ShortStretch,
enum_LongTime,
enum_LongBase,
enum_LongStretch,
enum_Tchunks,
enum_DiffParam
    
}sliderEnum;

@interface AdvancedSettingViewController : UIViewController

{

    BufferManager * bufferManager;
    Channel * channel;

}
//Peak Threshold
@property (weak, nonatomic) IBOutlet UISlider *SlNSDF;
@property (weak, nonatomic) IBOutlet UISlider *SlCepstrum;

//Short Term Params
@property (weak, nonatomic) IBOutlet UISlider *SlShTime;
@property (weak, nonatomic) IBOutlet UISlider *SlShBase;
@property (weak, nonatomic) IBOutlet UISlider *SlShStretch;

//Long Term Params
@property (weak, nonatomic) IBOutlet UISlider *SlLoTime;
@property (weak, nonatomic) IBOutlet UISlider *SlLoBase;
@property (weak, nonatomic) IBOutlet UISlider *SlLoStretch;


@property (weak, nonatomic) IBOutlet UISlider *TChunks;
@property (weak, nonatomic) IBOutlet UISlider *DiffParam;


//Value Labels
@property (weak, nonatomic) IBOutlet UILabel *LbNsdf;
@property (weak, nonatomic) IBOutlet UILabel *LbCepstrum;

@property (weak, nonatomic) IBOutlet UILabel *LbShortTime;
@property (weak, nonatomic) IBOutlet UILabel *LbShortBase;
@property (weak, nonatomic) IBOutlet UILabel *LbShortStretch;

@property (weak, nonatomic) IBOutlet UILabel *LbLongTime;
@property (weak, nonatomic) IBOutlet UILabel *LbLongBase;
@property (weak, nonatomic) IBOutlet UILabel *LbLongStretch;

@property (weak, nonatomic) IBOutlet UILabel *LbTChunks;
@property (weak, nonatomic) IBOutlet UILabel *LbDiffParam;

- (IBAction)SliderValueChanged:(id)sender;

@end
