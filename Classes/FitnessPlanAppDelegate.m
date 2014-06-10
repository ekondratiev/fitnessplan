//
//  FitnessPlanAppDelegate.m
//  FitnessPlan
//
//  Copyright ekondratiev.com 2010. All rights reserved.
//

#import "FitnessPlanAppDelegate.h"
#import "FitnessPlanViewController.h"
#import "Settings.h"
#import "Constants.h"
#import "NSFileManager+DirectoryLocations.h"


Settings *settings;

NSInteger iosVersion;

UIImage *buttonMasks[4];
UIImage *bulletMasks[4];
UIImage *buttonColors[8];
UIImage *bulletColors[8];
UIImage *ast;

static int tz;

@interface FitnessPlanAppDelegate ()  <UIApplicationDelegate, UIAlertViewDelegate>
@end


@implementation FitnessPlanAppDelegate

@synthesize window;
@synthesize rootVC;
@synthesize buyProVC;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[self readUserDefaults];
	
	iosVersion = getSystemVersionAsInteger();
	
	NSTimeZone *local = [NSTimeZone localTimeZone];
	tz = [local secondsFromGMT];
	
	loadButtons();
	
	// The application ships with a default database in its bundle. If anything in the application
    // bundle is altered, the code sign will fail. We want the database to be editable by users, 
    // so we need to create a copy of it in the application's Documents directory.     
    //BOOL rc = [self createEditableCopyOfDatabaseIfNeeded];
	BOOL rc = [self initializeDatabase];
	if(rc)
		[self checkDatabase];
	
	rootVC = [[[FitnessPlanViewController alloc] initWithNibName:@"FitnessPlanView" bundle:nil] autorelease];
	navVC = [[UINavigationController alloc] initWithRootViewController:rootVC];
	navVC.navigationBar.barStyle = UIBarStyleBlackOpaque;
	navVC.navigationBar.tintColor = settings.app_tint_color;
	
    [window addSubview:navVC.view];
	[window makeKeyAndVisible];
	
    return YES;
}


- (void)saveUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:settings.isPro forKey:@"proVersion"];
    
    [defaults synchronize];
}

- (void)readUserDefaults
{
    if(!settings)
        settings = [[Settings alloc] init];
    
    int usesMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
	
	NSMutableDictionary *defaultDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
	[defaultDictionary setObject:@"YES" forKey:@"createOnTap"];
	[defaultDictionary setObject:@"NO" forKey:@"bigButtons"];
	[defaultDictionary setObject:@"NO" forKey:@"futureInGray"];
	[defaultDictionary setObject:@"YES" forKey:@"copyNotes"];
    [defaultDictionary setObject:@"NO" forKey:@"showAll"];
//	[defaultDictionary setObject:[NSNumber numberWithInt:0]  forKey:@"colorScheme"];
    [defaultDictionary setObject:[NSNumber numberWithInt:usesMetric]  forKey:@"tempUnits"];
    [defaultDictionary setObject:@"NO" forKey:@"proVersion"];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:defaultDictionary];
	
	settings.createOnTap = [defaults boolForKey:@"createOnTap"];
	settings.bigButtons = [defaults boolForKey:@"bigButtons"];
	settings.futureInGray = [defaults boolForKey:@"futureInGray"];
	settings.copyNotes = [defaults boolForKey:@"copyNotes"];
    settings.showAll = [defaults boolForKey:@"showAll"];
