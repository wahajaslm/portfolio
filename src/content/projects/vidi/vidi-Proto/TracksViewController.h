//
//  TracksViewController.h
//  PanScrollView
//
//  Created by Wahaj Aslam on 02/08/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VidiSequence.h"
#import "TracksDetailViewController.h"

@interface TracksViewController : UITableViewController<UITableViewDelegate,UITableViewDataSource>

{
VidiSequence * TvidiSequence;
}
@end
