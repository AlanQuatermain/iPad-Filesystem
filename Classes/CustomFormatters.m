//
//  CustomFormatters.m
//  iPad Filesystem
//
//  Created by Jim Dovey on 10-05-10.
//  Copyright 2010 Kobo Inc. All rights reserved.
//

#import "CustomFormatters.h"
#import <Endian.h>
#import <sys/stat.h>

@implementation OSTypeFormatter

- (NSString *) stringForObjectValue: (id) obj
{
	if ( [obj isKindOfClass: [NSValue class]] == NO )
		return ( nil );
	
	OSType osType = 0;
	[obj getValue: &osType];
	
#if TARGET_RT_LITTLE_ENDIAN
	osType = Endian32_Swap(osType);
#endif
	
	char str[5];
	memcpy(str, &osType, sizeof(osType));
	str[4] = '\0';
	
	return ( [NSString stringWithUTF8String: str] );
}

- (BOOL) getObjectValue: (id *) obj forString: (NSString *) string errorDescription: (NSString **) error
{
	if ( [string length] != 4 )
		return ( NO );
	
	OSType osType = 0;
	const char * str = [string UTF8String];
	osType = OSReadBigInt32(str, 0);	// this will swap for us as appropriate
	
	if ( obj != NULL )
		*obj = [NSNumber numberWithUnsignedInt: osType];
	return ( YES );
}

- (NSAttributedString *) attributedStringForObjectValue: (id) obj withDefaultAttributes: (NSDictionary *) attrs
{
	return ( [[[NSAttributedString alloc] initWithString: [self stringForObjectValue: obj] attributes: attrs] autorelease] );
}

@end

@implementation POSIXPermissionsFormatter

- (NSString *) stringForObjectValue: (id) obj
{
	if ( [obj isKindOfClass: [NSNumber class]] == NO )
		return ( nil );
	
	unsigned int perms = [obj unsignedIntValue];
	char buf[11];
	memset(buf, '-', 10);
	buf[10] = '\0';
	
	char type = '-';
	switch ( perms & S_IFMT )
	{
		case S_IFBLK:
			type = 'b';
			break;
			
		case S_IFCHR:
			type = 'c';
			break;
			
		case S_IFDIR:
			type = 'd';
			break;
			
		case S_IFIFO:
		case S_IFSOCK:
			type = 's';
			break;
			
		case S_IFREG:
		default:
			break;
			
		case S_IFLNK:
			type = 'l';
			break;
			
		case S_IFWHT:
			type = 'w';
			break;
	}
	
	buf[0] = type;
	
	if ( perms & S_IRUSR )
		buf[1] = 'r';
	if ( perms & S_IWUSR )
		buf[2] = 'w';
	if ( perms & S_IXUSR )
		buf[3] = 'x';
	if ( perms & S_IRGRP )
		buf[4] = 'r';
	if ( perms & S_IWGRP )
		buf[5] = 'w';
	if ( perms & S_IXGRP )
		buf[6] = 'x';
	if ( perms & S_IROTH )
		buf[7] = 'r';
	if ( perms & S_IWOTH )
		buf[8] = 'w';
	if ( perms & S_IXOTH )
		buf[9] = 'x';
	
	return ( [NSString stringWithUTF8String: buf] );
}

- (BOOL) getObjectValue: (id *) obj forString: (NSString *) string errorDescription: (NSString **) error
{
	return ( NO );
}

- (NSAttributedString *) attributedStringForObjectValue: (id) obj withDefaultAttributes: (NSDictionary *) attrs
{
	return ( [[[NSAttributedString alloc] initWithString: [self stringForObjectValue: obj] attributes: attrs] autorelease] );
}

@end

@implementation BooleanFormatter

- (NSString *) stringForObjectValue: (id) obj
{
	if ( [obj boolValue] )
		return ( NSLocalizedString(@"Yes", @"") );
	
	return ( NSLocalizedString(@"No", @"") );
}

- (BOOL) getObjectValue: (id *) obj forString: (NSString *) string errorDescription: (NSString **) error
{
	if ( obj != NULL )
		*obj = [NSNumber numberWithBool: [string boolValue]];
	return ( YES );
}

- (NSAttributedString *) attributedStringForObjectValue: (id) obj withDefaultAttributes: (NSDictionary *) attrs
{
	return ( [[[NSAttributedString alloc] initWithString: [self stringForObjectValue: obj] attributes: attrs] autorelease] );
}

@end

