//
//  SettingsViewController.h
//  NetworkMIDI


#import <UIKit/UIKit.h>
#import "SimpleSelectionViewController.h"
@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, SimpleSelectionViewControllerDelegate>

@property (nonatomic, weak) id <SettingsViewControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction)done:(id)sender;

@end


@protocol SettingsViewControllerDelegate
- (void)settingsViewControllerDidFinish:(SettingsViewController *)controller;
@end
