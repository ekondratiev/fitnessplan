//
//  WorkoutViewController.h
//  FitnessPlan2
//
//  Created by Женя on 14.09.10.
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Workout.h"
#import "EditWorkoutViewController.h"
#import "MetricsListVC.h"
#import "ZIStoreButton.h"


@interface WorkoutViewController : UIViewController
{
	UIView *innerView;
	UILabel *workoutNameLabel;
	UILabel *dateLabel;
	UILabel *repeatedLabel;
	UIImageView *weatherIcon;
	UILabel *temperatureLabel;
	UILabel *a1nameLabel, *a1valueLabel;
	UILabel *a2nameLabel, *a2valueLabel;
	UILabel *a3nameLabel, *a3valueLabel;
	UILabel *time1Label, *time1valueLabel;
	UILabel *time2Label, *time2valueLabel;
    UILabel *time3Label, *time3valueLabel;
	UILabel *hrateLabel;
	UILabel *hrateValueLabel;
	UILabel *weightLabel;
	UILabel *weightValueLabel;
	
	UIImageView *feelingIcon;
	UILabel *metricsLabel;
	ZIStoreButton *metricsEditButton;
	UILabel *notesLabel;
	
	Workout *workout;
	
	NSDateFormatter *dateFormatter;
	EditWorkoutViewController *editWorkoutController;
	UINavigationController *editNavigationController;
    
    MetricsListVC *metricsVC;
}

@property (nonatomic, assign) Workout *workout;

- (void) createViewPro;
- (void) updateViewPro;
- (void) createView;

@end
