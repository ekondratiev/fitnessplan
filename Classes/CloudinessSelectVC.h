//
//  CloudinessEditVC.h
//  FitnessPlan
//
//  Created by Женя on 04.01.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FitnessPlanAppDelegate.h"


@interface CloudinessSelectVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	
	id target;
	SEL action;
	int selected;
	
	FitnessPlanAppDelegate *delegate;
}

- (void) setTarget:(id)aTarget action:(SEL)anAction;
- (void) setValue:(long)cloudiness;

@end
