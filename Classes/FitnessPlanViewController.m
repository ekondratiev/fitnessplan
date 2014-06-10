//
//  FitnessPlanViewController.m
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FitnessPlanViewController.h"
#import "FitnessPlanAppDelegate.h"
#import "AddWorkoutViewController.h"
#import "WorkoutButton.h"
#import "Settings.h"
#import "Constants.h"
#import "GCMathParser.h"


int buttonsView = 0;
NSString *buttonsViewLabels[10];


@implementation FitnessPlanViewController

@synthesize toolbar;
@synthesize bannerGradient;
@synthesize monthLabel;
@synthesize monthButton;
@synthesize oldestWorkout;


- (void) viewDidLoad
{	
	delegate = (FitnessPlanAppDelegate *) [[UIApplication sharedApplication] delegate];
	
	dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	weekdayNames = [[dateFormatter shortWeekdaySymbols] retain];
	
	NSRange rc = [dateFormatter.locale.localeIdentifier rangeOfString:@"ru_"];
	if(rc.location == 0)
		monthNames = [[NSArray alloc] initWithObjects: @"Январь", @"Февраль", @"Март", @"Апрель",
					  @"Май", @"Июнь", @"Июль", @"Август",
					  @"Сентябрь", @"Октябрь", @"Ноябрь", @"Декабрь", nil];
	else
		monthNames = [[dateFormatter monthSymbols] retain];
    
    // XXX
    buttonsViewLabels[0] = [NSLocalizedString(@"Name", nil) retain];
    buttonsViewLabels[1] = [[NSString stringWithFormat:@"%@ 1", NSLocalizedString(@"Amount", nil)] retain];
    buttonsViewLabels[2] = [[NSString stringWithFormat:@"%@ 2", NSLocalizedString(@"Amount", nil)] retain];
    buttonsViewLabels[3] = [[NSString stringWithFormat:@"%@ 3", NSLocalizedString(@"Amount", nil)] retain];
    buttonsViewLabels[4] = [[NSString stringWithFormat:@"%@ 1", NSLocalizedString(@"Time", nil)] retain];
    buttonsViewLabels[5] = [[NSString stringWithFormat:@"%@ 2", NSLocalizedString(@"Time", nil)] retain];
    buttonsViewLabels[6] = [[NSString stringWithFormat:@"%@ 3", NSLocalizedString(@"Time", nil)] retain];
    buttonsViewLabels[7] = [NSLocalizedString(@"HRate", nil) retain];
    buttonsViewLabels[8] = [NSLocalizedString(@"Weight", nil) retain];
    buttonsViewLabels[9] = [NSLocalizedString(@"Weather", nil) retain];
	

	self.navigationItem.title = NSLocalizedString(@"FitnessPlanTitle", nil);
	
	bannerGradient.image = colorizeImage([UIImage imageNamed:@"bannergradient.png"], settings.banner_tint_color);
	[monthLabel setFont:[UIFont boldSystemFontOfSize:18.0]];
	[monthLabel setHighlightedTextColor:MONTH_LABEL_HL_COLOR];
    monthLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.6];
    monthLabel.shadowOffset = CGSizeMake(0, 1);
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
											   target:self
											   action:@selector(addWorkout)]
											  autorelease];
	
	UIButton *b = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[b setBounds:CGRectMake(0, 0, 30, 20)];
	[b addTarget:self action:@selector(viewAbout) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:b];
	
	self.toolbar.barStyle = UIBarStyleBlackOpaque;
	self.toolbar.tintColor = settings.app_tint_color;
	[self setupToolbarButtons];
	
	// setup calendar
	calendar = [[THCalendarInfo calendarInfo] retain];
	currentYear = [calendar year];
	currentMonth = [calendar month];
	currentDay = [calendar dayOfMonth];
	[calendar moveToFirstDayOfMonth];
	
	touchedDay = [[THCalendarInfo calendarInfo] retain];
	
	daysScrollView = [[TouchedScrollView alloc] initWithFrame:CGRectMake(0, 44, 320, 328)];
	daysScrollView.minimumZoomScale = 1;
	daysScrollView.maximumZoomScale = 1;
	
	if(settings.createOnTap) // create on tap
		[daysScrollView setTouchEndedTarget:self action:@selector(daysViewTouched:)];
	
	[self.view addSubview:daysScrollView];
	
	daysView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 31 * DAYSVIEW_LINE_HEIGHT + (DAYSVIEW_PADDING * 2))];
	daysView.tag = 5432;
	[daysScrollView addSubview:daysView];
	
	workoutButtons = [[NSMutableArray alloc] initWithCapacity:30];

	// XXX
	//workoutViewController = [[[WorkoutViewController alloc] initWithNibName:@"WorkoutView" bundle:nil]
	//						 autorelease];
    
    // notification view
    
    notifView = [[UIView alloc] initWithFrame:CGRectMake(60, 160, 200, 90)];
    notifView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [notifView.layer setCornerRadius:10];
    
    notifLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 90)];
    notifLabel.backgroundColor = [UIColor clearColor];
    notifLabel.textColor = [UIColor whiteColor];
    notifLabel.font = [UIFont boldSystemFontOfSize:18];
    notifLabel.textAlignment = UITextAlignmentCenter;
    notifLabel.text = NSLocalizedString(@"Notification", nil);
    [notifLabel.layer setShadowOffset:CGSizeMake(1, 2)];
    [notifLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [notifLabel.layer setShadowOpacity:0.5];
    [notifLabel.layer setShadowRadius:2];
    [notifView addSubview:notifLabel];
    [notifLabel release];
}

