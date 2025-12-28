//
//  SettingsViewController.m
//  NetworkMIDI
//

//

#import "SettingsViewController.h"
#import "NetworkMidiController.h"
#import "ApplicationSettings.h"

@implementation SettingsViewController

#define SERVICE_LIST 0
#define MIDI_CHANNEL_LIST 1

#define SERVICE_SECTION 0
#define SERVICE_ROW 0

#define MIDI_SECTION 1
#define CHANNEL_ROW 0

@synthesize delegate=_delegate;

- (id)init
{
    self = [super init];
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Settings";
  //  UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                            //                    target:self
                                                              //                  action:@selector(done:)];
  //  self.navigationItem.leftBarButtonItem = doneButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reloadConnections:) 
                                                 name:MIDIControllerConnectionsChanged 
                                               object:[NetworkMidiController sharedInstance]];

}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate settingsViewControllerDidFinish:self];
}


- (IBAction)showNetworkServices:(id)sender
{
    SimpleSelectionViewController *controller = [SimpleSelectionViewController showInNavigationController:self.navigationController 
                                                                                             withDelegate:self 
                                                                                                  withTag:SERVICE_LIST];
    [[NSNotificationCenter defaultCenter] addObserver:controller 
                                             selector:@selector(reloadData:) 
                                                 name:MIDIControllerConnectionsChanged 
                                               object:[NetworkMidiController sharedInstance]];
}

- (IBAction) showMIDIChannels:(id)sender
{
    [SimpleSelectionViewController showInNavigationController:self.navigationController 
                                                 withDelegate:self 
                                                      withTag:MIDI_CHANNEL_LIST];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SERVICE_SECTION:
            switch (indexPath.row) {
                case SERVICE_ROW:
                    [self showNetworkServices:self];
                    break;
            }
            break;
        case MIDI_SECTION:
            switch (indexPath.row) {
                case CHANNEL_ROW:
                    [self showMIDIChannels:self];
                    break;
            }
            break;
    }
    
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case SERVICE_SECTION:
            return @"MIDI Connections";
        case MIDI_SECTION:
            return @"MIDI Options";
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case SERVICE_SECTION:
            return 1;
        case MIDI_SECTION:
            return 1;
        default:
            return 0;
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    return 2;    
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ValueCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 
                                       reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    switch (indexPath.section) {
        case SERVICE_SECTION:
            switch (indexPath.row) {
                case SERVICE_ROW:
                    cell.textLabel.text = @"Connected To";
                    cell.detailTextLabel.text = [[NetworkMidiController  sharedInstance] describeConnections];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
            }
            break;
        case MIDI_SECTION:
            switch (indexPath.row) {
                case CHANNEL_ROW:
                    cell.textLabel.text = @"Send/Receive On";
                    cell.detailTextLabel.text = [ApplicationSettings sharedInstance].midiChannel ? 
                    [NSString stringWithFormat:@"Channel %@", [[ApplicationSettings sharedInstance].midiChannel stringValue], nil] : @"None Selected";
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    break;
                    
                default:
                    break;
            }
            break;
    }

    return cell;
}


#pragma mark - SimpleSelectionViewControllerDelegate

- (NSString *)titleForController:(SimpleSelectionViewController *)controller
{
    switch (controller.tag) {
        case SERVICE_LIST:
            return @"Directory";
        case MIDI_CHANNEL_LIST:
            return @"MIDI Channel";
    }
    return nil;
}

- (NSArray *)namesForController:(SimpleSelectionViewController*)controller
{
    switch (controller.tag) {
        case SERVICE_LIST:
            return [[[NetworkMidiController sharedInstance] services] allKeys];
        case MIDI_CHANNEL_LIST:
            return @[@"Channel 1", @"Channel 2", @"Channel 3", @"Channel 4", @"Channel 5", @"Channel 6", @"Channel 7", @"Channel 8",
                    @"Channel 9", @"Channel 10", @"Channel 11", @"Channel 12", @"Channel 13", @"Channel 14", @"Channel 15", @"Channel 16"];
    }
    return nil;
}

- (NSArray *)valuesForController:(SimpleSelectionViewController*)controller
{
    switch (controller.tag) {
        case SERVICE_LIST:
            return [[[NetworkMidiController sharedInstance] services] allValues];
        case MIDI_CHANNEL_LIST:
            return @[@1, @2,@3,@4,@5,@6,@7,@8,
                                             @9, @10, @11, @12, @13, @14, @15, @16];
    }
    return nil;
}

- (BOOL)isSelectedValue:(id)value forController:(SimpleSelectionViewController *)controller
{
    switch (controller.tag) {
        case SERVICE_LIST:
            return [[NetworkMidiController sharedInstance] isConnected:value];
        case MIDI_CHANNEL_LIST:
            if (value) {
                NSNumber *numberValue = (NSNumber*)value;
                NSNumber *currentValue = [ApplicationSettings sharedInstance].midiChannel;
                if (currentValue && [numberValue isEqualToNumber:currentValue]) {
                    return YES;
                }
            }
            break;
    }
    return NO;
}

- (void)reloadSection:(NSUInteger)section row:(NSUInteger)row
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:row
                                           inSection:section];
    [self.tableView reloadRowsAtIndexPaths:@[path]
                           withRowAnimation:UITableViewRowAnimationFade];
}

- (void) internalReloadConnections:(id)sender
{
    [self reloadSection:SERVICE_SECTION
                    row:SERVICE_ROW];
}

- (void)reloadConnections:(id)sender
{
    [self performSelectorOnMainThread:@selector(internalReloadConnections:) 
                           withObject:sender 
                        waitUntilDone:NO];
}

- (void)didSelectValue:(id)value forController:(SimpleSelectionViewController *)controller
{
    switch (controller.tag) {
        case SERVICE_LIST:
            if (value) {
                NSNetService *service = (NSNetService*)value;
                DLog(@"Selected: %@", service);
                [[NetworkMidiController sharedInstance] toggleConnected:service];
            }            
            break;
        case MIDI_CHANNEL_LIST:
            if (value) {
                NSNumber *numberValue = (NSNumber *)value;
                NSNumber *currentValue = [ApplicationSettings sharedInstance].midiChannel;
                if (!currentValue || ![numberValue isEqualToNumber:currentValue]) {
                    [ApplicationSettings sharedInstance].midiChannel = value;
                }
            }
            break;
    }
}

- (void)didFinish:(SimpleSelectionViewController *)controller
{
    switch (controller.tag) {
        case SERVICE_LIST:
            [self reloadSection:SERVICE_SECTION row:SERVICE_ROW];
            break;
        case MIDI_CHANNEL_LIST:
            [self reloadSection:MIDI_SECTION row:CHANNEL_ROW];
            break;
    }
}

- (BOOL)supportsMultipleSelectionForController:(SimpleSelectionViewController *)controller
{
    switch (controller.tag) {
        case SERVICE_LIST:
            return YES;
        case MIDI_CHANNEL_LIST:
        default:
            return NO;
    }       
}


@end
