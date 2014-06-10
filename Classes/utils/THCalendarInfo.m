//
//  THCalendarInfo.m
//
//  Created by Scott Stevenson on 3/10/06.
//  Released under a BSD-style license. See License.txt
//
//  Modified by Evgeny Kondratiev on 12/7/08 for iPhone.

#import "THCalendarInfo.h"


@interface THCalendarInfo (Private)
- (void) setupEnglishNames;
@end

@interface THCalendarInfo (PrivateAccessors)
-(CFCalendarRef)calendar;
-(void)setCalendar:(CFCalendarRef)newCalendar;
-(CFTimeZoneRef)timeZone;
-(void)setTimeZone:(CFTimeZoneRef)newTimeZone;
@end


static SDCalendarRoundingRule MyDefaultRoundingRule;
static SDCalendarHourFormat MyDefaultHourFormat;



@implementation THCalendarInfo

+ (void) initialize
{
	MyDefaultRoundingRule = SDCalendarRoundDownRule;
	MyDefaultHourFormat   = SDCalendar24HourFormat;
}

- (id) init
{
	if (self = [super init])
	{
		_absoluteTime = CFAbsoluteTimeGetCurrent();
		_calendar     = CFCalendarCopyCurrent();
		_timeZone	  = CFCalendarCopyTimeZone(_calendar);
		_dayNames	  = nil;
		_monthNames	  = nil;
		
		[self setupEnglishNames];
	}
	return self;
}

- (void) dealloc
{
	if (_calendar) CFRelease(_calendar);
	if (_timeZone) CFRelease(_timeZone);
	
	[_dayNames release];
	[_monthNames release];
	
	[super dealloc];
}

+ (id) calendarInfo
{
	return [[[THCalendarInfo alloc] init] autorelease];
}

+ (id) createWithUnixEpoch:(unsigned)unixEpoch
{
	THCalendarInfo *cal = [[[THCalendarInfo alloc] init] autorelease];
	[cal setUnixEpoch:unixEpoch];
	return cal;
}

+ (id) createWithYear:(int)year month:(int)month day:(int)day hour:(int)hour minute:(int)minute second:(int)second
{
	THCalendarInfo *cal = [[[THCalendarInfo alloc] init] autorelease];
	
	CFAbsoluteTime newTime = 0;
    BOOL itWorked = NO;
	
	const char format[] = "yMdHms";
	
	itWorked = CFCalendarComposeAbsoluteTime ([cal calendar],
											  &newTime,
											  format,
											  year, month, day, hour, minute, second);
	
	if (itWorked)
	{
		[cal setAbsoluteTime: newTime];
		return cal;
	}
	return nil;
}

+ (SDCalendarRoundingRule) defaultRoundingRule
{
	return MyDefaultRoundingRule;
}

+ (void) setDefaultRoundingRule: (SDCalendarRoundingRule)roundingRule
{
	MyDefaultRoundingRule = roundingRule;
}

+ (SDCalendarHourFormat) defaultHourFormat
{
	return MyDefaultHourFormat;
}

+ (void) setDefaultHourFormat: (SDCalendarHourFormat)format
{
	MyDefaultHourFormat = format;
}

#pragma mark -
#pragma mark Class Methods for Current Date and Time

+ (NSDate *) currentDate
{
	return [NSDate date];
}

+ (CFAbsoluteTime) currentAbsoluteTime
{
	return CFAbsoluteTimeGetCurrent();	
}

+ (unsigned) currentUnixEpoch
{
	return [self currentAbsoluteTime]  + kCFAbsoluteTimeIntervalSince1970;	
}

+ (int) currentDayOfWeek
{
	return CFCalendarGetOrdinalityOfUnit (
	   CFCalendarCopyCurrent(),
	   kCFCalendarUnitDay,
	   kCFCalendarUnitWeek,
	   [self currentAbsoluteTime]
	);
}

+ (int) currentDayOfMonth
{
	return CFCalendarGetOrdinalityOfUnit (
	   CFCalendarCopyCurrent(),
	   kCFCalendarUnitDay,
	   kCFCalendarUnitMonth,
	   [self currentAbsoluteTime]
	);
}

+ (int) currentMonth
{
	return CFCalendarGetOrdinalityOfUnit (
	   CFCalendarCopyCurrent(),
	   kCFCalendarUnitMonth,
	   kCFCalendarUnitYear,
	   [self currentAbsoluteTime]
	);
}

