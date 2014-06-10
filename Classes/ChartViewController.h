//
//  ChartViewController.h
//  FitnessPlan
//
//  Created by Женя on 26.03.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Workout.h"
#import "Metric.h"

@interface ChartViewController : UIViewController <UIWebViewDelegate>
{
    IBOutlet UIToolbar *toolbar;
    UIButton *closeButton;
    UISegmentedControl *periodsSeg;
    
    UIImageView *mImages[2];
    UILabel *mLabels[2];
    
    UILabel *totalLabel;
    UIImageView *tImages[2];
    UILabel *tLabels[2];
    
    NSString *workoutName;
    Metric *metrics[2];
    
    NSDateFormatter *dateFormatter;

    NSString *barTemplate;
    NSString *lineTemplate;
    UIView *nodataView;
    NSURL *baseUrl;
    
    UIWebView *graphView;
    
    NSArray *items;
    
    UILabel *l1, *l2;
    UIImageView *im1, *im2;
    
    double max[2], min[2], sum[2];
    int count;
}

@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSString *workoutName;

- (void) setWorkoutName:(NSString *)wname metric1:(Metric *)m1 metric2:(Metric *)m2;
- (void) periodChanged:(id)sender;

@end
