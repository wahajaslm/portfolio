//
//  SchordsViewController.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 14/05/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <libkern/OSAtomic.h>

@interface SchordsViewController : UIViewController
{
    
}


@property (weak, nonatomic) IBOutlet UIButton *btnScales;
@property (weak, nonatomic) IBOutlet UIButton *btnChords;


- (IBAction)btnpressedScales:(id)sender;
- (IBAction)btnPressedChords:(id)sender;

@end
