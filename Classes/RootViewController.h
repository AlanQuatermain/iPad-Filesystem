//
//  RootViewController.h
//  iPad Filesystem
//
//  Created by Jim Dovey on 10-05-10.
//  Copyright Kobo Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UITableViewController
{
    DetailViewController *detailViewController;
	
	NSString * folderPath;
	NSArray * _folderContents;
	NSMutableArray * _attributes;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;
@property (nonatomic, copy) NSString *folderPath;

@end