+ (int) currentYear
{
	return CFCalendarGetOrdinalityOfUnit (
	   CFCalendarCopyCurrent(),
	   kCFCalendarUnitYear,
	   kCFCalendarUnitEra,
	   [self currentAbsoluteTime]
	);
}

+ (int) currentHour
{
	return [self currentHourIn24HourFormat];
}

+ (int) currentHourIn12HourFormat
{
	int myHour = CFCalendarGetOrdinalityOfUnit (
	   CFCalendarCopyCurrent(),
	   kCFCalendarUnitHour,
	   kCFCalendarUnitDay,
	   [self currentAbsoluteTime]
	);
	
	// adjust for real-world expectations
	// otherwise, 3:45 is '4' (fouth hour)
	myHour--;

	// is it midnight?
	if (myHour < 1)
	{		
		myHour = 12;
		
	// afternoon/evening
	} else if (myHour > 12) {
				
		myHour -= 12;
	}

	return myHour;	
}

+ (int) currentHourIn24HourFormat
{
	int myHour = CFCalendarGetOrdinalityOfUnit (
	   CFCalendarCopyCurrent(),
	   kCFCalendarUnitHour,
	   kCFCalendarUnitDay,
	   [self currentAbsoluteTime]
	);

	// adjust for real-world expectations
	// otherwise, 3:45 is '4' (fouth hour)	
	myHour--;
	
	return myHour;
}

+ (int) currentMinute
{
	int myMinute = CFCalendarGetOrdinalityOfUnit (
	   CFCalendarCopyCurrent(),
	   kCFCalendarUnitMinute,
	   kCFCalendarUnitHour,
	   [self currentAbsoluteTime]
	);
	
	// adjust for real-world expectations
	// otherwise, 3:10 is '11' (eleventh minute)
	myMinute--;
	
	return myMinute;	
}

+ (int) currentSecond
{
	int mySecond = CFCalendarGetOrdinalityOfUnit (
	   CFCalendarCopyCurrent(),
	   kCFCalendarUnitSecond,
	   kCFCalendarUnitMinute,
	   [self currentAbsoluteTime]
	);
	
	// adjust for real-world expectations
	// otherwise, 3:10:09 is '10' (tenth second)
	mySecond--;
	
	return mySecond;
}

+ (int) daysInCurrentMonth
{
	CFRange r = CFCalendarGetRangeOfUnit (
	   CFCalendarCopyCurrent(),
	   kCFCalendarUnitDay,
	   kCFCalendarUnitMonth,
	   [self currentAbsoluteTime]
	);
	
	return r.length;
}

+ (NSString *) currentDayName
{
	return @"Undefined";
}                                                

+ (NSString *) currentMonthName
{
	return @"Undefined";
}


#pragma mark -
#pragma mark Accessors for Reference Date

-(CFAbsoluteTime) absoluteTime
{
	return _absoluteTime;
}

-(unsigned) unixEpoch
{
	return _absoluteTime + kCFAbsoluteTimeIntervalSince1970;
}

-(void) setAbsoluteTime:(CFAbsoluteTime)newAbsoluteTime
{
	_absoluteTime = newAbsoluteTime;
}

-(void) setUnixEpoch:(unsigned)unixEpoch
{
	_absoluteTime = unixEpoch - kCFAbsoluteTimeIntervalSince1970;
}

- (NSDate *) date
{
	// This looks weird to me, but this doc says it's okay:
	// http://developer.apple.com/documentation/Cocoa/Conceptual/MemoryMgmt/Concepts/CFObjects.html
	
	NSDate * newDate = (NSDate *) CFDateCreate(NULL, [self absoluteTime]);
	return [newDate autorelease];
}

- (void) setDate:(NSDate *)newDate
{
	if (newDate == NULL) return;
	[self setAbsoluteTime: CFDateGetAbsoluteTime((CFDateRef)newDate)];
}

- (void) resetDateAndTimeToCurrent
{
	[self setAbsoluteTime: CFAbsoluteTimeGetCurrent()];
}

- (CFIndex) firstDayOfWeek
{
	return CFCalendarGetFirstWeekday([self calendar]);
}

- (void) setFirstDayOfWeek:(CFIndex)wkdy
{
	CFCalendarSetFirstWeekday([self calendar], wkdy);
}


