//
//  EditMetricVC.h
//  FitnessPlan
//
//  Created by Женя on 23.03.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Metric.h"


@interface EditMetricVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	UITextField *textField;
	NSString *valueLabel;
    
    Metric *editedMetric;
	
	id target;
	SEL action;
}

@property (nonatomic, copy) NSString *valueLabel;
@property (nonatomic, retain) Metric *editedMetric;

- (void) setTarget:(id)aTarget action:(SEL)anAction;

@end