//
//  WorkoutButton.h
//  FitnessPlan2
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Workout.h"


@interface WorkoutButton : UIControl
{
	BOOL inButton;
    BOOL showAst;
	
	UIImage *backImage;
	UIImage *backImageP;
	Workout *workout;	
}

@property (nonatomic, retain) UIImage *backImage;
@property (nonatomic, retain) UIImage *backImageP;
@property (nonatomic, retain) Workout *workout;

+ (WorkoutButton *)createWithWorkout:(Workout *)workout;
+ (WorkoutButton *)createWithWorkout:(Workout *)workout pos:(CGFloat)pos width:(int)width padding:(int)padding;
- (id)initWithFrame:(CGRect)frame workout:(Workout *)newWorkout;

@end
