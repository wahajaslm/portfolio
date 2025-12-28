//
//  TracksViewController.m
//  PanScrollView
//
//  Created by Wahaj Aslam on 02/08/2014.
//  Copyright (c) 2014 ljh. All rights reserved.
//

#import "TracksViewController.h"

@interface TracksViewController ()

@end

@implementation TracksViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.title = @"Tracks";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    TvidiSequence= [VidiSequence sharedInstance];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // #warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *plistpath = [documentsDirectory stringByAppendingPathComponent:@"MidiList.plist"]; //3
    
    NSMutableDictionary *plistFileDataDictionary = [[NSMutableDictionary alloc]initWithContentsOfFile:plistpath];
    
    NSMutableArray* plistMidiDataArray=[[NSMutableArray alloc]init];
    
    
    if([plistFileDataDictionary count] != 0)
    {
        
        plistMidiDataArray = [NSMutableArray arrayWithArray:(NSMutableArray*)[plistFileDataDictionary valueForKey:@"mididata"]];
        
    }
    

   // #warning Incomplete method implementation.
    // Return the number of rows in the section.
    //return [[TvidiSequence midiFileItems] count];
    
    return [plistMidiDataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
    NSString *documentsDirectory = [paths objectAtIndex:0]; //2
    NSString *plistpath = [documentsDirectory stringByAppendingPathComponent:@"MidiList.plist"]; //3
    
    NSMutableDictionary *plistFileDataDictionary = [[NSMutableDictionary alloc]initWithContentsOfFile:plistpath];
    
    NSMutableArray* plistMidiDataArray=[[NSMutableArray alloc]init];
    
   
    if([plistFileDataDictionary count] != 0)
    {
        
        plistMidiDataArray = [NSMutableArray arrayWithArray:(NSMutableArray*)[plistFileDataDictionary valueForKey:@"mididata"]];
        
    }
    
    
    //NSMutableArray* MidiData=[[NSMutableArray alloc]initWithArray:[plistMidiDataArray objectAtIndex:indexPath.row]];
    
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
   // NSString *Trackname = [[TvidiSequence midiFileItems] objectAtIndex:indexPath.row];
   
    
    NSString *Trackname = [[plistMidiDataArray objectAtIndex:0]objectAtIndex:0];
    
    cell.textLabel.text = Trackname;
    cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
   
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    TracksDetailViewController *detailViewController = [[TracksDetailViewController alloc] initWithNibName:@"TracksDetailViewController" bundle:nil];
    
    [TvidiSequence LoadSequnceFileatIndex:indexPath.row];
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}


@end
