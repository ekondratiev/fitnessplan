//
//  Workout.h
//  FitnessPlan2
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "utils/THCalendarInfo.h"
#import "GCMathParser.h"


@interface Workout : NSObject
{
	long wid;
	NSString *name;
	THCalendarInfo *wdate;

	long wtypeid;							// 0 is default for (A, B, C)
	float amount_1, amount_2, amount_3;		// 0.0 is not set
	NSString *amount_name_1, *amount_name_2, *amount_name_3;
	long time_1, time_2, time_3;			// 0 is not set

	long hrate;			// in bpm
	float weight;		// in kg or pounds
	long feeling;		// in % (0 - is not set, 1 - bad, 50 - so-so, 100 - good)

	long weather_t;		// temperature in C or F (-9999 is not set)
	long weather_c;		// weather type (0 - is not set)
	
	NSString *notes;
	
	long parentid;
	long rstep;				// step in days
	THCalendarInfo *rtill;	// repeat ends on this timestamp
	
	long color;
	long flags;
}

@property (nonatomic, assign) long wid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) THCalendarInfo *wdate;
@property (nonatomic, assign) long wtypeid;
@property (nonatomic, assign) float amount_1;
@property (nonatomic, assign) float amount_2;
@property (nonatomic, assign) float amount_3;
@property (nonatomic, copy) NSString *amount_name_1;
@property (nonatomic, copy) NSString *amount_name_2;
@property (nonatomic, copy) NSString *amount_name_3;
@property (nonatomic, assign) long time_1;
@property (nonatomic, assign) long time_2;
@property (nonatomic, assign) long time_3;
@property (nonatomic, assign) long hrate;
@property (nonatomic, assign) float weight;
@property (nonatomic, assign) long feeling;
@property (nonatomic, assign) long weather_t;
@property (nonatomic, assign) long weather_c;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, assign) long parentid;
@property (nonatomic, assign) long rstep;
@property (nonatomic, retain) THCalendarInfo *rtill;
@property (nonatomic, assign) long color;
@property (nonatomic, assign) long flags;

- (BOOL)hasName;
- (BOOL)hasDetails;
- (BOOL)hasNotes;
- (BOOL)hasRepeat;
- (BOOL)hasWeather;

- (void)setupExpressionParameters:(GCMathParser *)parser;

+ (long)feelingToIndex:(long)feeling;
+ (long)indexToFeeling:(long)index;

@end
