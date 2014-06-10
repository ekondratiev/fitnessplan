//
//  HistoryViewController.h
//  FitnessPlan
//
//  Created by Женя on 25.03.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChartViewController.h"
#import "SelectedIndexPath.h"
#import "ZIStoreButton.h"


// this defines number of charts for the diagram
#define MAX_METRICS_SELECTED    2


@interface HistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *workoutsTable;
    UITableView *metricsTable;
    
    ZIStoreButton *proceedButton;
    
    NSArray *workoutsList;
    NSArray *metricsList;
    
    int workoutSelected;

    int metricsSelectStep;
    SelectedIndexPath *metricsSelected[MAX_METRICS_SELECTED];
    
    ChartViewController *chartVC;
}

@property (nonatomic, retain) NSArray *workoutsList;
@property (nonatomic, retain) NSArray *metricsList;

- (void)updateWorkouts;

@end
