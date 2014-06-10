//
//  AmountEditVC.h
//  FitnessPlan2
//
//  Copyright 2010 Evgeny Kondratiev. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CircularPickerView.h"
#import "Settings.h"
#import "Workout.h"


@interface AmountEditVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	UITextField *labelFields[3];
	UITextField *textFields[3];
	
	Workout *editedWorkout;
	
	id target;
	SEL action;
}

- (void) setTarget:(id)aTarget action:(SEL)anAction;
- (void) setValue:(Workout *)workout;

@end