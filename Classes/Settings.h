//
//  Settings.h
//  FitnessPlan2
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Settings : NSObject
{
	BOOL createOnTap;
	BOOL bigButtons;
	BOOL futureInGray;
	BOOL copyNotes;
	int colorScheme;
    BOOL showAll;
    BOOL fullPeriod;
    int temperatureUnit; // 0 - F, 1 - C
    
    BOOL isPro;
	
	UIColor *app_tint_color;
	UIColor *banner_tint_color;
	
	NSArray *emoList;
	NSArray *emoImages;
	
	NSArray *repList;
	
	NSArray *cloudinessList;
	NSArray *cloudinessImages;
	
	UIFont *labelsFont;
	UIFont *detailsFont;
	UIFont *smallDetailsFont;
	UIFont *digitsFont;
    
    NSArray *predefinedMetrics;
}

@property (nonatomic, assign) BOOL createOnTap;
@property (nonatomic, assign) BOOL bigButtons;
@property (nonatomic, assign) BOOL futureInGray;
@property (nonatomic, assign) BOOL copyNotes;
@property (nonatomic, assign) int colorScheme;
@property (nonatomic, assign) BOOL showAll;
@property (nonatomic, assign) BOOL fullPeriod;
@property (nonatomic, assign) int temperatureUnit;

@property (nonatomic, assign) BOOL isPro;

@property (nonatomic, retain) UIColor *app_tint_color;
@property (nonatomic, retain) UIColor *banner_tint_color;
@property (nonatomic, retain) NSArray *emoList;
@property (nonatomic, retain) NSArray *emoImages;
@property (nonatomic, retain) NSArray *repList;
@property (nonatomic, retain) NSArray *cloudinessList;
@property (nonatomic, retain) NSArray *cloudinessImages;

@property (nonatomic, readonly) UIFont *labelsFont;
@property (nonatomic, readonly) UIFont *detailsFont;
@property (nonatomic, readonly) UIFont *smallDetailsFont;
@property (nonatomic, readonly) UIFont *digitsFont;

@property (nonatomic, retain) NSArray *predefinedMetrics;

@end

extern Settings *settings;
extern NSInteger iosVersion;
extern int buttonsView;