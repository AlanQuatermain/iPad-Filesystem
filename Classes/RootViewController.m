//
//  RootViewController.m
//  iPad Filesystem
//
//  Created by Jim Dovey on 10-05-10.
//  Copyright Kobo Inc. 2010. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "UIAlertView+NSError.h"

@implementation RootViewController

@synthesize detailViewController, folderPath;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
	if ( self.folderPath == nil )
		self.folderPath = @"/";
	
	// load the contents of the specified folder
	NSError * error = nil;
	_folderContents = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath: self.folderPath error: &error] copy];
	if ( error != nil )
	{
		[UIAlertView showAlertForError: error];
		return;
	}
	
	// fetch attributes
	BOOL shownError = NO;
	_attributes = [[NSMutableArray alloc] initWithCapacity: [_folderContents count]];
	for ( NSString * filename in _folderContents )
	{
		error = nil;
		NSString * path = [self.folderPath stringByAppendingPathComponent: filename];
		
		NSDictionary * dict = [[NSFileManager defaultManager] attributesOfItemAtPath: path error: &error];
		if ( error != nil )
		{
			if ( shownError == NO )
			{
				shownError = YES;
				[UIAlertView showAlertForError: error];
			}
			
			[_attributes addObject: [NSNull null]];
		}
		else
		{
			[_attributes addObject: dict];
		}
	}
	
	[self.tableView reloadData];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear:animated];
	
	NSIndexPath * selected = [self.tableView indexPathForSelectedRow];
	if ( selected != nil )
		self.detailViewController.detailItem = [_attributes objectAtIndex: selected.row];
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return ( [_folderContents count] );
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"FolderItemCellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
	id obj = [_attributes objectAtIndex: indexPath.row];
	if ( obj == [NSNull null] )
	{
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	else if ( [[obj fileType] isEqualToString: NSFileTypeDirectory] )
	{
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
    cell.textLabel.text = [_folderContents objectAtIndex: indexPath.row];
    
	return ( cell );
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    /*
     When a row is selected, set the detail view controller's detail item to the item associated with the selected row.
     */
    self.detailViewController.detailItem = [_attributes objectAtIndex: indexPath.row];
	self.detailViewController.title = [_folderContents objectAtIndex: indexPath.row];
}

- (void) tableView: (UITableView *) aTableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath
{
	RootViewController * subController = [[RootViewController alloc] initWithStyle: UITableViewStylePlain];
	subController.detailViewController = self.detailViewController;
	subController.folderPath = [self.folderPath stringByAppendingPathComponent: [_folderContents objectAtIndex: indexPath.row]];
	
	[self.navigationController pushViewController: subController animated: YES];
	
	[subController release];
}

#pragma mark -
#pragma mark Memory management

- (void) viewDidUnload
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[_folderContents release];
	[_attributes release];
	_folderContents = nil;
	_attributes = nil;
}


- (void) dealloc
{
    [detailViewController release];
	[folderPath release];
	[_folderContents release];
	[_attributes release];
    [super dealloc];
}


@end

