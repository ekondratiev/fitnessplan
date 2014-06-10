//
//  DetailsEditVC.h
//  FitPlan
//
//  Created by Evgeny Kondratiev on 21.12.08.
//  Copyright 2008 Kondratiev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircularPickerView.h"
#import "Workout.h"


@interface ExpendedTimeEditVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
								UIPickerViewDataSource, UIPickerViewDelegate>
{
	UITableView *tableView;
	CircularPickerView *timePicker;
	NSDateComponents *times[3];
	
	Workout *editedWorkout;

	id target;
	SEL action;
}

- (void) setTarget:(id)aTarget action:(SEL)anAction;
- (void) setValue:(Workout *)workout;

@end