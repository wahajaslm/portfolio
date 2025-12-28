//
//  QuanTempViewController.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 14/05/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VidiSequence.h"

#define DTempo 120
#define MaxTempo 988
#define MinTempo 5

@interface QuanTempViewController : UIViewController<UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>


{
  //  int Tempo;
    VidiSequence * vidiSequence;
    CFURLRef soundFileURLRef;
    SystemSoundID soundFileObject;
    int numerator;
    BOOL  MetronomeTickTimeRunning;

    
}

- (IBAction)HeadPhonePressed:(id)sender;

@property (assign) NSTimer *timer;


@property (weak, nonatomic) IBOutlet UIButton *btnHeadPhones;
@property (weak, nonatomic) IBOutlet UIPickerView *TempoPicker;

@property (strong, nonatomic) NSMutableArray *TempoArray;

@property (strong, nonatomic) NSMutableArray *NumeratorArray;

@property (strong, nonatomic) NSArray *DenominatorArray;

@property (weak, nonatomic) IBOutlet UIPickerView *TimeSignaturePicker;
@property (weak, nonatomic) IBOutlet UITextField *tempoTextField;

@property (assign, nonatomic)  int Tempo;

@property (weak, nonatomic) IBOutlet UIView *viewQuanTemp;

@property (weak, nonatomic) IBOutlet UIButton *btnquantize;
@property (weak, nonatomic) IBOutlet UIButton *btntempo;
@property (weak, nonatomic) IBOutlet UIButton *btnTempoUp;
@property (weak, nonatomic) IBOutlet UIButton *btnTempoDown;
- (IBAction)tempoIncrease:(id)sender;
- (IBAction)tempoDecrease:(id)sender;

- (IBAction)btnbackpressed:(id)sender;

- (IBAction)btnQuantizePressed:(id)sender;
- (IBAction)btntempopressed:(id)sender;


- (void)tick:(NSTimer *)timer;


@end
    