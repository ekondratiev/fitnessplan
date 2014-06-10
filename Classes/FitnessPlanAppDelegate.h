//
//  FitnessPlanAppDelegate.h
//  FitnessPlan2
//
//  Copyright ekondratiev.com 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "Workout.h"
#import "Metric.h"
#import "BuyProViewController.h"


@class FitnessPlanViewController;

@interface FitnessPlanAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    UINavigationController *navVC;
	
	FitnessPlanViewController *rootVC;
    BuyProViewController *buyProVC;
	
	sqlite3 *database;
	sqlite3_stmt *selectStmt;
	sqlite3_stmt *addStmt;
	sqlite3_stmt *modStmt;
	sqlite3_stmt *delStmt;
	sqlite3_stmt *delNextStmt;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) id rootVC;
@property (nonatomic, retain) BuyProViewController *buyProVC;

- (void)saveUserDefaults;
- (void)readUserDefaults;

- (void)updateButtons;
- (void)displayMonth:(BOOL)showToday;

//- (BOOL) createEditableCopyOfDatabaseIfNeeded;
- (BOOL) checkDatabase;
- (BOOL) initializeDatabase;
- (int) addWorkout:(Workout *)workout;
- (int) addRepeatedWorkout:(Workout *)workout;
- (int) modWorkout:(Workout *)workout;
- (int) modChain:(Workout *)workout;
- (int) delWorkout:(Workout *)workout allNext:(BOOL)allNext;
- (NSArray *) workoutsForMonth:(int)month year:(int)year;
- (NSArray *) workoutsForPeriod:(THCalendarInfo *)time1 to:(THCalendarInfo *)time2 forName:(NSString *)name;
- (NSArray *) allWorkoutsForPeriod:(THCalendarInfo *)time1 to:(THCalendarInfo *)time2;
- (NSMutableArray *) collectWorkouts:(sqlite3_stmt *)stmt;
- (NSArray *) groupedNames:(NSString *)searchText from:(int)date;
- (Workout *) getLastWorkoutFor:(Workout *)workout;
- (Workout *) getOldestWorkout;

//- (NSMutableArray *) getMetricsForWorkoutId:(long)wid;
//- (NSMutableArray *) getMetricsForWorkout:(Workout *)workout;
- (NSMutableArray *) allMetricsForWorkoutName:(NSString *)name;
- (NSMutableArray *) allMetricsForAllWorkouts;
- (int) addMetric:(Metric *)metric;
- (int) modMetric:(Metric *)metric;
- (int) delMetric:(Metric *)metric;
- (int) cleanupMetrics;

+ (NSString *)stringFromTimestamp:(long)ts;

//- (int) getWorkoutColor:(Workout *)workout;
//- (NSString *) getWorkoutNotes:(Workout *)workout;

@end

void loadButtons();
UIImage *colorizeImage(UIImage *baseImage, UIColor *theColor);
NSInteger getSystemVersionAsInteger();