#pragma mark -
#pragma mark Info for Reference Date

- (int) dayOfWeek
{
	return CFCalendarGetOrdinalityOfUnit (
	   [self calendar],
	   kCFCalendarUnitDay,
	   kCFCalendarUnitWeek,
	   [self absoluteTime]
	);
}

- (int) dayOfMonth
{
	return CFCalendarGetOrdinalityOfUnit (
	   [self calendar],
	   kCFCalendarUnitDay,
	   kCFCalendarUnitMonth,
	   [self absoluteTime]
	);	
}

- (int) month
{
	return CFCalendarGetOrdinalityOfUnit (
	   [self calendar],
	   kCFCalendarUnitMonth,
	   kCFCalendarUnitYear,
	   [self absoluteTime]
	);	
}

- (int) year
{
	return CFCalendarGetOrdinalityOfUnit (
	   [self calendar],
	   kCFCalendarUnitYear,
	   kCFCalendarUnitEra,
	   [self absoluteTime]
	);	
}

- (int) hour
{
	return [self hourIn24HourFormat];
}

- (int) hourIn12HourFormat
{
	int myHour = CFCalendarGetOrdinalityOfUnit (
	   [self calendar],
	   kCFCalendarUnitHour,
	   kCFCalendarUnitDay,
	   [self absoluteTime]
	);
	
	// adjust for real-world expectations
	// otherwise, 3:45 is '4' (fouth hour)
	myHour--;

	// is it midnight?
	if (myHour < 1)
	{		
		myHour = 12;
		
	// afternoon/evening
	} else if (myHour > 12) {
				
		myHour -= 12;
	}

	return myHour;	
}

- (int) hourIn24HourFormat
{
	int myHour = CFCalendarGetOrdinalityOfUnit (
	   [self calendar],
	   kCFCalendarUnitHour,
	   kCFCalendarUnitDay,
	   [self absoluteTime]
	);

	// adjust for real-world expectations
	// otherwise, 3:45 is '4' (fouth hour)	
	myHour--;
	
	return myHour;
}

- (int) minute
{
	int myMinute = CFCalendarGetOrdinalityOfUnit (
	   [self calendar],
	   kCFCalendarUnitMinute,
	   kCFCalendarUnitHour,
	   [self absoluteTime]
	);
	
	// adjust for real-world expectations
	// otherwise, 3:10 is '11' (eleventh minute)
	myMinute--;
	
	return myMinute;	
}

- (int) second
{
	int mySecond = CFCalendarGetOrdinalityOfUnit (
	   [self calendar],
	   kCFCalendarUnitSecond,
	   kCFCalendarUnitMinute,
	   [self absoluteTime]
	);
	
	// adjust for real-world expectations
	// otherwise, 3:10:09 is '10' (tenth second)
	mySecond--;
	
	return mySecond;
}

- (int) daysInMonth
{
	CFRange r = CFCalendarGetRangeOfUnit (
	   [self calendar],
	   kCFCalendarUnitDay,
	   kCFCalendarUnitMonth,
	   [self absoluteTime]
	);
	
	return r.length;
}

- (NSString *) dayName
{
	unsigned currentDay = [self dayOfWeek];
	return [_dayNames objectAtIndex: (currentDay-1)];
}

- (NSString *) monthName
{
	unsigned currentMonth = ([self month] - 1);
	return [_monthNames objectAtIndex: currentMonth];
}


// go forward in time by one unit

- (void) moveToNextDay
{
	[self adjustDays: 1];
}

- (void) moveToNextMonth
{
	[self adjustMonths: 1];
}

- (void) moveToNextYear
{
	[self adjustYears: 1];	
}

// go back in time by one unit

- (void) moveToPreviousDay
{
	[self adjustDays: -1];
}

- (void) moveToPreviousMonth
{
	[self adjustMonths: -1];
}

- (void) moveToPreviousYear
{
	[self adjustYears: -1];
}

// go back or forward in time an arbitrary number
// of units. negative numbers go backwards

- (void) adjustDays: (int)days
{
	CFAbsoluteTime   newTime = [self absoluteTime];
	
	// calculate absolute time for new object
	// declaring the format separately suppresses warnings
	
	const char format[] = "d";
	CFCalendarAddComponents ([self calendar], &newTime, 0, format, days);
	[self setAbsoluteTime: newTime];
}

