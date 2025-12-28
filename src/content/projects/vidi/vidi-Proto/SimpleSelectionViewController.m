//
//  SimpleSelectionViewController.m
//  NetworkMIDI
//

#import "SimpleSelectionViewController.h"


@implementation SimpleSelectionViewController

@synthesize delegate, tag;

+ (SimpleSelectionViewController *)showInNavigationController:(UINavigationController*)controller withDelegate:(id<SimpleSelectionViewControllerDelegate>) aDelegate withTag:(NSUInteger)aTag
{
    SimpleSelectionViewController *selectionController = [[SimpleSelectionViewController alloc] initWithNibName:@"SimpleSelectionViewController"
                                                                                                         bundle:nil];
    selectionController.tag = aTag;
    selectionController.delegate = aDelegate;
    [controller pushViewController:selectionController animated:YES];
    
    return selectionController;
}    

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    
    if (self) {
        // Custom initialization
        delegate = nil;
        names = nil;
        values = nil;
        descriptions = nil;
    }
    return self;
}

- (void)releaseData
{
    names = nil;
    values = nil;
    descriptions = nil;
}

- (void) dealloc
{
    delegate = nil;
    [self releaseData];
}

- (void)checkNamesAndValues {
    if (delegate) {
        if (!names)
            names = [[delegate namesForController:self] copy];
        if (!values)
            values = [[delegate valuesForController:self] copy];
        if (!descriptions && [delegate respondsToSelector:@selector(descriptionsForController:)])
            descriptions = [[delegate descriptionsForController:self] copy];
    }
}

- (void) internalReloadData:(id)sender {
    [self releaseData];
    [self checkNamesAndValues];
    [self.tableView reloadData];
}

- (void) reloadData:(id)sender
{
    [self performSelectorOnMainThread:@selector(internalReloadData:) 
                           withObject:sender 
                        waitUntilDone:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    if (delegate)
        self.navigationItem.title = [delegate titleForController:self];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([delegate respondsToSelector:@selector(supportsMultipleSelectionForController:)] 
        && [delegate supportsMultipleSelectionForController:self]) {
        [delegate didFinish:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        [self checkNamesAndValues];
        if (names) {
            return [names count];
        }
    }
        
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SimpleCellIdentifier = @"SimpleCell";
    static NSString *DescriptionCellIdentifier = @"DescriptionCell";
    
    static NSString* CellIdentifier;
    BOOL hasDescription = NO;
    if (delegate) {
        [self checkNamesAndValues];
        if (descriptions && [descriptions count] > indexPath.row) {
            NSString* description = descriptions[indexPath.row];
            hasDescription = ![description isEqualToString:@""];
        }
    }
    
    CellIdentifier = hasDescription ? DescriptionCellIdentifier : SimpleCellIdentifier;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:hasDescription ? UITableViewCellStyleSubtitle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    BOOL selected = NO;
    if (delegate) {
        if (names && [names count] > indexPath.row)
            cell.textLabel.text = names[indexPath.row];
        if (values && [values count] > indexPath.row)
            if ([delegate isSelectedValue:values[indexPath.row] forController:self])
                selected = YES;  
        if (hasDescription)
            cell.detailTextLabel.text = descriptions[indexPath.row];
    }
    cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (delegate) {
        [self checkNamesAndValues];
        if (values && [values count] > indexPath.row)
            [delegate didSelectValue:values[indexPath.row] forController:self];
        // Momentary selection
        [[self.tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
    }
    if (![delegate respondsToSelector:@selector(supportsMultipleSelectionForController:)] 
        || ![delegate supportsMultipleSelectionForController:self]) {
        [self.navigationController popViewControllerAnimated:YES];
        [delegate didFinish:self];
    }
}

@end
