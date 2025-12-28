//
//  SimpleSelectionViewController.h
//  NetworkMIDI

#import <UIKit/UIKit.h>

@protocol SimpleSelectionViewControllerDelegate;

@interface SimpleSelectionViewController : UITableViewController {
    __strong NSArray *names;
    __strong NSArray *values;
    __strong NSArray *descriptions;
}

@property (nonatomic, weak) id<SimpleSelectionViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;

- (void) reloadData:(id)sender;
+ (SimpleSelectionViewController *) showInNavigationController:(UINavigationController*)controller withDelegate:(id<SimpleSelectionViewControllerDelegate>) aDelegate withTag:(NSUInteger)aTag;

@end

@protocol SimpleSelectionViewControllerDelegate <NSObject>

@required

- (NSString*) titleForController:(SimpleSelectionViewController*)controller;
- (NSArray*) namesForController:(SimpleSelectionViewController*)controller;
- (NSArray*) valuesForController:(SimpleSelectionViewController*)controller;
- (BOOL) isSelectedValue:(id)value forController:(SimpleSelectionViewController*)controller;
- (void) didSelectValue:(id)value forController:(SimpleSelectionViewController*)controller;
- (void) didFinish:(SimpleSelectionViewController*)controller;

@optional

- (NSArray*) descriptionsForController:(SimpleSelectionViewController*)controller;
- (BOOL) supportsMultipleSelectionForController:(SimpleSelectionViewController*)controller;

@end
