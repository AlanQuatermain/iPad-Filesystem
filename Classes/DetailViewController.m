//
//  DetailViewController.m
//  iPad Filesystem
//
//  Created by Jim Dovey on 10-05-10.
//  Copyright Kobo Inc. 2010. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "CustomFormatters.h"
#import "DocumentInteractionView.h"

enum
{
	kSectionFileBasicDetails,
	kSectionFilePermissions,
	kSectionFinderInfo,
	
	kNumSections
};

static NSArray * BasicDetailKeys = nil;
static NSArray * PermissionDetailKeys = nil;
static NSArray * FinderInfoKeys = nil;

static NSDictionary * LocalizedNames = nil;

static NSSet * PermissionsNumberTypes = nil;
static NSSet * OSTypeNumberTypes = nil;
static NSSet * BooleanNumberTypes = nil;

static NSFormatter * gOSTypeFormatter = nil;
static NSFormatter * gPermissionsFormatter = nil;
static NSFormatter * gBooleanFormatter = nil;

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize toolbar, popoverController, detailItem, detailTableView, titleBarItem;
@synthesize documentInteractionController=_documentController;

+ (void) initialize
{
	if ( self != [DetailViewController class] )
		return;
	
	BasicDetailKeys = [[NSArray alloc] initWithObjects: NSFileType, NSFileSize, NSFileModificationDate, NSFileReferenceCount, NSFileDeviceIdentifier, NSFileSystemNumber, NSFileSystemFileNumber, NSFileBusy, nil];
	PermissionDetailKeys = [[NSArray alloc] initWithObjects: NSFileOwnerAccountName, NSFileOwnerAccountID, NSFileGroupOwnerAccountName, NSFileGroupOwnerAccountID, NSFilePosixPermissions, nil];
	FinderInfoKeys = [[NSArray alloc] initWithObjects: NSFileExtensionHidden, NSFileHFSCreatorCode, NSFileHFSTypeCode, NSFileImmutable, NSFileAppendOnly, NSFileCreationDate, nil];
	
	LocalizedNames = [[NSDictionary alloc] initWithObjectsAndKeys: NSLocalizedString(@"File Type", @""), NSFileType,
					  NSLocalizedString(@"Directory", @""), NSFileTypeDirectory,
					  NSLocalizedString(@"File", @""), NSFileTypeRegular, 
					  NSLocalizedString(@"Symbolic Link", @""), NSFileTypeSymbolicLink,
					  NSLocalizedString(@"Socket", @""), NSFileTypeSocket,
					  NSLocalizedString(@"Character Special", @""), NSFileTypeCharacterSpecial,
					  NSLocalizedString(@"Block Special", @""), NSFileTypeBlockSpecial,
					  NSLocalizedString(@"Unkown", @""), NSFileTypeUnknown,
					  NSLocalizedString(@"Size", @""), NSFileSize,
					  NSLocalizedString(@"Modification Date", @""), NSFileModificationDate,
					  NSLocalizedString(@"Reference Count", @""), NSFileReferenceCount,
					  NSLocalizedString(@"Device ID", @""), NSFileDeviceIdentifier,
					  NSLocalizedString(@"Owner", @""), NSFileOwnerAccountName, 
					  NSLocalizedString(@"Group", @""), NSFileGroupOwnerAccountName,
					  NSLocalizedString(@"Permissions", @""), NSFilePosixPermissions,
					  NSLocalizedString(@"FileSystem Number", @""), NSFileSystemNumber,
					  NSLocalizedString(@"File Number", @""), NSFileSystemFileNumber,
					  NSLocalizedString(@"Extension Hidden", @""), NSFileExtensionHidden,
					  NSLocalizedString(@"Creator Code", @""), NSFileHFSCreatorCode,
					  NSLocalizedString(@"Type Code", @""), NSFileHFSTypeCode,
					  NSLocalizedString(@"Immutable", @""), NSFileImmutable,
					  NSLocalizedString(@"Append Only", @""), NSFileAppendOnly,
					  NSLocalizedString(@"Creation Date", @""), NSFileCreationDate,
					  NSLocalizedString(@"Owner ID", @""), NSFileOwnerAccountID,
					  NSLocalizedString(@"Group ID", @""), NSFileGroupOwnerAccountID,
					  nil];
	
	PermissionsNumberTypes = [[NSSet alloc] initWithObjects: NSFilePosixPermissions, nil];
	OSTypeNumberTypes = [[NSSet alloc] initWithObjects: NSFileHFSTypeCode, NSFileHFSCreatorCode, nil];
	BooleanNumberTypes = [[NSSet alloc] initWithObjects: NSFileExtensionHidden, NSFileImmutable, NSFileAppendOnly, nil];
	
	gOSTypeFormatter = [[OSTypeFormatter alloc] init];
	gBooleanFormatter = [[BooleanFormatter alloc] init];
	gPermissionsFormatter = [[POSIXPermissionsFormatter alloc] init];
}

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void) setDetailItem: (NSDictionary *) newDetailItem
{
    if (detailItem != newDetailItem)
	{
        [detailItem release];
        detailItem = [newDetailItem copy];
        
        // Update the view.
        [self configureView];
    }

    if (popoverController != nil) {
        [popoverController dismissPopoverAnimated:YES];
    }
}

