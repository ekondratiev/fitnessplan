//
//  THCalendarInfo.h
//
//  Created by Scott Stevenson on 3/10/06.
//  Released under a BSD-style license. See License.txt
//
//  Modified by Evgeny Kondratiev on 12/7/08 for iPhone in folllowing parts:
//      - NSCalendarDate class references and methods removed due to NSCalendarDate depracation
//      - firstDayOfWeek added
//
//  TODO:
//      - change month and weekday names to use NSDateFormatter

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum {
	SDCalendarRoundDownRule = (1 << 1),
	SDCalendarExactCountRule = (1 << 2),
} SDCalendarRoundingRule;

typedef enum {
	SDCalendar12HourFormat = (1 << 1),
	SDCalendar24HourFormat = (1 << 2),
} SDCalendarHourFormat;

// SDCalendarRoundingRule controls what happens when
// moving back/forward in increments. For example, if
// current date is Jan 31 and we move forward one
// month, should the new date be Feb 28 or Mar 3?
//
// in that example:
// SDCalendarRoundDownRule  => Feb 28
// SDCalendarExactCountRule => Mar 03


// TODO something later --
// would be nice if the object could cache NSString representations
// of some key int values like month, year, etc. stringWithForrmat
// is somewhat expensive if done frequently

@interface THCalendarInfo : NSObject {

	CFAbsoluteTime	   _absoluteTime;
	CFCalendarRef	   _calendar;
	CFTimeZoneRef	   _timeZone;
	
	NSArray			 * _dayNames;
	NSArray 		 * _monthNames;   
}
                           
+ (id) calendarInfo;
+ (id) createWithUnixEpoch:(unsigned)unixEpoch;
+ (id) createWithYear:(int)year month:(int)month day:(int)day hour:(int)hour minute:(int)minute second:(int)second;

+ (SDCalendarRoundingRule) defaultRoundingRule;
+ (void) setDefaultRoundingRule: (SDCalendarRoundingRule)roundingRule;                               
+ (SDCalendarHourFormat) defaultHourFormat;
+ (void) setDefaultHourFormat: (SDCalendarHourFormat)format;


// CLASS methods
// universal info for current date/time

+ (NSDate *) currentDate;
+ (CFAbsoluteTime) currentAbsoluteTime;
+ (unsigned) currentUnixEpoch;

+ (int) currentDayOfWeek;
+ (int) currentDayOfMonth;
+ (int) currentMonth;
+ (int) currentYear;

+ (int) currentHour;
+ (int) currentHourIn12HourFormat;
+ (int) currentHourIn24HourFormat;
+ (int) currentMinute;
+ (int) currentSecond;

+ (int) daysInCurrentMonth;

+ (NSString *) currentDayName;
+ (NSString *) currentMonthName;


// INSTANCE methods
// accessors for reference date

- (CFAbsoluteTime) absoluteTime;
- (unsigned) unixEpoch;
- (void) setAbsoluteTime:(CFAbsoluteTime)newAbsoluteTime;
- (void) setUnixEpoch:(unsigned)unixEpoch;
- (NSDate *) date;
- (void) setDate:(NSDate *)aValue;

- (void) resetDateAndTimeToCurrent;

- (CFIndex) firstDayOfWeek;
- (void) setFirstDayOfWeek:(CFIndex)wkdy;

// get info on reference date

- (int) dayOfWeek;
- (int) dayOfMonth;
- (int) month;
- (int) year;

- (int) hour;
- (int) hourIn12HourFormat;
- (int) hourIn24HourFormat;
- (int) minute;
- (int) second;

- (int) daysInMonth;

- (NSString *) dayName;
- (NSString *) monthName;

// go forward in time by one unit

- (void) moveToNextDay;
- (void) moveToNextMonth;
- (void) moveToNextYear;

// go back in time by one unit

- (void) moveToPreviousDay;
- (void) moveToPreviousMonth;
- (void) moveToPreviousYear;

// go back or forward in time an arbitrary number
// of units. negative numbers go backwards

- (void) adjustDays: (int)days;
- (void) adjustMonths: (int)months;
- (void) adjustYears: (int)years;
- (void) adjustSeconds: (int)seconds;

- (void) moveToFirstDayOfMonth;
- (void) setHour:(int)newHour minute:(int)newMinute second:(int)newSecond;
- (void) setYeat:(int)newYear month:(int)newMonth day:(int)newDay;

@end
