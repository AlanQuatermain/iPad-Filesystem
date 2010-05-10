//
//  UIAlertView+NSError.h
//  iPad Filesystem
//
//  Created by Jim Dovey on 10-05-10.
//  Copyright 2010 Kobo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (NSError)
+ (void) showAlertForError: (NSError *) error;
@end