- (void) viewWillAppear:(BOOL)animated
{
    // change buttonsView
    if(settings.bigButtons && buttonsView == 0)
        buttonsView = 1;
    else if(!settings.bigButtons && buttonsView == 1)
        buttonsView = 0;

	[self displayMonth:YES];
}

- (void) setupToolbarButtons
{
	NSMutableArray *toolbarButtons = [[NSMutableArray alloc] init];
	
	UIBarButtonItem *b;
	// view history button
	b = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chart3.png"]
										 style:UIBarButtonItemStyleBordered
										target:self
										action:@selector(viewHistory)];
	[toolbarButtons addObject:b];
	[b release];
	
	// flexible space

	UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc]
										  initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
										  target:nil
										  action:NULL];
	[toolbarButtons addObject:flexibleSpaceItem];
	[flexibleSpaceItem release];
	
//	// users button
//	b = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"users.png"]
//										 style:UIBarButtonItemStyleBordered
//										target:self
//										action:@selector(showUsers)];
//	//b.style = UIBarButtonItemStyleBordered;
//	[toolbarButtons addObject:b];
//	[b release];
	
    b = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"view.png"]
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(changeView)];
    //b.style = UIBarButtonItemStyleBordered;
    [toolbarButtons addObject:b];
    [b release];
    
	[toolbar setItems:toolbarButtons];
	[toolbarButtons release];
}

