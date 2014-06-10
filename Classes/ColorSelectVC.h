//
//  ColorSelectVC.h
//  FitnessPlan
//
//  Created by Evgeny Kondratiev on 22.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FitnessPlanAppDelegate.h"


@interface ColorSelectVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	
	id target;
	SEL action;
	int selected;
	
	FitnessPlanAppDelegate *delegate;
}

- (void) setTarget:(id)aTarget action:(SEL)anAction;
- (void) setValue:(int)color;

@end
