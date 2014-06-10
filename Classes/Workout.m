//
//  Workout.m
//  FitnessPlan2
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import "Workout.h"


@implementation Workout

@synthesize wid;
@synthesize name;
@synthesize wdate;
@synthesize wtypeid;
@synthesize amount_1, amount_2, amount_3;
@synthesize amount_name_1, amount_name_2, amount_name_3;
@synthesize time_1, time_2, time_3;
@synthesize hrate;
@synthesize weight;
@synthesize feeling;
@synthesize weather_t;
@synthesize weather_c;
@synthesize notes;
@synthesize parentid;
@synthesize rstep;
@synthesize rtill;
@synthesize color;
@synthesize flags;


- (id)init
{
	self = [super init];
	
	wid = -1;
	wdate = [[THCalendarInfo calendarInfo] retain];
	
	// setup 5 minutes step for workout time
	int remain = [wdate minute] % 5;
	[wdate adjustSeconds:60 * (5 - remain)];
	[wdate setHour:[wdate hour] minute:[wdate minute] second:0];
	
	wtypeid = 0;
	amount_1 = 0.0;
	amount_2 = 0.0;
	amount_3 = 0.0;
	
	self.amount_name_1 = NSLocalizedString(@"Amount1", nil);
	self.amount_name_2 = NSLocalizedString(@"Amount2", nil);
	self.amount_name_3 = NSLocalizedString(@"Amount3", nil);
	
	time_1 = 0;
	time_2 = 0;
    time_3 = 0;
	
	hrate = 0;
	weight = 0;
	feeling = 0;
	
	weather_t = -9999;
	weather_c = 0;
	
	parentid = -1;
	rstep = 0;
	rtill = 0;
	
	color = 4; // green
	flags = 0;
	
	return self;
}


- (BOOL)hasName
{
	return (name != nil && [name length] > 0);
}


- (BOOL)hasDetails
{
	if(amount_1 > 0.0 || amount_2 > 0.0 || amount_3 > 0.0 || time_1 > 0 || time_2 > 0)
		return TRUE;
	else
		return FALSE;
}


- (BOOL)hasNotes
{
	return (notes != nil && [notes length] > 0);
}


- (BOOL)hasRepeat
{
	return (rstep > 0);
}


- (BOOL)hasWeather
{
	return (weather_t != -9999 || weather_c != 0);
}


- (void)setupExpressionParameters:(GCMathParser *)parser
{
    [parser setSymbolValue:amount_1 forKey:@"a1"];
    [parser setSymbolValue:amount_1 forKey:@"amount"];
    [parser setSymbolValue:amount_1 forKey:@"Amount"];
    [parser setSymbolValue:amount_2 forKey:@"a2"];
    [parser setSymbolValue:amount_3 forKey:@"a3"];
    [parser setSymbolValue:time_1 forKey:@"t1"];
    [parser setSymbolValue:time_1 forKey:@"time"];
    [parser setSymbolValue:time_1 forKey:@"Time"];
    [parser setSymbolValue:time_2 forKey:@"t2"];
    [parser setSymbolValue:time_3 forKey:@"t3"];
    [parser setSymbolValue:hrate forKey:@"hr"];
    [parser setSymbolValue:hrate forKey:@"hrate"];
    [parser setSymbolValue:weight forKey:@"w"];
    [parser setSymbolValue:weight forKey:@"wgt"];
    [parser setSymbolValue:weight forKey:@"weight"];
}


- (void)dealloc
{
	[amount_name_1 release];
	[amount_name_2 release];
	[amount_name_3 release];
	[rtill release];
	[notes release];
	[name release];
	[wdate release];
    [super dealloc];
}


#pragma mark -
#pragma mark Static Methods

+ (long)feelingToIndex:(long)feeling
{
	if(feeling == 0) return 0;
    
	feeling--;
    feeling = 100 - feeling;    // here we revert feeling index
	return (feeling / 20) + 1;
}


+ (long)indexToFeeling:(long)index
{
    if(index == 0) return 0;
    
    index = 1 + 5 - index;
	return index * 20;
}


@end
