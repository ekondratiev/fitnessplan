//
//  RepeatTillSelectVC.h
//  FitnessPlan
//
//  Created by Evgeny Kondratiev on 23.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THCalendarInfo.h"


@interface RepeatTillSelectVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	UIDatePicker *datePicker;
	NSDateFormatter *dateFormatter;
	
	THCalendarInfo *date;
	
	id target;
	SEL action;
}

- (void) setTarget:(id)aTarget action:(SEL)anAction;
- (void) setValue:(THCalendarInfo *)date min:(THCalendarInfo *)minDate;
- (void) dateChanged:(id)sender;

@end