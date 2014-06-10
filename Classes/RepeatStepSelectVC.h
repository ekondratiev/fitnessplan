//
//  RepeatStepSelectVC.h
//  FitnessPlan
//
//  Created by Evgeny Kondratiev on 23.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FitnessPlanAppDelegate.h"


@interface RepeatStepSelectVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	
	id target;
	SEL action;
	int selected;
	
	FitnessPlanAppDelegate *delegate;
}

- (void) setTarget:(id)aTarget action:(SEL)anAction;
- (void) setValue:(int)step;

@end