//	settings.colorScheme = [defaults integerForKey:@"colorScheme"];
    settings.colorScheme = 0;
    settings.temperatureUnit = [defaults integerForKey:@"tempUnits"];
    settings.isPro = [defaults boolForKey:@"proVersion"];
    
    // isPro debug
    settings.isPro = YES;
    
	// read References.plist
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Config" ofType:@"plist"];
	NSDictionary *refs = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSArray *colors = [refs objectForKey:@"colors"];
	NSDictionary *c = [colors objectAtIndex:settings.colorScheme];
	
	// XXX
	float r = [[c objectForKey:@"app_r"] floatValue];
	float g = [[c objectForKey:@"app_g"] floatValue];
	float b = [[c objectForKey:@"app_b"] floatValue];
	float a = [[c objectForKey:@"app_a"] floatValue];
	settings.app_tint_color = [UIColor colorWithRed:r green:g blue:b alpha:a];
	
	r = [[c objectForKey:@"banner_r"] floatValue];
	g = [[c objectForKey:@"banner_g"] floatValue];
	b = [[c objectForKey:@"banner_b"] floatValue];
	a = [[c objectForKey:@"banner_a"] floatValue];
	settings.banner_tint_color = [UIColor colorWithRed:r green:g blue:b alpha:a];
	
	NSArray *list;
	
	// repeating list
	
	list = [NSArray arrayWithObjects:
			NSLocalizedString(@"Never", nil),
			NSLocalizedString(@"Every1d", nil),
			NSLocalizedString(@"Every2d", nil),
			NSLocalizedString(@"Every3d", nil),
			NSLocalizedString(@"Every4d", nil),
			NSLocalizedString(@"Every5d", nil),
			NSLocalizedString(@"Every6d", nil),
			NSLocalizedString(@"EveryWeek", nil),
			NSLocalizedString(@"Every2Weeks", nil),
			NSLocalizedString(@"EveryMonth", nil),
			nil];
	settings.repList = list;
	
	// emo list
	
	list = [NSArray arrayWithObjects:
			NSLocalizedString(@"IsNotSet", nil),
			NSLocalizedString(@"FeelPerfect", nil),
			NSLocalizedString(@"FeelGood", nil),
			NSLocalizedString(@"FeelNorm", nil),
			NSLocalizedString(@"FeelSad", nil),
            NSLocalizedString(@"FeelShock", nil),
			nil];
	settings.emoList = list;
	
	list = [NSArray arrayWithObjects:
			[UIImage imageNamed:@"dunno52.png"],
			[UIImage imageNamed:@"perfectly52.png"],
			[UIImage imageNamed:@"good52.png"],
			[UIImage imageNamed:@"norm52.png"],
			[UIImage imageNamed:@"sad52.png"],
            [UIImage imageNamed:@"shock52.png"],
			nil];
	settings.emoImages = list;
	
	// cloudiness list
	
	list = [NSArray arrayWithObjects:
			NSLocalizedString(@"IsNotSet", nil),
			NSLocalizedString(@"Fine", nil),
			NSLocalizedString(@"SomeCloud", nil),
			NSLocalizedString(@"Cloudy", nil),
			NSLocalizedString(@"Rainy", nil),
			NSLocalizedString(@"Snowy", nil),
			NSLocalizedString(@"Storm", nil),
			NSLocalizedString(@"Sleet", nil),
			nil];
	settings.cloudinessList = list;
	
	list = [NSArray arrayWithObjects:
			[UIImage imageNamed:@"dunno52.png"],
			[UIImage imageNamed:@"sun52.png"],
			[UIImage imageNamed:@"cloudys52.png"],
			[UIImage imageNamed:@"cloudy52.png"],
			[UIImage imageNamed:@"rainy52.png"],
			[UIImage imageNamed:@"snow52.png"],
			[UIImage imageNamed:@"storm52.png"],
			[UIImage imageNamed:@"sleet52.png"],
			nil];
	settings.cloudinessImages = list;
    
    // predefined metrics
    
    // read PredefinedMetrics.plist
	path = [[NSBundle mainBundle] pathForResource:@"PredefinedMetrics" ofType:@"plist"];
	refs = [[NSDictionary dictionaryWithContentsOfFile:path] objectForKey:@"metrics"];
    
    NSMutableArray *predefinedMetrics = [NSMutableArray arrayWithCapacity:5];
    
    for(NSDictionary *m in refs)
    {
        Metric *metric = [[Metric alloc] init];
        
        metric.mname = [m objectForKey:@"mname"];
        metric.text = [m objectForKey:@"metric"];
        metric.type = [[m objectForKey:@"type"] intValue];
        
        [predefinedMetrics addObject:metric];
        
        [metric release];
    }
    settings.predefinedMetrics = predefinedMetrics;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [self readUserDefaults];
    [rootVC displayMonth:NO];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


- (void) updateButtons
{
	[rootVC updateButtons];
}


- (void)displayMonth:(BOOL)showToday
{
	[rootVC displayMonth:showToday];
}


- (void)fatalError:(NSString *)msg
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
													message:msg
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"Exit", nil)
										  otherButtonTitles:nil];
	[alert show];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc
{
	[navVC release];
	[window release];
	[settings release];
	[super dealloc];
}


#pragma mark -
#pragma mark Database interaction


// returns YES if new database was created, NO if existing database was opened
- (BOOL)initializeDatabase
{
	// The database is stored in the application bundle.
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [[NSFileManager defaultManager] applicationSupportDirectory];
    NSString *path = [directory stringByAppendingPathComponent:DATABASE_NAME];
    
	int rc = sqlite3_open_v2([path UTF8String], &database, SQLITE_OPEN_READWRITE, NULL);
	
    if(rc != SQLITE_OK)
	{
        // The database does not exist, so create database from text file.
        
        rc = sqlite3_open_v2([path UTF8String], &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
        if(rc != SQLITE_OK)
        {
            // Even though the open failed, call close to properly clean up resources.
            sqlite3_close(database);
            exit(0);
        }
        
        NSString *sqlFile = [[NSBundle mainBundle] pathForResource:@"fitnessplan3" ofType:@"sql"];
        NSString *sql = [[[NSString alloc] initWithContentsOfFile:sqlFile encoding:NSUTF8StringEncoding error:nil] autorelease];
        
        rc = sqlite3_exec(database, [sql UTF8String], NULL, NULL, NULL);
        if(rc != SQLITE_OK)
        {
            // Even though the open failed, call close to properly clean up resources.
            sqlite3_close(database);
            exit(0);
        }
        
        return YES;
	}
    
    return NO;
}


- (BOOL)checkDatabase
{
	//NSLog(@"* in checkDatabase");
	// First, test for existence.
    int rc;
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"fitnessplan.sql"];
    
	rc = [fileManager fileExistsAtPath:writableDBPath];
	if(!rc)
		return YES;
	
	////////////////////////////////////////////////////////////////////////////////////////////////////
	//// migrate!
	////////////////////////////////////////////////////////////////////////////////////////////////////
	
	long prevVersion = 0x12;
	sqlite3_stmt *stmt;
	
	NSString *sql = [NSString stringWithFormat:@"attach '%@' as old", writableDBPath];
	
	// attach old database;
	sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, NULL);
	rc = sqlite3_step(stmt);
	sqlite3_finalize(stmt);
	
	rc = sqlite3_prepare_v2(database, "pragma table_info('activities')", -1, &stmt, NULL);
	if(rc == SQLITE_OK)
	{
		while((rc = sqlite3_step(stmt)))
		{
            const char *s = (const char*)sqlite3_column_text(stmt, 1);
            if(!s)
                break;
            
			NSString *columnName = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
			
			if([columnName compare:@"color"] == NSOrderedSame)
			{
				prevVersion = 0x15;
				break;
			}
		}
	}
	sqlite3_finalize(stmt);

	//NSLog(@"prevVersion=0x%X", prevVersion);
	
	if(prevVersion == 0x15)
		sql = @"insert into workouts (rowid, name, wdate, amount_1, time_1, notes, parentid, flags, rstep, rtill, color) select rowid, discipline, date, amount, time, notes, parentid, flags, rstep, rtill, color from old.activities order by date";
	else
		sql = @"insert into workouts (rowid, name, wdate, amount_1, time_1, notes, parentid, flags, rstep, rtill) select rowid, discipline, date, amount, time, notes, parentid, flags, rstep, rtill from old.activities order by date";
	
	rc = sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, NULL);
	if(rc == SQLITE_OK)
	{
		rc = sqlite3_step(stmt);
		//NSLog(@"migration: rc=%d", rc);
	}
	sqlite3_finalize(stmt);
	
	sqlite3_close(database);
	
	NSError *error;
	[fileManager removeItemAtPath:writableDBPath error:&error];
	//NSLog(@"removeItemAtPath: %@", writableDBPath);
	
	[self initializeDatabase];
	
	return YES;
}


