//
//  MetricsListVC.h
//  FitnessPlan
//
//  Created by Женя on 16.03.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditMetricVC.h"
#import "Workout.h"


@interface MetricsListVC : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UIAlertViewDelegate>
{
    UITableView *tableView;
    EditMetricVC *metricEditVC;

    Workout *editedWorkout;
    NSMutableArray *metrics;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, assign) Workout *editedWorkout;

@end
