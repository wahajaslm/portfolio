//
//  QuanTempViewController.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 14/05/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "QuanTempViewController.h"


@interface QuanTempViewController ()

@end

@implementation QuanTempViewController

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
 
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"tick" withExtension: @"aif"];
    
    // Store the URL as a CFURLRef instance
    soundFileURLRef = (__bridge CFURLRef) tapSound;
    
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (soundFileURLRef, &soundFileObject);
    
    
    
    _tempoTextField.delegate= self;
    _tempoTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    // Do any additional setup after loading the view from its nib.
    _viewQuanTemp.hidden = YES;
    
    vidiSequence = [VidiSequence sharedInstance];
    
    _Tempo = DTempo;
    vidiSequence.tempoTrackBpm = _Tempo;
    _tempoTextField.text= [NSString stringWithFormat:@"%d" ,_Tempo ];
    
    vidiSequence.TSNumerator = DefaultTimeSignature;
    vidiSequence.TSDenominator = DefaultTimeSignature;
    
    [self initPickerArrays];
    
    self.TimeSignaturePicker.delegate=self;
    self.TimeSignaturePicker.dataSource=self;
    self.TempoPicker.delegate=self;
    self.TempoPicker.dataSource=self;
    
    [self.TempoPicker selectRow:(_Tempo-5) inComponent:0 animated:true];
    
    UInt8 DeafultBeatRow = 3;
    UInt8 DeafultBarRow = 2;
    [self.TimeSignaturePicker selectRow:DeafultBeatRow inComponent:0 animated:true ];
    [self.TimeSignaturePicker selectRow:DeafultBarRow inComponent:1 animated:true ];

    numerator=DeafultBeatRow;
     }


- (void)initPickerArrays
{
    
    self.DenominatorArray  = [[NSArray alloc]  initWithObjects:@"1",@"2",@"4",@"8",@"16",@"32",@"64" , nil];
    
    self.NumeratorArray  = [[NSMutableArray alloc]  init];
    self.TempoArray =[[NSMutableArray alloc]init];
    
    for (UInt8 i = 1; i <= 99; i++)
    {
        NSString *name = [NSString stringWithFormat:@"%d",i];
        [self.NumeratorArray addObject:name];
    }
    
    for (int i = 5; i <= 990; i++)
    {
        NSString *name = [NSString stringWithFormat:@"%d",i];
        [self.TempoArray addObject:name];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}






// pragma mark is used for easy access of code in Xcode
#pragma mark - TextField Delegates

// This method is called once we click inside the textField
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"Text field did begin editing");
}

// This method is called once we complete editing
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    NSInteger integer= [textField.text integerValue];
    _Tempo = (int)integer;
    NSLog(@"Text field ended editing  %d", _Tempo );
    
    vidiSequence.tempoTrackBpm = _Tempo;
    
    [self.TempoPicker selectRow:(_Tempo-5) inComponent:0 animated:true];
    
}

// This method enables or disables the processing of return key
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
   
    NSString *stringValue = textField.text;
    NSInteger integer = [stringValue intValue];
    if (integer <23 || integer > 103)
        // You can make the text red here for example
        return NO;
    else
    {
        NSLog(@"Num %ld", (long)integer);
        return YES;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    

    
    NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:@"0123456789.\n"] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basicTest = [string isEqualToString:filtered];

    NSInteger v = [textField.text integerValue];

    
    if(!basicTest && (v<5 || v>120))
    {
        
        return NO;
    }
    
    return YES;
}


- (IBAction)tempoIncrease:(id)sender{
    
    _Tempo++;
    
  if (_Tempo > MaxTempo)
      
  {
      _Tempo = MaxTempo;
  }
   
    NSLog(@"Text field ended editing  %d", _Tempo );
    
    _tempoTextField.text= [NSString stringWithFormat:@"%d" ,_Tempo ];
     vidiSequence.tempoTrackBpm = _Tempo;
     [self.TempoPicker selectRow:(_Tempo-5) inComponent:0 animated:true];
    [self MetronomeTimerConfig];
}

