//
//  DocumentInteractionView.m
//  iPad Filesystem
//
//  Created by Jim Dovey on 10-05-11.
//  Copyright 2010 Kobo Inc. All rights reserved.
//

#import "DocumentInteractionView.h"


@implementation DocumentInteractionView

@synthesize documentInteractionController=_controller, previewStartView=_iconView;

- (id) initWithFrame: (CGRect) frame
{
	self = [super initWithFrame: frame];
	if ( self == nil )
		return ( nil );
	
	_iconView = [[UIImageView alloc] initWithFrame: CGRectZero];
	_iconView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
	_iconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
	_iconView.userInteractionEnabled = YES;
	[self addSubview: _iconView];
	
	self.backgroundColor = [UIColor groupTableViewBackgroundColor];
	
	return ( self );
}

- (void) dealloc
{
	[_controller dealloc];
    [super dealloc];
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	
	CGRect aFrame = _iconView.frame;
	aFrame.size = _iconView.image.size;
	_iconView.frame = aFrame;
	
	_iconView.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (void) setDocumentInteractionController: (UIDocumentInteractionController *) controller
{
	[_controller release];
	_controller = [controller retain];
	
	_iconView.gestureRecognizers = _controller.gestureRecognizers;
	
	_iconView.image = [_controller.icons objectAtIndex: 0];
	_iconView.opaque = NO;
	_iconView.backgroundColor = [UIColor clearColor];
}

@end
