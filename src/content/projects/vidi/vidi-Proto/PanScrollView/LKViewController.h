//
//  LKViewController.h
//  PanScrollView
//


#import <UIKit/UIKit.h>
#import "PitchBendViewController.h"
#import "SchordsViewController.h"
#import "QuanTempViewController.h"
#import "SettingsViewController.h"
#import "PlotViewController.h"
#import "BufferManager.h"
#import "AudioController.h"
#import "DebugViewController.h"
#import "TracksViewController.h"
#import "AdvancedSettingViewController.h"

@interface LKViewController : UIViewController<UIScrollViewDelegate>

{
    BOOL pageControlIsChangingPage;
    AudioController *audioController;
    BufferManager *bufferManager;
}
- (IBAction)TracksPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *view_content;
@property (weak, nonatomic) IBOutlet UIScrollView *PageScrollView;
@property (weak, nonatomic) IBOutlet  UIPageControl* PageControl;
@property (nonatomic, retain) NSMutableArray * viewControllerArray;

@property (nonatomic, retain) PitchBendViewController * pitchBendViewController;
@property (nonatomic, retain) SchordsViewController *schordsViewController;
@property (nonatomic, retain) QuanTempViewController *quanTempViewController;
@property (nonatomic, retain) PlotViewController *plotViewController;
@property (nonatomic, retain) DebugViewController *debugViewController;
/* PageControl */
- (IBAction)PageChanged:(UIPageControl *)sender;

- (IBAction)AdvanceSettingsPressed:(id)sender;

- (IBAction)SettingPressed:(UIButton *)sender;

@end
