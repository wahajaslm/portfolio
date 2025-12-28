//
//  TracksDetailViewController.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 02/08/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "TracksDetailViewController.h"
#import "VidiSequence.h"

@interface TracksDetailViewController ()

@end

@implementation TracksDetailViewController

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

    [self initViews];
    
}

-(void)initViews
{

    _TitleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _TitleView.layer.borderWidth = 1.80f;

    
    _PlayView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _PlayView.layer.borderWidth = 1.50f;

    _PauseView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _PauseView.layer.borderWidth = 1.5f;

    _DeleteView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _DeleteView.layer.borderWidth = 1.5f;

    _ShareView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _ShareView.layer.borderWidth = 1.5f;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)PlayPressed:(id)sender {
    
    
    [[VidiSequence sharedInstance] PlayMidiFile];
}
@end
