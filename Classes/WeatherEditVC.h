//
//  WeatherEditVC.h
//  FitnessPlan2
//
//  Created by Женя on 10.12.10.
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CloudinessSelectVC.h"


@interface WeatherEditVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	UISegmentedControl *seg;
	UITextField *textField;
	NSString *valueLabel;
	long valueC;
	
	CloudinessSelectVC *cloudVC;
	
	id target;
	SEL action;
}

@property (nonatomic, copy) NSString *valueLabel;

- (void) setTarget:(id)aTarget action:(SEL)anAction;
- (void) setValueT:(long)valueT C:(long)valueC;

@end