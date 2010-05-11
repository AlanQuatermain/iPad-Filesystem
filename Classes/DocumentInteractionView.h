//
//  DocumentInteractionView.h
//  iPad Filesystem
//
//  Created by Jim Dovey on 10-05-11.
//  Copyright 2010 Kobo Inc. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DocumentInteractionView : UIView
{
	UIDocumentInteractionController * _controller;
	UIImageView *					  _iconView;
}

@property (nonatomic, retain) UIDocumentInteractionController * documentInteractionController;
@property (nonatomic, readonly) UIView * previewStartView;

@end
