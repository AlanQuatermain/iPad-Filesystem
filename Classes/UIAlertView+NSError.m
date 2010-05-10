//
//  UIAlertView+NSError.m
//  iPad Filesystem
//
//  Created by Jim Dovey on 10-05-10.
//  Copyright 2010 Kobo Inc. All rights reserved.
//

#import "UIAlertView+NSError.h"

@implementation UIAlertView (NSError)

+ (void) showAlertForError: (NSError *) error
{
	UIAlertView * alert = [[self alloc] init];
	NSDictionary * userInfo = [error userInfo];
	
	NSString * failureReason = [userInfo objectForKey: NSLocalizedFailureReasonErrorKey];
	
	if ( failureReason != nil )
	{
		alert.message = failureReason;
		alert.title = [error localizedDescription];
	}
	else
	{
		alert.title = NSLocalizedString(@"An Error Occurred", @"Alert Title");
		alert.message = [error localizedDescription];
	}
	
	alert.cancelButtonIndex = [alert addButtonWithTitle: NSLocalizedString(@"OK", @"Button Title")];
	
	[alert performSelectorOnMainThread: @selector(show) withObject: nil waitUntilDone: NO];
}

@end
