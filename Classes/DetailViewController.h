//
//  DetailViewController.h
//  iPad Filesystem
//
//  Created by Jim Dovey on 10-05-10.
//  Copyright Kobo Inc. 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
	UIBarItem *titleBarItem;
    
    NSDictionary * detailItem;
	
	UITableView *detailTableView;
	
	NSMutableArray * _tableData;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarItem *titleBarItem;
@property (nonatomic, copy) NSDictionary * detailItem;
@property (nonatomic, retain) IBOutlet UITableView *detailTableView;

@end