-(UIImage *) makeDaysBackground
{
	int daysInMonth = [calendar daysInMonth];
	int wdIndex = [calendar dayOfWeek];
	
	if([calendar firstDayOfWeek] == 1) // Sunday
	{
		if(wdIndex == 1) wdIndex = 7;
		else
			wdIndex--;
	}
	else if([calendar firstDayOfWeek] == 7) // arabic
	{
		wdIndex += 5;
		if(wdIndex >= 7) wdIndex -= 6;
	}
	
	UIGraphicsBeginImageContext(CGSizeMake(SCREEN_WIDTH, 31 * DAYSVIEW_LINE_HEIGHT + (DAYSVIEW_PADDING * 2) + 62));
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(context, 1);
	CGContextSetShouldAntialias(context, NO);
	for(int i = 0; i <= daysInMonth; i++)
	{
		if(wdIndex == 6 && i < daysInMonth) // saturday
		{
			CGContextSetRGBFillColor(context, 0.96, 0.96, 0.86, 1);
			CGContextFillRect(context, CGRectMake(0, i * DAYSVIEW_LINE_HEIGHT + DAYSVIEW_PADDING, 320, DAYSVIEW_LINE_HEIGHT));
		}
		else if(wdIndex == 7 && i < daysInMonth) // sunday
		{
			CGContextSetRGBFillColor(context, 0.93, 0.93, 0.82, 1);
			CGContextFillRect(context, CGRectMake(0, i * DAYSVIEW_LINE_HEIGHT + DAYSVIEW_PADDING, 320, DAYSVIEW_LINE_HEIGHT));
		}
		
		CGContextBeginPath(context);
		CGContextSetRGBStrokeColor(context, 0.79, 0.79, 0.79, 1);
		CGContextMoveToPoint(context, 28, i * DAYSVIEW_LINE_HEIGHT + DAYSVIEW_PADDING);
		CGContextAddLineToPoint(context, 310, i * DAYSVIEW_LINE_HEIGHT + DAYSVIEW_PADDING);
		CGContextStrokePath(context);
		
		wdIndex++;
		if(wdIndex > 7) wdIndex = 1;
	}
	
	// draw men
	/*
	CGSize sz = [man1 size];
	[man1 drawInRect:CGRectMake(280, daysInMonth * DAYSVIEW_LINE_HEIGHT + DAYSVIEW_PADDING - 3, sz.width, sz.height)];
	
	sz = [man2 size];
	[man2 drawInRect:CGRectMake(50, daysInMonth * DAYSVIEW_LINE_HEIGHT + DAYSVIEW_PADDING + 4, sz.width, sz.height)];
	
	sz = [man3 size];
	[man3 drawInRect:CGRectMake(230, daysInMonth * DAYSVIEW_LINE_HEIGHT + DAYSVIEW_PADDING - 3, sz.width, sz.height)];
	*/
	
	CGContextSetShouldAntialias(context, YES);
	UIFont *theFont = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
	UIFont *weekDaysFont = [UIFont boldSystemFontOfSize:10];
	
	NSString *label = @"29";
	CGSize size = [label sizeWithFont:theFont];
	int offset = (DAYSVIEW_LINE_HEIGHT - (size.height * 2)) / 2  + DAYSVIEW_PADDING + 3;
	
	wdIndex = [calendar dayOfWeek];
	if([calendar firstDayOfWeek] == 2) // Monday -- first day of week
	{
		wdIndex = (wdIndex == 7) ? 1 : wdIndex + 1;
	}
	else if([calendar firstDayOfWeek] == 7) // Sunday -- first day of week
	{
		wdIndex += 5;
		if(wdIndex >= 7) wdIndex -= 6;
	}
	
	// XXX due to strange iPad crash report
	if(wdIndex == 0) wdIndex = 1;
	
	for(int today, i = 0; i < daysInMonth; i++)
	{
		today = (i +1) == currentDay && [calendar month] == currentMonth && [calendar year] == currentYear;
		
		CGRect rect = CGRectMake(0, i * DAYSVIEW_LINE_HEIGHT + offset, 24, size.height);
		
		if(today)
			CGContextSetRGBFillColor(context, 0, 0.4, 0.9, 1);
		else
			CGContextSetRGBFillColor(context, 0, 0, 0, 1);
		
		label = [NSString stringWithFormat:@"%d", i + 1];
		[label drawInRect:rect
				 withFont:theFont
			lineBreakMode:UILineBreakModeTailTruncation
				alignment:UITextAlignmentRight];
		
		CGRect weekDayRect = CGRectMake(0, rect.origin.y + size.height, 24, rect.size.height);
		
		if(today)
			CGContextSetRGBFillColor(context, 0, 0.4, 0.9, 0.5);
		else
			CGContextSetRGBFillColor(context, 0, 0, 0, 0.5);
		
		NSString *wdName = [weekdayNames objectAtIndex:wdIndex - 1];
		[wdName drawInRect:weekDayRect
				  withFont:weekDaysFont
			 lineBreakMode:UILineBreakModeClip
				 alignment:UITextAlignmentRight];
		
		wdIndex = (wdIndex == 7) ? 1 : wdIndex + 1;
	}

	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();	
	return img;
}

