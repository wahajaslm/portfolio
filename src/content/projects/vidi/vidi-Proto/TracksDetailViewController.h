//
//  TracksDetailViewController.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 02/08/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TracksDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *PlayView;
@property (weak, nonatomic) IBOutlet UIView *TitleView;
@property (weak, nonatomic) IBOutlet UIView *PauseView;

@property (weak, nonatomic) IBOutlet UIView *DeleteView;
@property (weak, nonatomic) IBOutlet UIView *ShareView;
- (IBAction)PlayPressed:(id)sender;
@end