- (void) adjustMonths: (int)months
{
    CFAbsoluteTime   newTime = [self absoluteTime];

	// calculate absolute time for new object
	// declaring the format separately suppresses warnings
	
	if ([THCalendarInfo defaultRoundingRule] == SDCalendarExactCountRule)
	{
		const char dFormat[] = "d";
		CFCalendarAddComponents ([self calendar], &newTime, 0, dFormat, (months * 30));
			
	} else {
		
		const char mFormat[] = "M";
		CFCalendarAddComponents ([self calendar], &newTime, 0, mFormat, months);		
	}

	[self setAbsoluteTime: newTime];
}

- (void) adjustYears: (int)years
{
	// TODO: What happens if we start at Feb 29 and move one year?
		
	CFAbsoluteTime newTime = [self absoluteTime];
	
	// calculate absolute time for new object
	// declaring the format separately suppresses warnings

	const char format[] = "y";
	CFCalendarAddComponents ([self calendar], &newTime, 0, format, years);
	[self setAbsoluteTime: newTime];
}

- (void) adjustSeconds: (int)seconds
{	
	CFAbsoluteTime newTime = [self absoluteTime];
	
	// calculate absolute time for new object
	// declaring the format separately suppresses warnings
	
	const char format[] = "s";
	CFCalendarAddComponents ([self calendar], &newTime, 0, format, seconds);
	[self setAbsoluteTime: newTime];
}

- (void) moveToFirstDayOfMonth
{
	CFAbsoluteTime newTime = 0;
    BOOL itWorked = NO;

	// build new time from current month and year
	// but with '1' for the day

	const char format[] = "yMdHms";
			
	itWorked = CFCalendarComposeAbsoluteTime (
		[self calendar],
		&newTime,
		format,
		[self year], [self month], 1, 0, 0, 0
	);
	
	if (itWorked)
	{
		[self setAbsoluteTime: newTime];		
	}
}

- (void) setHour:(int)newHour minute:(int)newMinute second:(int)newSecond
{
	CFAbsoluteTime newTime = 0;
    BOOL itWorked = NO;
	
	const char format[] = "yMdHms";
	
	itWorked = CFCalendarComposeAbsoluteTime (
											  [self calendar],
											  &newTime,
											  format,
											  [self year], [self month], [self dayOfMonth],
											  newHour, newMinute, newSecond
											 );
	
	if (itWorked)
	{
		[self setAbsoluteTime: newTime];
	}
}


- (void) setYeat:(int)newYear month:(int)newMonth day:(int)newDay
{
	CFAbsoluteTime newTime = 0;
    BOOL itWorked = NO;
	
	const char format[] = "yMdHms";
	
	itWorked = CFCalendarComposeAbsoluteTime (
											  [self calendar],
											  &newTime,
											  format,
											  newYear, newMonth, newDay,
											  [self hour], [self minute], [self second]
                                              );
	
	if (itWorked)
	{
		[self setAbsoluteTime: newTime];
	}
}




#pragma mark -
#pragma mark Private

- (void) setupEnglishNames
{
  _dayNames = [[NSArray alloc] initWithObjects: @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", nil];

  _monthNames = [[NSArray alloc] initWithObjects: @"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
}

/*
- (void) setupRussianNames
{
	_dayNames = [[NSArray alloc] initWithObjects: @"Воскресенье", @"Понедельник", @"Вторник", @"Среда", @"Четверг", @"Пятница", @"Суббота", nil];
	
	_monthNames = [[NSArray alloc] initWithObjects: @"Январь", @"Февраль", @"Март", @"Апрель", @"Май", @"Июнь", @"Июль", @"Август", @"Сентябрь", @"Октябрь", @"Ноябрь", @"Декабрь", nil];
}
*/

#pragma mark -
#pragma mark Private Accessors

-(CFCalendarRef)calendar
{
	return _calendar;
}

-(void)setCalendar:(CFCalendarRef)newCalendar
{
	CFCalendarRef temp = _calendar;
	_calendar = (CFCalendarRef)CFRetain(newCalendar);
	if (temp) CFRelease(temp);
}
-(CFTimeZoneRef)timeZone {
	return _timeZone;
}

-(void)setTimeZone:(CFTimeZoneRef)newTimeZone
{
	CFTimeZoneRef temp = _timeZone;
	_timeZone = CFRetain(newTimeZone);
	if (temp) CFRelease(temp);
}

@end