- (NSArray *) placeButtons:(NSArray *)list
{
	int days[31] = { 0 };
	int cday = 0;
	int padding;
	
	NSMutableArray *blist = [NSMutableArray arrayWithCapacity:30];
	
	for(Workout *w in list)
	{
		int d = [w.wdate dayOfMonth] - 1;
		days[d]++;
	}
	
	int width = BUTTON_WIDTH;
	CGFloat hStep = (280.0 - BUTTON_WIDTH - 5) / (21 - 6 - 1);
	
	CGFloat xpos, ppos, gap;
	CGFloat hpos;
	CGFloat vibrance = 5;
	int passed;
	
	for(Workout *w in list)
	{
		int d = [w.wdate dayOfMonth];
		
		if(cday != d)
		{
			cday = d;
			padding = (settings.bigButtons) ? 1 : 3;
			xpos = 0;
			ppos = 0;
			passed = 0;
		}
		
		int hr = [w.wdate hour];
		
		if(hr < 6) hr = 6;
		else if(hr > 21) hr = 21;
		
		// calculate hpos
		if(xpos == 0 && hr < 11)
			hpos = 0;
		else
			hpos = (hr - 6) * hStep;
		
		gap = hpos - ppos;
		
		if(gap > (width * 0.3))
		{
			if((days[d-1] - passed) > 1)
			{
				if(hr > 14)
					hpos -= ((days[d-1] - passed) * hStep) / 1.2;
				else if(hr < 14)
					hpos -= gap / 4;
			}
		}
		
		if(passed > 0 && hr < 11 && days[d-1] <= 6)
			hpos += hStep * 0.7;
		
		if(xpos < hpos)
			xpos = hpos;
		
		WorkoutButton *b = [WorkoutButton createWithWorkout:w pos:xpos width:width padding:padding];
		[b addTarget:self action:@selector(openWorkout:) forControlEvents:UIControlEventTouchUpInside];
		[blist addObject:b];
		
		ppos = xpos;
		
		xpos += hStep + vibrance;
		
		passed++;
		
		if(!settings.bigButtons)
		{
			switch(padding) {
				case 0:
					padding = 23;
					break;
				case 18:
					padding = 0;
					break;
				case 3:
					padding = 18;
					break;
				case 23:
					padding = 3;
			}
		}
	}
	
	return blist;
}

- (void)displayMonth:(BOOL)showToday
{	
	// remove buttons
	for(WorkoutButton *b in workoutButtons)
	{
		[b removeFromSuperview];
	}
	[workoutButtons removeAllObjects];
	
	// make new days list
	if(daysBackground != nil)
	{
		[daysBackground removeFromSuperview];
		[daysBackground release];
	}
	
	daysBackground = [[UIImageView alloc] initWithImage:[self makeDaysBackground]];
	[daysView addSubview:daysBackground];
	
	// adjust days view
	int days = [calendar daysInMonth];
	[daysScrollView setContentSize:CGSizeMake(SCREEN_WIDTH, days * DAYSVIEW_LINE_HEIGHT + (DAYSVIEW_PADDING * 2) + 62)];
	
	// load activities for new month
	NSArray *workouts = [delegate workoutsForMonth:[calendar month] year:[calendar year]];
	
	// XXX place activities buttons
	NSArray *buttons = [self placeButtons:workouts];
	[workoutButtons addObjectsFromArray:buttons];
	
	for(WorkoutButton *b in workoutButtons)
	{
		[daysView addSubview:b];
	}
	
	monthLabel.text = [NSString stringWithFormat:@"%@, %d", [monthNames objectAtIndex:([calendar month] - 1)], [calendar year]];
	if([calendar month] == currentMonth && [calendar year] == currentYear)
	{
		if(showToday)
		{
			CGRect r = CGRectMake(0, currentDay * DAYSVIEW_LINE_HEIGHT, 320, DAYSVIEW_LINE_HEIGHT);
			[daysScrollView scrollRectToVisible:r animated:NO];
		}
		[monthLabel setHighlighted:YES];
	}
	else
	{
		[monthLabel setHighlighted:NO];
	}
}

