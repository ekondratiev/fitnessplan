//
//  FeelingSelectVC.h
//  FitnessPlan
//
//  Created by Женя on 14.03.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FitnessPlanAppDelegate.h"


@interface FeelingSelectVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
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
