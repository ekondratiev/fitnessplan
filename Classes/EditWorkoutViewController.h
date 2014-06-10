//
//  EditWorkoutViewController.h
//  FitnessPlan2
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "Workout.h"

#import "NameEditVC.h"
#import "DateSelectVC.h"
#import "RepeatStepSelectVC.h"
#import "RepeatTillSelectVC.h"
#import "AmountEditVC.h"
#import "ExpendedTimeEditVC.h"
#import "ColorSelectVC.h"
#import "NotesEditVC.h"
#import "HRateEditVC.h"
#import "FeelingSelectVC.h"
#import "WeightEditVC.h"
#import "WeatherEditVC.h"


@interface EditWorkoutViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate>
{
	IBOutlet UITableView *tableView;
	
	Workout *editedWorkout;
	BOOL changed;

	NSDateFormatter *dateFormatter;
	UIView *footerView;
	
	NameEditVC *nameEditVC;
	DateSelectVC *dateSelectVC;
	RepeatStepSelectVC *rstepVC;
	RepeatTillSelectVC *rtillVC;
	AmountEditVC *amountVC;
	ExpendedTimeEditVC *timeVC;
	HRateEditVC *hrateVC;
	WeightEditVC *weightVC;
	FeelingSelectVC *feelingVC;
	WeatherEditVC *weatherVC;
	ColorSelectVC *colorsVC;
	NotesEditVC *notesVC;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) Workout *editedWorkout;

- (void) showAlert:(NSString *)msg;

@end