- (void) updateButtons
{
	// remove buttons
	for(WorkoutButton *b in workoutButtons)
	{
		[b removeFromSuperview];
	}
	[workoutButtons removeAllObjects];
	
	NSArray *workouts = [delegate workoutsForMonth:[calendar month] year:[calendar year]];
	
	NSArray *buttons = [self placeButtons:workouts];
	[workoutButtons addObjectsFromArray:buttons];
	
	for(WorkoutButton *b in workoutButtons)
	{
		[daysView addSubview:b];
	}
}

- (void) daysViewTouched:(NSValue *)val
{
	CGPoint p;
	[val getValue:&p];
	
	if(p.x < 30 || p.y < DAYSVIEW_PADDING)
		return;
	
	int x = ((p.x - 30) / 17) +6;
	int y = ((p.y - DAYSVIEW_PADDING) / DAYSVIEW_LINE_HEIGHT);
	
	if(y > [calendar daysInMonth])
		return;

	touchedDay = [[THCalendarInfo calendarInfo] retain];
	[touchedDay setDate:[calendar date]];
	[touchedDay moveToFirstDayOfMonth];
	[touchedDay adjustDays:y];
	[touchedDay setHour:x minute:0 second:0];
	
	NSString *prompt = [NSString stringWithFormat:@"%02d:00, %@", x, [dateFormatter stringFromDate:[touchedDay date]]];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CreateNewWorkout", nil)
													message:prompt
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
										  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alert show];
}

- (void) openWorkout:(id)sender
{
	WorkoutButton *b = sender;
	
	if(workoutViewController == NULL)
		//workoutViewController = [[WorkoutViewController alloc] initWithNibName:@"WorkoutView" bundle:nil];
		workoutViewController = [[WorkoutViewController alloc] init];

	workoutViewController.workout = b.workout;
	
	[[self navigationController] pushViewController:workoutViewController animated:YES];
}


- (IBAction) nextMonth
{
	[calendar moveToNextMonth];
	[self displayMonth:YES];
}

- (IBAction) prevMonth
{
	[calendar moveToPreviousMonth];
	[self displayMonth:YES];
}

- (void) addWorkout
{
	[self addWorkout:nil];
}

- (void) addWorkout:(Workout *)newWorkout
{	
	if(addWorkoutController == nil)
		addWorkoutController = [[AddWorkoutViewController alloc] initWithNibName:@"EditWorkoutView" bundle:nil];
	
	Workout *workout = (newWorkout) ? newWorkout : [[[Workout alloc] init] autorelease];
	
	addWorkoutController.editedWorkout = workout;
	
	if(addNavigationController == nil)
		addNavigationController = [[UINavigationController alloc] initWithRootViewController:addWorkoutController];
	
	[[self navigationController] presentModalViewController:addNavigationController animated:YES];
}

- (void)changeView2
{
    for(WorkoutButton *b in workoutButtons)
		[b setNeedsDisplay];
}


- (void)changeView
{
    [self performSelectorInBackground:@selector(changeView2) withObject:nil];
    
    buttonsView++;
	buttonsView %= 10;
    if(settings.bigButtons && buttonsView == 0)
        buttonsView = 1;
    
    notifLabel.text = buttonsViewLabels[buttonsView];
    if(!notifView.superview)
        [self.view addSubview:notifView];
    
    [UIView animateWithDuration:0.3
                          delay:0.4
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         notifView.alpha = 0;
                     }
                     completion:^(BOOL finished){
                         [notifView removeFromSuperview];
                         notifView.alpha = 1;
                     }];
}


