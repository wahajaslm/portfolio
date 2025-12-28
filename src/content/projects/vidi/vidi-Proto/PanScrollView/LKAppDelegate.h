//
//  LKAppDelegate.h
//  PanScrollView
//

#import <UIKit/UIKit.h>

// Local includes
#import "AudioController.h"
#import "gdata.h"
#import "VidiTimer.h"

@class LKViewController;

@interface LKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LKViewController *viewController;
@property (strong, nonatomic) UINavigationController *RootNavigationController;
@property (strong, nonatomic) AudioController * audioControllerSharedInstance;
@property (assign, nonatomic) GData * gdata;
@property (strong,nonatomic)  VidiTimer * viditimer;

@end
