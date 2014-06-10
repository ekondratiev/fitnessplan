//
//  FitnessPlanViewController.h
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "utils/TouchedScrollView.h"
#import "utils/THCalendarInfo.h"
#import "FitnessPlanAppDelegate.h"
#import "AboutViewController.h"
#import "AddWorkoutViewController.h"
#import "WorkoutViewController.h"
#import "HistoryViewController.h"


@interface FitnessPlanViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
	UIToolbar *toolbar;
	UIImageView *bannerGradient;
	UILabel *monthLabel;
    UIButton *monthButton;
	
	TouchedScrollView *daysScrollView;
	UIView *daysView;
	UIImageView *daysBackground;
	
	NSDateFormatter *dateFormatter;
	NSArray *monthNames;
	NSArray *weekdayNames;
	
	THCalendarInfo *calendar;
	THCalendarInfo *touchedDay;
	int currentDay, currentMonth, currentYear;
	
	UINavigationController *addNavigationController;
	AddWorkoutViewController *addWorkoutController;
	WorkoutViewController *workoutViewController;
    HistoryViewController *historyViewController;
	
	UINavigationController *aboutNavigationController;
	AboutViewController *aboutViewController;
	
	NSMutableArray *workoutButtons;
	
	FitnessPlanAppDelegate *delegate;
	
	UIView *blockerView;
    UIView *notifView;
    UILabel *notifLabel;
    
    UIActionSheet *gotoSheet;
    UIPickerView *pickerView;
    Workout *oldestWorkout;
}

- (void) setupToolbarButtons;
- (void) updateButtons;

- (void) displayMonth:(BOOL)showToday;
- (IBAction) nextMonth;
- (IBAction) prevMonth;
- (IBAction) gotoSheet;

- (void) addWorkout:(Workout *)newWorkout;

- (void) changeView;
- (void) viewHistory;
- (void) viewAbout;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIImageView *bannerGradient;
@property (nonatomic, retain) IBOutlet UILabel *monthLabel;
@property (nonatomic, retain) IBOutlet UIButton *monthButton;
@property (nonatomic, retain) Workout *oldestWorkout;

@end