- (void)viewHistory
{
    if(historyViewController == NULL)
		historyViewController = [[HistoryViewController alloc] init];
	
    [historyViewController updateWorkouts];
	[[self navigationController] pushViewController:historyViewController animated:YES];
}


- (void) viewAbout
{
	if(aboutViewController == nil)
	{
		aboutViewController = [[AboutViewController alloc] init];
		aboutNavigationController = [[UINavigationController alloc]
											initWithRootViewController:aboutViewController];
	}
	[[self navigationController] presentModalViewController:aboutNavigationController animated:YES];
}

- (void) dealloc
{
	[workoutViewController release];
	[calendar release];
	[dateFormatter release];
	[weekdayNames release];
	[monthLabel release];
	[monthNames release];
	[daysScrollView release];
	[daysView release];
	[super dealloc];
}


#pragma mark -
#pragma mark Go to date


- (void)gotoDate
{
    int month = [pickerView selectedRowInComponent:0];
    int year = [pickerView selectedRowInComponent:1];
    [gotoSheet dismissWithClickedButtonIndex:0 animated:YES];
    
    [calendar setYeat:[oldestWorkout.wdate year]+year month:month+1 day:1];
    [self displayMonth:NO];
}


- (void)dismissActionSheet
{
    [gotoSheet dismissWithClickedButtonIndex:0 animated:YES];
}


- (IBAction)gotoSheet
{
    if(!gotoSheet)
    {        
        gotoSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        
        [gotoSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
        
        CGRect pickerFrame = CGRectMake(0, 40, 0, 0);
        
        pickerView = [[UIPickerView alloc] initWithFrame:pickerFrame];
        pickerView.showsSelectionIndicator = YES;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        
        [gotoSheet addSubview:pickerView];
        [pickerView release];
        
        UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:NSLocalizedString(@"Go", nil)]];
        closeButton.momentary = YES; 
        closeButton.frame = CGRectMake(240, 7.0f, 70.0f, 30.0f);
        closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
        closeButton.tintColor = [UIColor blackColor];
        [closeButton addTarget:self action:@selector(gotoDate) forControlEvents:UIControlEventValueChanged];
        [gotoSheet addSubview:closeButton];
        [closeButton release];
        
        UISegmentedControl *okButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:NSLocalizedString(@"Cancel", nil)]];
        okButton.momentary = YES; 
        okButton.frame = CGRectMake(10, 7.0f, 70.0f, 30.0f);
        okButton.segmentedControlStyle = UISegmentedControlStyleBar;
        okButton.tintColor = [UIColor blackColor];
        [okButton addTarget:self action:@selector(dismissActionSheet) forControlEvents:UIControlEventValueChanged];
        [gotoSheet addSubview:okButton];
        [okButton release];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(85, 7, 150, 30)];
        title.backgroundColor = [UIColor clearColor];
        title.textColor = [UIColor whiteColor];
        title.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
        title.shadowOffset = CGSizeMake(0, -1);
        title.font = [UIFont boldSystemFontOfSize:16];
        title.textAlignment = UITextAlignmentCenter;
        title.text = NSLocalizedString(@"GoToTitle", nil);
        [gotoSheet addSubview:title];
        [title release];
    }
    
    self.oldestWorkout = [delegate getOldestWorkout];
    
    [gotoSheet showInView:self.view];
    [gotoSheet setBounds:CGRectMake(0, 0, 320, 485)];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2; // month, year
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
        return 12;
    else
        return currentYear - [oldestWorkout.wdate year] + 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
        return [monthNames objectAtIndex:row];
    else
        return [NSString stringWithFormat:@"%d", [oldestWorkout.wdate year] + row];
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[alertView release];
	if(buttonIndex == 1) // OK
	{
		Workout *w = [[[Workout alloc] init] autorelease];
		w.wdate = touchedDay;
		[self addWorkout:w];
	}
	[touchedDay release];
}

@end
