//
//  DateSelectVC.h
//  FitPlan
//
//  Created by Evgeny Kondratiev on 21.12.08.
//  Copyright 2008 Kondratiev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THCalendarInfo.h"


@interface DateSelectVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	UIDatePicker *datePicker;
	NSDateFormatter *dateFormatter;
	
	THCalendarInfo *date;
	
	BOOL repeated;
	
	id target;
	SEL action;
}

@property (nonatomic, assign) BOOL repeated;

- (void) setTarget:(id)aTarget action:(SEL)anAction;
- (void) setValue:(THCalendarInfo *)date;
- (void) dateChanged:(id)sender;

@end