- (IBAction)tempoDecrease:(id)sender {
    
    _Tempo--;
    
    if (_Tempo < MinTempo)
        
    {
        _Tempo = MinTempo;
    }
    
    NSLog(@"Text field ended editing  %d", _Tempo );
    
    _tempoTextField.text= [NSString stringWithFormat:@"%d" ,_Tempo ];
     vidiSequence.tempoTrackBpm = _Tempo;
   
    [self.TempoPicker selectRow:(_Tempo-5) inComponent:0 animated:true];
    [self MetronomeTimerConfig];
}



- (IBAction)btnbackpressed:(id)sender {
    _viewQuanTemp.hidden = YES;
}

- (IBAction)btnQuantizePressed:(id)sender {
}

- (IBAction)btntempopressed:(id)sender {
    _viewQuanTemp.hidden = NO;
}

#pragma PickerDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView == self.TempoPicker) {
        return 1;
    }
    else
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (pickerView == self.TempoPicker)
    {
        
        return [self.TempoArray count];
        
        
    }
    
    else
    {
    
    if (component ==0)
        
        return [self.NumeratorArray count];
    
    else
        return [self.DenominatorArray count];
    }
}

#pragma PickerDelegate

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    if (pickerView == self.TempoPicker)
    {
        
        return [self.TempoArray objectAtIndex:row ];
    }

    else{
    if (component==0) {
        
        
          return [self.NumeratorArray objectAtIndex:row];
        
    }
    
    else
        return [self.DenominatorArray objectAtIndex:row];
    }
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    
    if (pickerView == self.TempoPicker)
    {
        
        _Tempo = [[self.TempoArray objectAtIndex:row] intValue];
        _tempoTextField.text= [NSString stringWithFormat:@"%d" ,_Tempo ];
        vidiSequence.tempoTrackBpm = _Tempo;
        
        [self MetronomeTimerConfig];
    }
    
    else
    {
        if(component == 0)
        {
            vidiSequence.TSNumerator = [[self.NumeratorArray objectAtIndex:row]intValue];
            numerator = vidiSequence.TSNumerator;
        }
        else
        {
            vidiSequence.TSDenominator = [[self.DenominatorArray objectAtIndex:row]intValue];
        }
    
    }
    
  }

- (IBAction)HeadPhonePressed:(id)sender {
 
 //   UIButton* button = (UIButton*)sender;
  
    if (!_btnHeadPhones.selected)
    {
        
        [self setStartMetronomeTimer];
        _btnHeadPhones.selected = !_btnHeadPhones.selected;
        
        MetronomeTickTimeRunning = true;
        
    }
    
    else
    {
        [self stopMetronomeTimer];
        
        _btnHeadPhones.selected = !_btnHeadPhones.selected;
        
        MetronomeTickTimeRunning = false;
            }
    
}




-(void)MetronomeTimerConfig{


if (MetronomeTickTimeRunning)
{
    [self stopMetronomeTimer];
    
    [self setStartMetronomeTimer];
}

}


-(void)setStartMetronomeTimer{

if (!self.timer || MetronomeTickTimeRunning )

{
    // Calculate the timer interval based on the tempo in beats per minute
    double interval = 60.0 / _Tempo;
    
    // Start the repeating timer that counts the beats.
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(tick:) userInfo:
              [NSNumber numberWithDouble:interval * (numerator / 2)] repeats:YES];
    
}
}
-(void)stopMetronomeTimer
{
if (_timer)
{
    [_timer invalidate];
    _timer = nil;
}
}

#pragma mark - NSTimer actions

- (void)tick:(NSTimer *)timer {
    // Update the display. Oh yeah, and tick!
   // [display tick:(NSNumber *)timer.userInfo];
    AudioServicesPlaySystemSound(soundFileObject);
}


@end
