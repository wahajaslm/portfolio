//
//  SchordsViewController.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 14/05/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "SchordsViewController.h"

@interface SchordsViewController ()

@end

@implementation SchordsViewController

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

    
    [_btnScales addTarget:self action:@selector(ScalesOnClick:)forControlEvents:UIControlEventTouchUpInside];
     [_btnChords addTarget:self action:@selector(ChordsOnClick:) forControlEvents:UIControlEventTouchUpInside];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnpressedScales:(id)sender {
   }

- (void) ScalesOnClick:(UIButton *)sender {
    
    
    [sender setSelected:!sender.selected];
    
    [_btnScales setBackgroundImage:[UIImage imageNamed:@"Scales Off.png"] forState:UIControlStateNormal];
    [_btnScales setBackgroundImage:[UIImage imageNamed:@"Scales On.png"] forState:UIControlStateSelected];

    
}


- (IBAction)btnPressedChords:(id)sender {

    
}
- (void) ChordsOnClick:(UIButton *)sender {
    
    [sender setSelected:!sender.selected];
   
    [_btnChords setImage:[UIImage imageNamed:@"Chords Off.png"] forState:UIControlStateNormal];
    [_btnChords setImage:[UIImage imageNamed:@"Chords On.png"] forState:UIControlStateSelected];
    
    NSLog(@"State :%lu",(unsigned long)sender.state);
}


@end