- (void) configureView
{
	if ( _tableData == nil )
		_tableData = [[NSMutableArray alloc] init];
	else
		[_tableData removeAllObjects];
	
	[_tableData addObject: [NSMutableArray arrayWithCapacity: [BasicDetailKeys count]]];
	[_tableData addObject: [NSMutableArray arrayWithCapacity: [PermissionDetailKeys count]]];
	[_tableData addObject: [NSMutableArray arrayWithCapacity: [FinderInfoKeys count]]];
	
	if ( (id)detailItem == [NSNull null] )
	{
		[self.detailTableView reloadData];
		return;
	}
	
	NSSet * allKeys = [NSSet setWithArray: [detailItem allKeys]];
	NSArray * keySets = [NSArray arrayWithObjects: BasicDetailKeys, PermissionDetailKeys, FinderInfoKeys, nil];
	
	NSUInteger idx = 0;
	for ( NSMutableArray * array in _tableData )
	{
		NSArray * check = [keySets objectAtIndex: idx++];
		
		for ( NSString * key in check )
		{
			if ( [allKeys containsObject: key] == NO )
				continue;
			
			id value = [detailItem objectForKey: key];
			NSString * str = nil;
			if ( [value isKindOfClass: [NSString class]] )
			{
				str = value;
			}
			else if ( [PermissionsNumberTypes containsObject: key] )
			{
				str = [gPermissionsFormatter stringForObjectValue: value];
			}
			else if ( [OSTypeNumberTypes containsObject: key] )
			{
				str = [gOSTypeFormatter stringForObjectValue: value];
			}
			else if ( [BooleanNumberTypes containsObject: key] )
			{
				str = [gBooleanFormatter stringForObjectValue: value];
			}
			else
			{
				str = [value description];
			}
			
			NSString * localizedKey = [LocalizedNames objectForKey: key];
			if ( localizedKey == nil )
				localizedKey = key;
			
			NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys: str, @"detail", localizedKey, @"title", nil];
			[array addObject: dict];
		}
	}
	
	if ( self.documentInteractionController != nil )
	{
		self.documentInteractionController.delegate = self;
		
		DocumentInteractionView * header = [[DocumentInteractionView alloc] initWithFrame: CGRectMake(0.0, 0.0, self.detailTableView.bounds.size.width, 128.0)];
		header.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		header.documentInteractionController = self.documentInteractionController;
		self.detailTableView.tableHeaderView = header;
	}
	
	[self.detailTableView reloadData];
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
    
    barButtonItem.title = @"Root List";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
	return ( kNumSections );
}

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section
{
	return ( [[_tableData objectAtIndex: section] count] );
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FolderDetailCellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell.
	
	NSDictionary * dict = [[_tableData objectAtIndex: indexPath.section] objectAtIndex: indexPath.row];
	
    cell.textLabel.text = [dict objectForKey: @"title"];
	cell.detailTextLabel.text = [dict objectForKey: @"detail"];
    
	return ( cell );
}

- (NSString *) tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section
{
	switch ( section )
	{
		case kSectionFileBasicDetails:
			return ( NSLocalizedString(@"Basic Details", @"") );
			
		case kSectionFilePermissions:
			return ( NSLocalizedString(@"Access Permissions", @"") );
			
		case kSectionFinderInfo:
			return ( NSLocalizedString(@"Finder Info", @"") );
			
		default:
			break;
	}
	
	return ( nil );
}

- (NSString *) tableView: (UITableView *) tableView titleForFooterInSection: (NSInteger) section
{
	if ( (section == kNumSections-1) && ((id)detailItem == [NSNull null]) )
		return ( NSLocalizedString(@"No Information Available", @"") );
	
	return ( nil );
}

#pragma mark -
#pragma mark Document Interaction Controller Delegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
	return ( self );
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
	DocumentInteractionView * aView = (DocumentInteractionView *)self.detailTableView.tableHeaderView;
	return ( aView.previewStartView );
}

#pragma mark -
#pragma mark View lifecycle

- (void) setTitle: (NSString *) aTitle
{
	[super setTitle: aTitle];
	self.titleBarItem.title = aTitle;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.titleBarItem.title = self.title;
	[self.detailTableView reloadData];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (void) viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
	self.toolbar = nil;
	self.detailTableView = nil;
}

#pragma mark -
#pragma mark Memory management

- (void) dealloc
{
    [popoverController release];
    [toolbar release];
    
    [detailItem release];
	[detailTableView release];
	[_tableData release];
	[_documentController release];
    [super dealloc];
}

@end
