//
//  Settings.m
//  FitnessPlan2
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import "Settings.h"


@implementation Settings

@synthesize createOnTap;
@synthesize bigButtons;
@synthesize futureInGray;
@synthesize copyNotes;
@synthesize colorScheme;
@synthesize fullPeriod;
@synthesize showAll;
@synthesize temperatureUnit;
@synthesize isPro;
@synthesize app_tint_color, banner_tint_color;
@synthesize repList, emoList, emoImages;
@synthesize cloudinessList, cloudinessImages;
@synthesize labelsFont, detailsFont, smallDetailsFont, digitsFont;
@synthesize predefinedMetrics;

- (id) init
{
	//createOnTap = YES;
	//bigButtons = NO;
	//futureInGray = NO;
	//copyNotes = YES;
	//colorScheme = 1;
    //showAll = NO;
    
    isPro = NO;
	
	labelsFont = [[UIFont boldSystemFontOfSize:16] retain];
	detailsFont = [[UIFont systemFontOfSize:16] retain];
	smallDetailsFont = [[UIFont systemFontOfSize:14] retain];
	digitsFont = [[UIFont boldSystemFontOfSize:16] retain]; //[[UIFont fontWithName:@"DBLCDTempBlack" size:18] retain];
	
	return self;
}


- (void)dealloc
{
    [predefinedMetrics release];
	[labelsFont release];
	[detailsFont release];
	[smallDetailsFont release];
	[digitsFont release];
	[super dealloc];
}

@end