- (int)addWorkout:(Workout *)workout
{
	if(!addStmt)
	{
		char *sql = "insert into workouts (name, wdate, wtypeid, amount_1, amount_2, amount_3, time_1, time_2, time_3, hrate, weight, feeling, weather_t, weather_c, notes, parentid, rstep, rtill, color, flags, amount_name_1, amount_name_2, amount_name_3) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
			[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
	}
	
	sqlite3_bind_text(addStmt, 1, [workout.name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(addStmt, 2, [workout.wdate unixEpoch] + tz);
	
	sqlite3_bind_int(addStmt, 3, workout.wtypeid);
	sqlite3_bind_double(addStmt, 4, workout.amount_1);
	sqlite3_bind_double(addStmt, 5, workout.amount_2);
	sqlite3_bind_double(addStmt, 6, workout.amount_3);
	sqlite3_bind_int(addStmt, 7, workout.time_1);
	sqlite3_bind_int(addStmt, 8, workout.time_2);
    sqlite3_bind_int(addStmt, 9, workout.time_3);
	
	sqlite3_bind_int(addStmt, 10, workout.hrate);
	sqlite3_bind_double(addStmt, 11, workout.weight);
	sqlite3_bind_int(addStmt, 12, workout.feeling);
	
	sqlite3_bind_int(addStmt, 13, workout.weather_t);
	sqlite3_bind_int(addStmt, 14, workout.weather_c);
	
	sqlite3_bind_text(addStmt, 15, [workout.notes UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_bind_int(addStmt, 16, workout.parentid);
	sqlite3_bind_int(addStmt, 17, workout.rstep);
	sqlite3_bind_int(addStmt, 18, [workout.rtill unixEpoch]);
	
	sqlite3_bind_int(addStmt, 19, workout.color);
	sqlite3_bind_int(addStmt, 20, workout.flags);
	
	sqlite3_bind_text(addStmt, 21, [workout.amount_name_1 UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 22, [workout.amount_name_2 UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 23, [workout.amount_name_3 UTF8String], -1, SQLITE_TRANSIENT);
	
	int rc = sqlite3_step(addStmt);
	
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(addStmt);
	
	if(rc != SQLITE_DONE)
		return -1;
	
	// SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
	// in the database. To access this functionality, the table should have a column declared of type 
	// "INTEGER PRIMARY KEY"
	workout.wid = sqlite3_last_insert_rowid(database);
	
	return 0;
}

- (int) addRepeatedWorkout:(Workout *)workout
{
	int rc = 0;
	
	rc |= [self addWorkout:workout];
	if(rc) return -2;
	
	if([workout hasRepeat])
	{
		workout.parentid = workout.wid;
		rc |= [self modWorkout:workout];
		
		THCalendarInfo *di = [THCalendarInfo calendarInfo];
		[di setDate:[workout.wdate date]];
		
		int rstep = workout.rstep;
		if(rstep >= 1 && rstep <= 7)
			[di adjustDays:rstep];
		else if(rstep == 8)
			[di adjustDays:14];
		else if(rstep == 9)
			[di moveToNextMonth];
		
		// XXX clear some fields for repeated workouts
		workout.hrate = 0;
		workout.weight = 0;
		workout.feeling = 0;
		workout.weather_c = 0;
		workout.weather_t = -9999;
		
		while([di unixEpoch] < [workout.rtill unixEpoch])
		{
			workout.wdate = di;
			rc |= [self addWorkout:workout];
			
			if(rstep >= 1 && rstep <= 7)
				[di adjustDays:rstep];
			else if(rstep == 8)
				[di adjustDays:14];
			else if(rstep == 9)
				[di moveToNextMonth];
		}
	}
	return rc;
}

- (int) modWorkout:(Workout *)workout
{
	int rc;
	
	if(!modStmt)
	{
		char *sql = "update workouts set name=?, wdate=?, wtypeid=?, amount_1=?, amount_2=?, amount_3=?, time_1=?, time_2=?, time_3=?, hrate=?, weight=?, feeling=?, weather_t=?, weather_c=?, notes=?, parentid=?, rstep=?, rtill=?, color=?, flags=?, amount_name_1=?, amount_name_2=?, amount_name_3=? where rowid=?";
		if(sqlite3_prepare_v2(database, sql, -1, &modStmt, NULL) != SQLITE_OK)
			[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
	}
	
	sqlite3_bind_text(modStmt, 1, [workout.name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(modStmt, 2, [workout.wdate unixEpoch] + tz);
	
	sqlite3_bind_int(modStmt, 3, workout.wtypeid);
	sqlite3_bind_double(modStmt, 4, workout.amount_1);
	sqlite3_bind_double(modStmt, 5, workout.amount_2);
	sqlite3_bind_double(modStmt, 6, workout.amount_3);
	sqlite3_bind_int(modStmt, 7, workout.time_1);
	sqlite3_bind_int(modStmt, 8, workout.time_2);
    sqlite3_bind_int(modStmt, 9, workout.time_3);
	
	sqlite3_bind_int(modStmt, 10, workout.hrate);
	sqlite3_bind_double(modStmt, 11, workout.weight);
	sqlite3_bind_int(modStmt, 12, workout.feeling);
	
	sqlite3_bind_int(modStmt, 13, workout.weather_t);
	sqlite3_bind_int(modStmt, 14, workout.weather_c);
	
	sqlite3_bind_text(modStmt, 15, [workout.notes UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_bind_int(modStmt, 16, workout.parentid);
	sqlite3_bind_int(modStmt, 17, workout.rstep);
	sqlite3_bind_int(modStmt, 18, [workout.rtill unixEpoch]);
	
	sqlite3_bind_int(modStmt, 19, workout.color);
	sqlite3_bind_int(modStmt, 20, workout.flags);
	
	sqlite3_bind_text(modStmt, 21, [workout.amount_name_1 UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(modStmt, 22, [workout.amount_name_2 UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(modStmt, 23, [workout.amount_name_3 UTF8String], -1, SQLITE_TRANSIENT);
	
	sqlite3_bind_int(modStmt, 24, workout.wid);
	
	rc = sqlite3_step(modStmt);
	
    // Because we want to reuse the statement, we "reset" it instead of "finalizing" it.
    sqlite3_reset(modStmt);
	
	if(rc != SQLITE_DONE)
		return -1;
	
	return 0;
}

- (int) modChain:(Workout *)workout
{
	int rc;
	
	sqlite3_stmt *stmt;
	
	char *sql = "update workouts set rtill=? where parentid=?";
	if(sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
		[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
	
	sqlite3_bind_int(stmt, 1, [workout.rtill unixEpoch] + tz);
	sqlite3_bind_int(stmt, 2, workout.parentid);
	rc = sqlite3_step(stmt);
	
    sqlite3_finalize(stmt);
	
	if(rc != SQLITE_DONE)
		return -1;
	
	return 0;
}

- (int) delWorkout:(Workout *)workout allNext:(BOOL)allNext
{
	int rc;
	
	if(!delStmt)
	{
		char *sql = "delete from workouts where rowid=?";
		if(sqlite3_prepare_v2(database, sql, -1, &delStmt, NULL) != SQLITE_OK)
			[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
	}
	if(!delNextStmt)
	{
		char *sql = "delete from workouts where parentid=? and wdate >= ?";
		if(sqlite3_prepare_v2(database, sql, -1, &delNextStmt, NULL) != SQLITE_OK)
			[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
	}
	
	if(!allNext)
	{
		sqlite3_bind_int(delStmt, 1, workout.wid);
		
		rc = sqlite3_step(delStmt);
		
		sqlite3_reset(delStmt);
	}
	else
	{
		sqlite3_bind_int(delNextStmt, 1, workout.parentid);
		sqlite3_bind_int(delNextStmt, 2, [workout.wdate unixEpoch] + tz);
		
		rc = sqlite3_step(delNextStmt);
		
		sqlite3_reset(delNextStmt);
	}
	
	if(rc != SQLITE_DONE)
		return -1;
	
	return 0;
}

- (NSArray *) workoutsForMonth:(int)month year:(int)year
{
	THCalendarInfo *time1 = [THCalendarInfo createWithYear:year month:month day:1 hour:0 minute:0 second:0];
	THCalendarInfo *time2 = [THCalendarInfo createWithYear:year month:month day:1 hour:0 minute:0 second:0];
	[time2 moveToNextMonth];
	
	if(!selectStmt)
	{
		char *sql = "select rowid, name, wdate, wtypeid, amount_1, amount_2, amount_3, time_1, time_2, time_3, hrate, weight, feeling, weather_t, weather_c, notes, parentid, rstep, rtill, color, flags, amount_name_1, amount_name_2, amount_name_3 from workouts where wdate >= ? and wdate < ? order by wdate";
		if (sqlite3_prepare_v2(database, sql, -1, &selectStmt, NULL) != SQLITE_OK)
		{
			[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
			return nil;
		}
	}
	
	sqlite3_bind_int(selectStmt, 1, [time1 unixEpoch] + tz);
	sqlite3_bind_int(selectStmt, 2, [time2 unixEpoch] + tz);
	
	NSMutableArray *items = [self collectWorkouts:selectStmt];
	
    sqlite3_reset(selectStmt);	
	
	return items;
}

- (NSArray *) workoutsForPeriod:(THCalendarInfo *)time1 to:(THCalendarInfo *)time2 forName:(NSString *)name
{
	sqlite3_stmt *stmt;
	
	char *sql = "select rowid, name, wdate, wtypeid, amount_1, amount_2, amount_3, time_1, time_2, time_3, hrate, weight, feeling, weather_t, weather_c, notes, parentid, rstep, rtill, color, flags, amount_name_1, amount_name_2, amount_name_3 from workouts where wdate >= ? and wdate <= ? and name=? order by wdate asc";
	if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
	{
		[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
		return nil;
	}
	
	sqlite3_bind_int(stmt, 1, [time1 unixEpoch]);
	sqlite3_bind_int(stmt, 2, [time2 unixEpoch]);
	sqlite3_bind_text(stmt, 3, [name UTF8String], -1, SQLITE_TRANSIENT);
	
	NSMutableArray *items = [self collectWorkouts:stmt];
	
    sqlite3_finalize(stmt);	
	
	return items;
}

- (NSArray *) allWorkoutsForPeriod:(THCalendarInfo *)time1 to:(THCalendarInfo *)time2
{
	sqlite3_stmt *stmt;
	
	if(time1 && time2)
	{
		char *sql = "select rowid, name, wdate, wtypeid, amount_1, amount_2, amount_3, time_1, time_2, time_3, hrate, weight, feeling, weather_t, weather_c, notes, parentid, rstep, rtill, color, flags, amount_name_1, amount_name_2, amount_name_3 from workouts where wdate >= ? and wdate <= ? order by wdate asc";
		if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
		{
			[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
			return nil;
		}
		sqlite3_bind_int(stmt, 1, [time1 unixEpoch]);
		sqlite3_bind_int(stmt, 2, [time2 unixEpoch]);
	}
	else
	{
		char *sql = "select rowid, name, wdate, wtypeid, amount_1, amount_2, amount_3, time_1, time_2, time_3, hrate, weight, feeling, weather_t, weather_c, notes, parentid, rstep, rtill, color, flags, amount_name_1, amount_name_2, amount_name_3 from workouts order by wdate asc";
		if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
		{
			[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
			return nil;
		}
	}
	
	NSMutableArray *items = [self collectWorkouts:stmt];
	
    sqlite3_finalize(stmt);	
	
	return items;
}


- (NSMutableArray *) collectWorkouts:(sqlite3_stmt *)stmt
{
	NSMutableArray *items = [[[NSMutableArray alloc] initWithCapacity:30] autorelease];
	
	while(sqlite3_step(stmt) == SQLITE_ROW)
	{
		Workout *w = [[Workout alloc] init];
		
		w.wid = sqlite3_column_int(stmt, 0);
		w.name = [NSString stringWithCString:(const char *)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
		w.wdate = [THCalendarInfo createWithUnixEpoch:(sqlite3_column_int(stmt, 2) - tz)];
		
		w.wtypeid = sqlite3_column_int(stmt, 3);
		w.amount_1 = sqlite3_column_double(stmt, 4);
		w.amount_2 = sqlite3_column_double(stmt, 5);
		w.amount_3 = sqlite3_column_double(stmt, 6);
		w.time_1 = sqlite3_column_int(stmt, 7);
		w.time_2 = sqlite3_column_int(stmt, 8);
        w.time_3 = sqlite3_column_int(stmt, 9);
		
		w.hrate = sqlite3_column_int(stmt, 10);
		w.weight = sqlite3_column_double(stmt, 11);
		w.feeling = sqlite3_column_int(stmt, 12);
		
		w.weather_t = sqlite3_column_int(stmt, 13);
		w.weather_c = sqlite3_column_int(stmt, 14);
		
		const char *notes = (char *)sqlite3_column_text(stmt, 15);
		if(notes)
			w.notes = [NSString stringWithCString:(const char *)notes encoding:NSUTF8StringEncoding];
		
		w.parentid = sqlite3_column_int(stmt, 16);
		w.rstep = sqlite3_column_int(stmt, 17);
		int rtill = sqlite3_column_int(stmt, 18);
		w.rtill = (rtill) ? [THCalendarInfo createWithUnixEpoch:rtill] : nil;
		
		w.color = sqlite3_column_int(stmt, 19);
		w.flags = sqlite3_column_int(stmt, 20);
		
		const char *s;
		
		s = (const char *)sqlite3_column_text(stmt, 21);
		if(s)
			w.amount_name_1 = [NSString stringWithCString:(const char *)s encoding:NSUTF8StringEncoding];
		
		s = (const char *)sqlite3_column_text(stmt, 22);
		if(s)
			w.amount_name_2 = [NSString stringWithCString:(const char *)s encoding:NSUTF8StringEncoding];
		
		s = (const char *)sqlite3_column_text(stmt, 23);
		if(s)
			w.amount_name_3 = [NSString stringWithCString:(const char *)s encoding:NSUTF8StringEncoding];
		
		[items addObject:w];
		[w release];
	}
	
	return items;
}


- (NSArray *) groupedNames:(NSString *)searchText from:(int)date
{
	char *sql = "select distinct name from workouts where name like ? and wdate >= ? order by name";
	sqlite3_stmt *stmt;
	
	if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
	{
		[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
		return nil;
	}
	
	NSString *searchLike = [searchText stringByAppendingString:@"%"];
	sqlite3_bind_text(stmt, 1, [searchLike UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(stmt, 2, date);
	
	NSMutableArray *items = [[[NSMutableArray alloc] initWithCapacity:30] autorelease];
	
	int rc;
	do {
		rc = sqlite3_step(stmt);
		if (rc == SQLITE_ROW)
		{
			NSString *s = [NSString stringWithCString:(const char *)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
			[items addObject:s];
		}
	} while(rc == SQLITE_ROW);
	
	sqlite3_finalize(stmt);
	
	return items;
}


- (Workout *) getLastWorkoutFor:(Workout *)workout
{
	char *sql = "select rowid, name, wdate, wtypeid, amount_1, amount_2, amount_3, time_1, time_2, time_3, hrate, weight, feeling, weather_t, weather_c, notes, parentid, rstep, rtill, color, flags, amount_name_1, amount_name_2, amount_name_3 from workouts where name=? and wdate < ? order by wdate desc limit 1";
	sqlite3_stmt *stmt;
	
	if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
	{
		[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
		return nil;
	}
	
	sqlite3_bind_text(stmt, 1, [workout.name UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(stmt, 2, [workout.wdate unixEpoch] + tz);
	
	NSMutableArray *items = [self collectWorkouts:stmt];
	
	sqlite3_finalize(stmt);
	
	return [items count] ? [items objectAtIndex:0] : nil;
}


- (Workout *) getOldestWorkout
{
	char *sql = "select rowid, name, wdate, wtypeid, amount_1, amount_2, amount_3, time_1, time_2, time_3, hrate, weight, feeling, weather_t, weather_c, notes, parentid, rstep, rtill, color, flags, amount_name_1, amount_name_2, amount_name_3 from workouts order by wdate asc limit 1";
	sqlite3_stmt *stmt;
	
	if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
	{
		[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
		return nil;
	}
	
	NSMutableArray *items = [self collectWorkouts:stmt];
	
	sqlite3_finalize(stmt);
	
	return [items count] ? [items objectAtIndex:0] : nil;
}


/*
- (NSMutableArray *) getMetricsForWorkoutId:(long)wid
{
	sqlite3_stmt *stmt;
    char *sql;
    
    sql = "select rowid, wid, mtype, mname, metric from metrics where wid=?";
	if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
	{
		[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
		return nil;
	}
	sqlite3_bind_int(stmt, 1, wid);
	
	if(sqlite3_step(stmt) == SQLITE_ROW)
	{
		NSMutableArray *items = [NSMutableArray arrayWithCapacity:10];
		do
		{
			Metric *m = [[Metric alloc] init];
			
			m.rowid = sqlite3_column_int(stmt, 0);
			m.wid = sqlite3_column_int(stmt, 1);
			m.type = sqlite3_column_int(stmt, 2);
            const char *s = (const char *) sqlite3_column_text(stmt, 3);
            if(s)
                m.mname = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
			m.text = [NSString stringWithCString:(const char *)sqlite3_column_text(stmt, 4) encoding:NSUTF8StringEncoding];
            
			[items addObject:m];
            [m release];
		}
		while(sqlite3_step(stmt) == SQLITE_ROW);
		sqlite3_finalize(stmt);
        
		return items;
	}
    return nil;
}


- (NSArray *) getMetricsForWorkout:(Workout *)workout
{
	sqlite3_stmt *stmt;
    char *sql;
    long wid = -1;
    
    NSMutableArray *metrics = [self getMetricsForWorkoutId:workout.wid];
    if(metrics)
        return metrics;
    
    // Ohhh, no... There are no metrics and we need to get metrics from the workout with the same name.
    
    
    sql = "select m.wid from metrics as m join workouts as w on w.rowid = m.wid where w.name=? order by w.rowid desc limit 1";
    if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
	{
		[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
		return nil;
	}
	sqlite3_bind_text(stmt, 1, [workout.name UTF8String], -1, SQLITE_TRANSIENT);
    
    if(sqlite3_step(stmt) == SQLITE_ROW)
	{
        wid = sqlite3_column_int(stmt, 0);
    }
	
    if(wid != -1)
        metrics = [self getMetricsForWorkoutId:wid];
    
    return metrics;
}
*/

- (NSMutableArray *) allMetricsForWorkoutName:(NSString *)name
{
	//char *sql = "select m.metric, m.rowid, m.wid, m.mtype, m.mname from metrics as m join workouts as w on w.rowid = m.wid where w.name=? group by m.metric order by m.metric";
    char *sql = "select metric, rowid, wid, mtype, mname, wname from metrics where wname=? order by metric";
	sqlite3_stmt *stmt;
	
	if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
	{
		//[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
        [self fatalError:[NSString stringWithCString:sqlite3_errmsg(database) encoding:NSASCIIStringEncoding]];
		return nil;
	}
	
	sqlite3_bind_text(stmt, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
	
	NSMutableArray *items = [[[NSMutableArray alloc] initWithCapacity:30] autorelease];
	
	int rc;
	do {
		rc = sqlite3_step(stmt);
		if (rc == SQLITE_ROW)
		{
            Metric *m = [[Metric alloc] init];
            
            m.text = [NSString stringWithCString:(const char *)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
            m.rowid = sqlite3_column_int(stmt, 1);
			m.wid = sqlite3_column_int(stmt, 2);
			m.type = sqlite3_column_int(stmt, 3);
            const char *s = (const char *) sqlite3_column_text(stmt, 4);
            if(s)
                m.mname = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
            s = (const char *) sqlite3_column_text(stmt, 5);
            if(s)
                m.wname = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
            
			[items addObject:m];
            [m release];
		}
	} while(rc == SQLITE_ROW);
	
	sqlite3_finalize(stmt);
	
	return items;
}


- (NSMutableArray *) allMetricsForAllWorkouts
{
	//char *sql = "select m.metric, m.rowid, m.wid, m.mtype, m.mname from metrics as m join workouts as w on w.rowid = m.wid where w.name=? group by m.metric order by m.metric";
    char *sql = "select metric, rowid, wid, mtype, mname, wname from metrics group by metric order by metric";
	sqlite3_stmt *stmt;
	
	if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
	{
		//[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
        [self fatalError:[NSString stringWithCString:sqlite3_errmsg(database) encoding:NSASCIIStringEncoding]];
		return nil;
	}
	
	NSMutableArray *items = [[[NSMutableArray alloc] initWithCapacity:30] autorelease];
	
	int rc;
	do {
		rc = sqlite3_step(stmt);
		if (rc == SQLITE_ROW)
		{
            Metric *m = [[Metric alloc] init];
            
            m.text = [NSString stringWithCString:(const char *)sqlite3_column_text(stmt, 0) encoding:NSUTF8StringEncoding];
            m.rowid = sqlite3_column_int(stmt, 1);
			m.wid = sqlite3_column_int(stmt, 2);
			m.type = sqlite3_column_int(stmt, 3);
            const char *s = (const char *) sqlite3_column_text(stmt, 4);
            if(s)
                m.mname = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
            s = (const char *) sqlite3_column_text(stmt, 5);
            if(s)
                m.wname = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
            
			[items addObject:m];
            [m release];
		}
	} while(rc == SQLITE_ROW);
	
	sqlite3_finalize(stmt);
	
	return items;
}


- (int) addMetric:(Metric *)metric
{
	char *sql = "insert into metrics (wid, mtype, mname, metric, wname) values (?,?,?,?,?)";
	sqlite3_stmt *stmt;
	
	if(sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
		[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
	
	sqlite3_bind_int(stmt, 1, metric.wid);
	sqlite3_bind_int(stmt, 2, metric.type);
	sqlite3_bind_text(stmt, 3, [metric.mname UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(stmt, 4, [metric.text UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 5, [metric.wname UTF8String], -1, SQLITE_TRANSIENT);

	int rc = sqlite3_step(stmt);
	
    sqlite3_finalize(stmt);
	
	if(rc != SQLITE_DONE)
		return -1;
	
	// SQLite provides a method which retrieves the value of the most recently auto-generated primary key sequence
	// in the database. To access this functionality, the table should have a column declared of type 
	// "INTEGER PRIMARY KEY"
	metric.rowid = sqlite3_last_insert_rowid(database);
	
	return 0;
}


- (int) modMetric:(Metric *)metric
{
	char *sql = "update metrics set wid=?, mtype=?, mname=?, metric=?, wname=? where rowid=?";
	sqlite3_stmt *stmt;
	
	if(sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
		[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
	
	sqlite3_bind_int(stmt, 1, metric.wid);
	sqlite3_bind_int(stmt, 2, metric.type);
	sqlite3_bind_text(stmt, 3, [metric.mname UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(stmt, 4, [metric.text UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(stmt, 5, [metric.wname UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(stmt, 6, metric.rowid);
	
	int rc = sqlite3_step(stmt);

    sqlite3_finalize(stmt);
	
	if(rc != SQLITE_DONE)
		return -1;

	return 0;
}


- (int) delMetric:(Metric *)metric
{
	char *sql = "delete from metrics where rowid=?";
	sqlite3_stmt *stmt;
	
	if(sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
		[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
	
	sqlite3_bind_int(stmt, 1, metric.rowid);
	
	int rc = sqlite3_step(stmt);
	
    sqlite3_finalize(stmt);
	
	if(rc != SQLITE_DONE)
		return -1;
    
    [self cleanupMetrics];
	
	return 0;
}


- (int) cleanupMetrics
{
	char *sql = "delete from metrics where wname not in (select name from workouts group by name order by name)";
	sqlite3_stmt *stmt;
	
	if(sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
		[self fatalError:NSLocalizedString(@"DatabaseError", nil)];
	
	int rc = sqlite3_step(stmt);
	
    sqlite3_finalize(stmt);
	
	if(rc != SQLITE_DONE)
		return -1;
	
	return 0;
}



// XXX
/*
 - (int) getWorkoutColor:(Workout *)workout
 {
 char *sql = "select color from workouts where name=? and wdate < strftime('%s','now') order by wdate desc limit 1";
 sqlite3_stmt *stmt;
 
 if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
 {
 [self fatalError:NSLocalizedString(@"DatabaseError", nil)];
 return -1;
 }
 
 sqlite3_bind_text(stmt, 1, [workout.name UTF8String], -1, SQLITE_TRANSIENT);
 
 int rc, color = -1;
 do {
 rc = sqlite3_step(stmt);
 if (rc == SQLITE_ROW)
 {
 color = sqlite3_column_int(stmt, 0);
 }
 } while(rc == SQLITE_ROW);
 
 sqlite3_finalize(stmt);
 
 return color;
 }
 
 - (NSString *) getWorkoutNotes:(Workout *)workout
 {
 char *sql = "select notes from workouts where name=? and wdate < strftime('%s','now') order by wdate desc limit 1";
 sqlite3_stmt *stmt;
 
 if (sqlite3_prepare_v2(database, sql, -1, &stmt, NULL) != SQLITE_OK)
 {
 [self fatalError:NSLocalizedString(@"DatabaseError", nil)];
 return NULL;
 }
 
 sqlite3_bind_text(stmt, 1, [workout.name UTF8String], -1, SQLITE_TRANSIENT);
 
 int rc;
 NSString *notes = nil;
 do {
 rc = sqlite3_step(stmt);
 if (rc == SQLITE_ROW)
 {
 char *s = (char *)sqlite3_column_text(stmt, 0);
 if(s)
 notes = [NSString stringWithCString:(const char *)s encoding:NSUTF8StringEncoding];
 }
 } while(rc == SQLITE_ROW);
 
 sqlite3_finalize(stmt);
 
 return notes;
 }
 */


+ (NSString *)stringFromTimestamp:(long)ts
{
    int hours = ts / 3600;
	int mins = (ts % 3600) / 60;
	int secs = ts % 60;
    
    if(hours)
        return [NSString stringWithFormat:@"%02dh%02dm", hours, mins];
    else
        return [NSString stringWithFormat:@"%02dm%02ds", mins, secs];
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[alertView release];
	exit(0);
}


@end


#pragma mark -


UIImage *makeButton(CGFloat red, CGFloat green, CGFloat blue)
{
	CGContextRef context;
	CGColorSpaceRef colorSpace;
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create a bitmap graphics context the size of the image
	context = CGBitmapContextCreate (NULL, 17, 26, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
	
	// free the rgb colorspace
	CGColorSpaceRelease(colorSpace);    
	
	CGImageRef maskImage = buttonMasks[0].CGImage;
	CGContextClipToMask(context, CGRectMake(0, 0, 17, 26), maskImage);
	
	CGContextSetRGBFillColor(context, red, green, blue, 0.7);
	CGContextFillRect(context, CGRectMake(0, 0, 17, 26));
	
	CGContextDrawImage(context, CGRectMake(0, 0, 17, 26), buttonMasks[3].CGImage);
	//CGContextDrawImage(context, CGRectMake(0, 0, 17, 26), icals[4].CGImage);
	
	// Create CGImageRef of the main view bitmap content, and then
	// release that bitmap context
	CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	// convert the finished resized image to a UIImage 
	UIImage *theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
	// image is retained by the property setting above, so we can 
	// release the original
	CGImageRelease(mainViewContentBitmapContext);
	
	// return the image
	return theImage;
}


UIImage *makeBullet(CGFloat red, CGFloat green, CGFloat blue)
{
	CGContextRef context;
	CGColorSpaceRef colorSpace;
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create a bitmap graphics context the size of the image
	context = CGBitmapContextCreate (NULL, 9, 8, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
	
	// free the rgb colorspace
	CGColorSpaceRelease(colorSpace);    
	
	CGImageRef maskImage = bulletMasks[0].CGImage;
	CGContextClipToMask(context, CGRectMake(0, 0, 9, 8), maskImage);
	
	CGContextSetRGBFillColor(context, red, green, blue, 0.7);
	CGContextFillRect(context, CGRectMake(0, 0, 9, 8));
	
	CGContextDrawImage(context, CGRectMake(0, 0, 9, 8), bulletMasks[1].CGImage);
	
	// Create CGImageRef of the main view bitmap content, and then
	// release that bitmap context
	CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	
	// convert the finished resized image to a UIImage 
	UIImage *theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext];
	// image is retained by the property setting above, so we can 
	// release the original
	CGImageRelease(mainViewContentBitmapContext);
	
	// return the image
	return theImage;
}


void loadButtons()
{
	buttonMasks[0] = [[UIImage imageNamed:@"b_mask.png"] retain];
	buttonMasks[1] = [[[UIImage imageNamed:@"b_pressed.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:10] retain];
	buttonMasks[2] = [[[UIImage imageNamed:@"b_shine.png"] stretchableImageWithLeftCapWidth:8 topCapHeight:10] retain];
	buttonMasks[3] = [[UIImage imageNamed:@"b_stroke.png"] retain];
    
    bulletMasks[0] = [[UIImage imageNamed:@"bul_mask.png"] retain];
	bulletMasks[1] = [[UIImage imageNamed:@"bul_stroke.png"] retain];
	
	ast = [[UIImage imageNamed:@"asteric-w.png"] retain];
	
	buttonColors[0] = [[makeButton(0.5, 0.5, 0.5) stretchableImageWithLeftCapWidth:8 topCapHeight:10] retain]; // gray
	buttonColors[1] = [[makeButton(1, 0, 0) stretchableImageWithLeftCapWidth:8 topCapHeight:10] retain]; // red
	buttonColors[2] = [[makeButton(1, 0.3, 0) stretchableImageWithLeftCapWidth:8 topCapHeight:10] retain]; // orange
	buttonColors[3] = [[makeButton(0.85, 0.55, 0) stretchableImageWithLeftCapWidth:8 topCapHeight:10] retain]; // yellow
	buttonColors[4] = [[makeButton(0, 0.6, 0.1) stretchableImageWithLeftCapWidth:8 topCapHeight:10] retain]; // green
	buttonColors[5] = [[makeButton(0, 0.4, 0.8) stretchableImageWithLeftCapWidth:8 topCapHeight:10] retain]; // lightblue
	buttonColors[6] = [[makeButton(0, 0.1, 0.5) stretchableImageWithLeftCapWidth:8 topCapHeight:10] retain]; // darkblue
	buttonColors[7] = [[makeButton(1, 0, 1) stretchableImageWithLeftCapWidth:8 topCapHeight:10] retain]; // magenta
    
    bulletColors[0] = [makeBullet(0.5, 0.5, 0.5) retain]; // gray
	bulletColors[1] = [makeBullet(1, 0, 0) retain]; // red
	bulletColors[2] = [makeBullet(1, 0.3, 0) retain]; // orange
	bulletColors[3] = [makeBullet(0.85, 0.55, 0) retain]; // yellow
	bulletColors[4] = [makeBullet(0, 0.6, 0.1) retain]; // green
	bulletColors[5] = [makeBullet(0, 0.4, 0.8) retain]; // lightblue
	bulletColors[6] = [makeBullet(0, 0.1, 0.5) retain]; // darkblue
	bulletColors[7] = [makeBullet(1, 0, 1) retain]; // magenta
}

UIImage *colorizeImage(UIImage *baseImage, UIColor *theColor)
{
    UIGraphicsBeginImageContext(baseImage.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, baseImage.CGImage);
    
    [theColor set];
    CGContextFillRect(ctx, area);
	
    CGContextRestoreGState(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    
    CGContextDrawImage(ctx, area, baseImage.CGImage);
	
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

NSInteger getSystemVersionAsInteger()
{
    int index = 0;
    NSInteger version = 0;
	
    NSArray *digits = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    NSEnumerator *enumer = [digits objectEnumerator];
	
	for(NSString *number in enumer)
	{
        if(index > 2)
			break;
		
		NSInteger multipler = powf(100, 2-index);
        version += [number intValue]*multipler;
        index++;
    }
	return version;
}

