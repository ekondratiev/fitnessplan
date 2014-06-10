//
//  ParameterEditVC.h
//  FitPlan
//
//  Created by Evgeny Kondratiev on 20.12.08.
//  Copyright 2008 Kondratiev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FitnessPlanAppDelegate.h"

@interface NameEditVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
	UISearchBar *textField;
	UITableView *tableView;
	
	NSArray *items;
	
	id target;
	SEL action;
	
	FitnessPlanAppDelegate *delegate;
}

- (void) setTarget:(id)aTarget action:(SEL)anAction;
- (void) setText:(NSString *)text;
- (void) reloadNames:(UISearchBar *)searchBar;

@end
