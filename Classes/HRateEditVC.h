//
//  HRateEditVC.h
//  FitnessPlan2
//
//  Created by Женя on 13.10.10.
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "Settings.h"

@interface HRateEditVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	UITextField *textField;
	NSString *valueLabel;
	
	id target;
	SEL action;
}

@property (nonatomic, copy) NSString *valueLabel;

- (void) setTarget:(id)aTarget action:(SEL)anAction;
- (void) setValue:(int)value;

@end