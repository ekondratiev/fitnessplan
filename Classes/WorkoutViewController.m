
//
//  WorkoutViewController.m
//  FitnessPlan2
//
//  Created by Женя on 14.09.10.
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WorkoutViewController.h"
#import "Constants.h"
#import "GCMathParser.h"
#import "BuyProViewController.h"


@implementation WorkoutViewController

@synthesize workout;

- (id)init
{
	if((self = [super init]))
	{
		self.navigationItem.title = NSLocalizedString(@"Workout", nil);
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		[[self editButtonItem] setTarget:self];
		[[self editButtonItem] setAction:@selector(goEdit)];
		
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		
		UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)] autorelease];
		scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        //scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
		
		self.view = scrollView;
	}
	return self;
}


- (void)viewWillAppear:(BOOL)animated
{
	// XXX check for return from modal VC
    if(settings.isPro)
    {
        [self createViewPro];
        [self updateViewPro];
    }
    else
        [self createView];
}


- (void)buyPro
{
    BuyProViewController *buyProVC = [[[BuyProViewController alloc] init] autorelease];
    [self.navigationController pushViewController:buyProVC animated:YES];
}


- (void) updateViewPro
{	
	CGRect frame;
	
	workoutNameLabel.text = workout.name;
	
	if(workout.weather_t != -9999)
	{
		frame = weatherIcon.frame;
		frame.origin.x = 226;
		weatherIcon.frame = frame;
		temperatureLabel.text = [NSString stringWithFormat:@"%d\u00B0%@", workout.weather_t, (settings.temperatureUnit) ? @"C" : @"F"];
	}
	else
	{
		frame = weatherIcon.frame;
		frame.origin.x = 256;
		weatherIcon.frame = frame;
		temperatureLabel.text = nil;
	}
	
	weatherIcon.image = (workout.weather_c) ? [settings.cloudinessImages objectAtIndex:workout.weather_c] : nil;
	
    // XXX
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	dateLabel.text = [NSString stringWithFormat:@"on %@", [dateFormatter stringFromDate:[workout.wdate date]]];
	
	if([workout hasRepeat])
	{
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        // XXX
		repeatedLabel.text = [NSString stringWithFormat:@"repeating every %@ till %@",
							  [settings.repList objectAtIndex:workout.rstep],
							  [dateFormatter stringFromDate:[workout.rtill date]]];
	}
	
	double whole, mod;
	
	a1nameLabel.text = workout.amount_name_1;
	if(workout.amount_1)
	{
		mod = modf(workout.amount_1, &whole);
		if(mod)
			a1valueLabel.text = [NSString stringWithFormat:@"%.2f", workout.amount_1];
		else
			a1valueLabel.text = [NSString stringWithFormat:@"%.0f", workout.amount_1];
	}
	else
		a1valueLabel.text = @"--";
	
	a2nameLabel.text = workout.amount_name_2;
	if(workout.amount_2)
	{
		mod = modf(workout.amount_2, &whole);
		if(mod)
			a2valueLabel.text = [NSString stringWithFormat:@"%.2f", workout.amount_2];
		else
			a2valueLabel.text = [NSString stringWithFormat:@"%.0f", workout.amount_2];
	}
	else
		a2valueLabel.text = @"--";
	
	a3nameLabel.text = workout.amount_name_3;
	if(workout.amount_3)
	{
		mod = modf(workout.amount_3, &whole);
		if(mod)
			a3valueLabel.text = [NSString stringWithFormat:@"%.2f", workout.amount_3];
		else
			a3valueLabel.text = [NSString stringWithFormat:@"%.0f", workout.amount_3];
	}
	else
		a3valueLabel.text = @"--";
	
	if(workout.time_1)
        time1valueLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",
                                workout.time_1 / 3600,
                                (workout.time_1 % 3600) / 60,
                                workout.time_1 % 60];
	else
		time1valueLabel.text = @"--";
	
	if(workout.time_2)
        time2valueLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",
                                workout.time_2 / 3600,
                                (workout.time_2 % 3600) / 60,
                                workout.time_2 % 60];
	else
		time2valueLabel.text = @"--";
    
    if(workout.time_3)
        time3valueLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",
                                workout.time_3 / 3600,
                                (workout.time_3 % 3600) / 60,
                                workout.time_3 % 60];
	else
		time3valueLabel.text = @"--";
	
	if(workout.hrate)
		hrateValueLabel.text = [NSString stringWithFormat:@"%d", workout.hrate];
	else
		hrateValueLabel.text = @"--";
	
	if(workout.weight)
	{
		mod = modf(workout.weight, &whole);
		if(mod)
			weightValueLabel.text = [NSString stringWithFormat:@"%.2f", workout.weight];
		else
			weightValueLabel.text = [NSString stringWithFormat:@"%.0f", workout.weight];
	}
	else
		weightValueLabel.text = @"--";
    
    if(workout.feeling)
        feelingIcon.image = [settings.emoImages objectAtIndex:[Workout feelingToIndex:workout.feeling]];	
    else
        feelingIcon.image = nil;
}


- (void)createViewPro
{
    if(innerView)
    {
        [innerView removeFromSuperview];
        [innerView release];
    }

    CGRect innerFrame = CGRectMake(10, 10, 300, 440);
    
	innerView = [[UIView alloc] initWithFrame:innerFrame];
	//innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	innerView.backgroundColor = [UIColor whiteColor];
	[innerView.layer setCornerRadius:10];
	[innerView.layer setBorderColor:[[UIColor colorWithWhite:0.6 alpha:1] CGColor]];
	[innerView.layer setBorderWidth:1];
	
	[self.view addSubview:innerView];
	
	workoutNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 210, 24)];
	workoutNameLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];//[UIFont boldSystemFontOfSize:20];
	[innerView addSubview:workoutNameLabel];
	[workoutNameLabel release];
	//workoutNameLabel.text = @"Workout Name";
	
	weatherIcon = [[UIImageView alloc] initWithFrame:CGRectMake(226, 10, 26, 26)]; // 36
	[innerView addSubview:weatherIcon];
	[weatherIcon release];
	//weatherIcon.image = [UIImage imageNamed:@"snowy.png"];
	
	temperatureLabel = [[UILabel alloc] initWithFrame:CGRectMake(256, 10, 40, 24)]; // 39
	temperatureLabel.font = settings.smallDetailsFont;
	temperatureLabel.adjustsFontSizeToFitWidth = YES;
	temperatureLabel.lineBreakMode = UILineBreakModeClip;
	temperatureLabel.backgroundColor = [UIColor clearColor];
	[innerView addSubview:temperatureLabel];
	[temperatureLabel release];
	//temperatureLabel.text = [NSString stringWithFormat:@"%d\u00B0", -33];
	
	dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 39, 170, 16)];
	dateLabel.font = settings.smallDetailsFont;
	[innerView addSubview:dateLabel];
	[dateLabel release];
	//dateLabel.text = @"on Dec, 27 2010 at 23:23 pm";
	
	CGPoint pos = CGPointMake(0, 58);
	
	if([workout hasRepeat])
	{
		repeatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 58, 280, 16)];
		repeatedLabel.font = [UIFont systemFontOfSize:14];
		[innerView addSubview:repeatedLabel];
		[repeatedLabel release];
		//repeatedLabel.text = @"repeating every 2 weeks till Jan, 12 2020";
		pos.y += 16;
	}
	
	pos.y += 8;
	
	a1nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, 93, 21)];
	a1nameLabel.font = settings.labelsFont;
	a1nameLabel.adjustsFontSizeToFitWidth = YES;
	a1nameLabel.backgroundColor = [UIColor clearColor];
	a1nameLabel.textAlignment = UITextAlignmentCenter;
	[innerView addSubview:a1nameLabel];
	[a1nameLabel release];
	//a1nameLabel.text = @"a1:";
	
	a2nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(103, pos.y, 93, 21)];
	a2nameLabel.font = settings.labelsFont;
	a2nameLabel.adjustsFontSizeToFitWidth = YES;
	a2nameLabel.backgroundColor = [UIColor clearColor];
	a2nameLabel.textAlignment = UITextAlignmentCenter;
	[innerView addSubview:a2nameLabel];
	[a2nameLabel release];
	//a2nameLabel.text = @"a2:";
	
	a3nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(196, pos.y, 93, 21)];
	a3nameLabel.font = settings.labelsFont;
	a3nameLabel.adjustsFontSizeToFitWidth = YES;
	a3nameLabel.backgroundColor = [UIColor clearColor];
	a3nameLabel.textAlignment = UITextAlignmentCenter;
	[innerView addSubview:a3nameLabel];
	[a3nameLabel release];
	//a3nameLabel.text = @"a3:";
	
	pos.y += 24;
	
	a1valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, 93, 21)];
	a1valueLabel.font = settings.digitsFont;
	a1valueLabel.backgroundColor = [UIColor clearColor];
	a1valueLabel.textAlignment = UITextAlignmentCenter;
	a1valueLabel.textColor = EDITABLE_TEXT_COLOR;
	[innerView addSubview:a1valueLabel];
	[a1valueLabel release];
	//a1valueLabel.text = @"98765";
	
	a2valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(103, pos.y, 93, 21)];
	a2valueLabel.font = settings.digitsFont;
	a2valueLabel.backgroundColor = [UIColor clearColor];
	a2valueLabel.textAlignment = UITextAlignmentCenter;
	a2valueLabel.textColor = EDITABLE_TEXT_COLOR;
	[innerView addSubview:a2valueLabel];
	[a2valueLabel release];
	//a2valueLabel.text = @"98765";
	
	a3valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(196, pos.y, 93, 21)];
	a3valueLabel.font = settings.digitsFont;
	a3valueLabel.backgroundColor = [UIColor clearColor];
	a3valueLabel.textAlignment = UITextAlignmentCenter;
	a3valueLabel.textColor = EDITABLE_TEXT_COLOR;
	[innerView addSubview:a3valueLabel];
	[a3valueLabel release];
	//a3valueLabel.text = @"98765";
	
	pos.y += 27 + 8;
	
	time1Label = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, 93, 21)];
	time1Label.font = settings.labelsFont;
	time1Label.backgroundColor = [UIColor clearColor];
	time1Label.textAlignment = UITextAlignmentCenter;
	[innerView addSubview:time1Label];
	[time1Label release];
	time1Label.text = NSLocalizedString(@"Time1", nil);
    
    time2Label = [[UILabel alloc] initWithFrame:CGRectMake(103, pos.y, 93, 21)];
	time2Label.font = settings.labelsFont;
	time2Label.backgroundColor = [UIColor clearColor];
	time2Label.textAlignment = UITextAlignmentCenter;
	[innerView addSubview:time2Label];
	[time2Label release];
	time2Label.text = NSLocalizedString(@"Time2", nil);
	
	time3Label = [[UILabel alloc] initWithFrame:CGRectMake(196, pos.y, 93, 21)];
	time3Label.font = settings.labelsFont;
	time3Label.backgroundColor = [UIColor clearColor];
	time3Label.textAlignment = UITextAlignmentCenter;
	[innerView addSubview:time3Label];
	[time3Label release];
	time3Label.text = NSLocalizedString(@"Time3", nil);
	
	pos.y += 24;
	
	time1valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, 93, 21)];
	time1valueLabel.font = settings.digitsFont;
	time1valueLabel.backgroundColor = [UIColor clearColor];
	time1valueLabel.textAlignment = UITextAlignmentCenter;
	time1valueLabel.textColor = EDITABLE_TEXT_COLOR;
	[innerView addSubview:time1valueLabel];
	[time1valueLabel release];
	//time1valueLabel.text = @"00:00:00";
	
	time2valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(103, pos.y, 93, 21)];
	time2valueLabel.font = settings.digitsFont;
	time2valueLabel.backgroundColor = [UIColor clearColor];
	time2valueLabel.textAlignment = UITextAlignmentCenter;
	time2valueLabel.textColor = EDITABLE_TEXT_COLOR;
	[innerView addSubview:time2valueLabel];
	[time2valueLabel release];
	//time2valueLabel.text = @"00:00:00";
    
    time3valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(196, pos.y, 93, 21)];
	time3valueLabel.font = settings.digitsFont;
	time3valueLabel.backgroundColor = [UIColor clearColor];
	time3valueLabel.textAlignment = UITextAlignmentCenter;
	time3valueLabel.textColor = EDITABLE_TEXT_COLOR;
	[innerView addSubview:time3valueLabel];
	[time3valueLabel release];
	//time3valueLabel.text = @"00:00:00";
	
	pos.y += 27 + 8 + 2;
	
	//	hrateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, 88, 21)];
	//	hrateLabel.font = settings.labelsFont;
	//	hrateLabel.backgroundColor = [UIColor clearColor];
	//	hrateLabel.textAlignment = UITextAlignmentRight;
	//	[innerView addSubview:hrateLabel];
	//	[hrateLabel release];
	//	
	//	hrateValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(104, pos.y+2, 30, 21)];
	//	hrateValueLabel.font = settings.digitsFont;
	//	hrateValueLabel.adjustsFontSizeToFitWidth = YES;
	//	hrateValueLabel.backgroundColor = [UIColor clearColor];
	//	hrateValueLabel.textAlignment = UITextAlignmentLeft;
	//	[innerView addSubview:hrateValueLabel];
	//	[hrateValueLabel release];
	
	hrateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, 93, 21)];
	hrateLabel.font = settings.labelsFont;
	hrateLabel.backgroundColor = [UIColor clearColor];
	hrateLabel.textAlignment = UITextAlignmentCenter;
	[innerView addSubview:hrateLabel];
	[hrateLabel release];
	hrateLabel.text = NSLocalizedString(@"HRate", nil);
	
	weightLabel = [[UILabel alloc] initWithFrame:CGRectMake(196, pos.y, 93, 21)];
	weightLabel.font = settings.labelsFont;
	weightLabel.backgroundColor = [UIColor clearColor];
	weightLabel.textAlignment = UITextAlignmentCenter;
	[innerView addSubview:weightLabel];
	[weightLabel release];
	weightLabel.text = NSLocalizedString(@"Weight", nil);
	
	pos.y += 24;
	
	hrateValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, 93, 21)];
	hrateValueLabel.font = settings.digitsFont;
	hrateValueLabel.adjustsFontSizeToFitWidth = YES;
	hrateValueLabel.backgroundColor = [UIColor clearColor];
	hrateValueLabel.textAlignment = UITextAlignmentCenter;
	hrateValueLabel.textColor = EDITABLE_TEXT_COLOR;
	[innerView addSubview:hrateValueLabel];
	[hrateValueLabel release];
	
	weightValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(196, pos.y, 93, 21)];
	weightValueLabel.font = settings.digitsFont;
	weightValueLabel.backgroundColor = [UIColor clearColor];
	weightValueLabel.textAlignment = UITextAlignmentCenter;
	weightValueLabel.textColor = EDITABLE_TEXT_COLOR;
	[innerView addSubview:weightValueLabel];
	[weightValueLabel release];	
	
	
	//	NSString *weight = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Weight", nil)];
	//	CGSize sz = [weight sizeWithFont:settings.labelsFont
	//							forWidth:120
	//					   lineBreakMode:UILineBreakModeTailTruncation];
	//	weightLabel = [[UILabel alloc] initWithFrame:CGRectMake(168, pos.y, sz.width, 21)];
	//	weightLabel.font = settings.labelsFont;
	//	weightLabel.backgroundColor = [UIColor clearColor];
	//	[innerView addSubview:weightLabel];
	//	[weightLabel release];
	//	weightLabel.text = weight;
	//	
	//	weightValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(168 + sz.width + 4, pos.y+2, 60, 21)];
	//	weightValueLabel.font = settings.digitsFont;
	//	weightValueLabel.backgroundColor = [UIColor clearColor];
	//	weightValueLabel.textAlignment = UITextAlignmentLeft;
	//	[innerView addSubview:weightValueLabel];
	//	[weightValueLabel release];
	
	feelingIcon = [[UIImageView alloc] initWithFrame:CGRectMake(135, pos.y-12, 26, 26)];
	feelingIcon.image = [settings.emoImages objectAtIndex:[Workout feelingToIndex:workout.feeling]];
	[innerView addSubview:feelingIcon];
	[feelingIcon release];
	
	pos.y += 26;
    
    pos.y += 15;
    
    if(settings.isPro)
    {
        UIImageView *hr1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, pos.y, 260, 3)];
        hr1.image = [UIImage imageNamed:@"hr.png"];
        hr1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        hr1.backgroundColor = [UIColor darkGrayColor];
        [innerView addSubview:hr1];
        [hr1 release];
        
        pos.y += 3 + 15;
        
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ////
        //// Metrics
        ////
        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
        metricsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, 200, 21)];
        metricsLabel.font = settings.labelsFont;
        [innerView addSubview:metricsLabel];
        [metricsLabel release];
                
        metricsEditButton = [[ZIStoreButton alloc] initWithFrame:CGRectMake(217, pos.y-2, 72, 25)];
        [metricsEditButton setTitle:NSLocalizedString(@"Edit", nil) forState:UIControlStateNormal];
        [metricsEditButton addTarget:self action:@selector(editMetrics) forControlEvents:UIControlEventTouchUpInside];
        [innerView addSubview:metricsEditButton];
        
        pos.y += 22 + 6;
        
        FitnessPlanAppDelegate *delegate = (FitnessPlanAppDelegate *) [[UIApplication sharedApplication] delegate];
        NSArray *metrics = [delegate allMetricsForWorkoutName:workout.name]; //[delegate getMetricsForWorkout:workout];
        
        if([metrics count])
            metricsLabel.text = NSLocalizedString(@"MetricsLabel", nil);
        else
        {
            metricsLabel.text = NSLocalizedString(@"NoMetricsLabel", nil);
            [metricsEditButton setTitle:NSLocalizedString(@"Add", nil) forState:UIControlStateNormal];
        }
        
        UIFont *metricsFont = [UIFont systemFontOfSize:14];
        
        GCMathParser *parser = [GCMathParser parser];
        
        for(Metric *m in metrics)
        {
            UILabel *ml = [[UILabel alloc] initWithFrame:CGRectMake(30, pos.y, 250, 20)];
            ml.backgroundColor = [UIColor clearColor];
            ml.font = metricsFont;
            [innerView addSubview:ml];
            [ml release];
            
            [workout setupExpressionParameters:parser];
            
            NSString *s;
            
            @try
            {
                double res = [parser evaluate:[m.text lowercaseString]];
                if(m.type == METRIC_TYPE_VALUE)
                    s = [NSString stringWithFormat:@"%@ = %0.3f", m.text, res];
                else
                    s = [NSString stringWithFormat:@"%@ = %@", m.text, [FitnessPlanAppDelegate stringFromTimestamp:res]];
            }
            @catch (NSException *exception)
            {
                s = [NSString stringWithFormat:@"%@ = %@", m.text, NSLocalizedString(@"ParseError", nil)];
            }
            
            ml.text = s;
            
            pos.y += ml.frame.size.height + 2;
        }
        
    }
    else
    {
        UIView *proView = [[UIView alloc] initWithFrame:CGRectMake(20, pos.y, 280, 40)];
        [proView.layer setCornerRadius:5];
        [proView.layer setBorderColor:[[UIColor colorWithWhite:0.6 alpha:1] CGColor]];
        [proView.layer setBorderWidth:1];
        [self.view addSubview:proView];
        [proView release];
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 40)];
        l.textAlignment = UITextAlignmentCenter;
        l.text = @"Buy PRO version!";
        [proView addSubview:l];
        [l release];
        
        pos.y += 40;
    }
    
    if([workout hasNotes])
    {
        if(settings.isPro)
        {
            pos.y += 15;
            
            UIImageView *hr2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, pos.y, 260, 3)];
            hr2.image = [UIImage imageNamed:@"hr.png"];
            [innerView addSubview:hr2];
            [hr2 release];
            
            pos.y += 3;
        }
        
        pos.y += 15;
        
        UIFont *notesFont = [UIFont systemFontOfSize:14];
        CGSize maxSize = CGSizeMake(280, 800);
        CGSize notesSize = [workout.notes sizeWithFont:notesFont constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
        
        notesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, notesSize.width, notesSize.height)];
        notesLabel.backgroundColor = [UIColor clearColor];
        notesLabel.font = notesFont;
        notesLabel.lineBreakMode = UILineBreakModeWordWrap;
        notesLabel.numberOfLines = 0;
        notesLabel.text = workout.notes;
        [innerView addSubview:notesLabel];
        [notesLabel release];
        
        pos.y += notesSize.height;
    }
    
    innerFrame.size.height = pos.y + 15;
    innerView.frame = innerFrame;
    
    ((UIScrollView *)self.view).contentSize = CGSizeMake(innerFrame.size.width, innerFrame.size.height + 20);
}


- (void)createView
{
    if(innerView)
    {
        [innerView removeFromSuperview];
        [innerView release];
    }
    
    CGRect innerFrame = CGRectMake(10, 10, 300, 440);
    
	innerView = [[UIView alloc] initWithFrame:innerFrame];
	//innerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	innerView.backgroundColor = [UIColor whiteColor];
	[innerView.layer setCornerRadius:10];
	[innerView.layer setBorderColor:[[UIColor colorWithWhite:0.6 alpha:1] CGColor]];
	[innerView.layer setBorderWidth:1];
	
	[self.view addSubview:innerView];
	
	workoutNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 210, 24)];
	workoutNameLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];//[UIFont boldSystemFontOfSize:20];
	[innerView addSubview:workoutNameLabel];
	[workoutNameLabel release];
	workoutNameLabel.text = workout.name;
		
	dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 39, 170, 15)];
	dateLabel.font = settings.smallDetailsFont;
	[innerView addSubview:dateLabel];
	[dateLabel release];
	//dateLabel.text = @"on Dec, 27 2010 at 23:23 pm";
	
	CGPoint pos = CGPointMake(0, 58);
	
	if([workout hasRepeat])
	{
		repeatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 58, 280, 15)];
		repeatedLabel.font = [UIFont systemFontOfSize:14];
		[innerView addSubview:repeatedLabel];
		[repeatedLabel release];
		//repeatedLabel.text = @"repeating every 2 weeks till Jan, 12 2020";
		pos.y += 14;
	}
	
	pos.y += 8;
	
	a1nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, 140, 21)];
	a1nameLabel.font = settings.labelsFont;
	a1nameLabel.adjustsFontSizeToFitWidth = YES;
	a1nameLabel.backgroundColor = [UIColor clearColor];
	a1nameLabel.textAlignment = UITextAlignmentCenter;
	[innerView addSubview:a1nameLabel];
	[a1nameLabel release];
	
    time1Label = [[UILabel alloc] initWithFrame:CGRectMake(150, pos.y, 140, 21)]; // 140
	time1Label.font = settings.labelsFont;
	time1Label.backgroundColor = [UIColor clearColor];
	time1Label.textAlignment = UITextAlignmentCenter;
	[innerView addSubview:time1Label];
	[time1Label release];
	time1Label.text = NSLocalizedString(@"Time1", nil);

	pos.y += 24;
	
	a1valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, 140, 21)];
	a1valueLabel.font = settings.digitsFont;
	a1valueLabel.backgroundColor = [UIColor clearColor];
	a1valueLabel.textAlignment = UITextAlignmentCenter;
	a1valueLabel.textColor = EDITABLE_TEXT_COLOR;
	[innerView addSubview:a1valueLabel];
	[a1valueLabel release];
	//a1valueLabel.text = @"98765";	
	
	time1valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, pos.y, 140, 21)];
	time1valueLabel.font = settings.digitsFont;
	time1valueLabel.backgroundColor = [UIColor clearColor];
	time1valueLabel.textAlignment = UITextAlignmentCenter;
	time1valueLabel.textColor = EDITABLE_TEXT_COLOR;
	[innerView addSubview:time1valueLabel];
	[time1valueLabel release];
	//time1valueLabel.text = @"00:00:00";

    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////
    //// values
    ////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"OnDate", nil), [dateFormatter stringFromDate:[workout.wdate date]]];
	
	if([workout hasRepeat])
	{
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		repeatedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"RepeatingTill", nil),
							  [settings.repList objectAtIndex:workout.rstep],
							  [dateFormatter stringFromDate:[workout.rtill date]]];
	}

    
    double whole, mod;
    
    a1nameLabel.text = workout.amount_name_1;
	if(workout.amount_1)
	{
		mod = modf(workout.amount_1, &whole);
		if(mod)
			a1valueLabel.text = [NSString stringWithFormat:@"%.2f", workout.amount_1];
		else
			a1valueLabel.text = [NSString stringWithFormat:@"%.0f", workout.amount_1];
	}
	else
		a1valueLabel.text = @"--";
    
    if(workout.time_1)
        time1valueLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",
                                workout.time_1 / 3600,
                                (workout.time_1 % 3600) / 60,
                                workout.time_1 % 60];
	else
		time1valueLabel.text = @"--";

	pos.y += 26;
    pos.y += 15;
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////
    //// PRO advertisment
    ////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
	
    ZIStoreButton *b = [[ZIStoreButton alloc] initWithFrame:CGRectMake(20, pos.y, 280, 40)];
    [b setTitle:NSLocalizedString(@"ProFeatures", nil) forState:UIControlStateNormal];
    [b setTitleFont:[UIFont boldSystemFontOfSize:18]];
    [b addTarget:self action:@selector(buyPro) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:b];
    [b release];

    pos.y += 40;
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////
    //// Notes
    ////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    if([workout hasNotes])
    {        
        pos.y += 5;
        
        UIFont *notesFont = [UIFont systemFontOfSize:14];
        CGSize maxSize = CGSizeMake(280, 800);
        CGSize notesSize = [workout.notes sizeWithFont:notesFont constrainedToSize:maxSize lineBreakMode:UILineBreakModeWordWrap];
        
        notesLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, pos.y, notesSize.width, notesSize.height)];
        notesLabel.backgroundColor = [UIColor clearColor];
        notesLabel.font = notesFont;
        notesLabel.lineBreakMode = UILineBreakModeWordWrap;
        notesLabel.numberOfLines = 0;
        notesLabel.text = workout.notes;
        [innerView addSubview:notesLabel];
        [notesLabel release];
        
        pos.y += notesSize.height;
    }
    
    innerFrame.size.height = pos.y + 15;
    innerView.frame = innerFrame;
    
    ((UIScrollView *)self.view).contentSize = CGSizeMake(innerFrame.size.width, innerFrame.size.height + 20);
}


- (void)setWorkout:(Workout *)aWorkout
{
	workout = aWorkout;
    
    if(settings.isPro)
    {
        [self createViewPro];
        [self updateViewPro];
    }
    else
        [self createView];
}


- (void)goEdit
{
	if(editNavigationController == nil)
	{
		editWorkoutController = [[EditWorkoutViewController alloc] initWithNibName:@"EditWorkoutView" bundle:nil];
		editNavigationController = [[UINavigationController alloc] initWithRootViewController:editWorkoutController];
	}
	[editWorkoutController setEditedWorkout:workout];
	[[self navigationController] presentModalViewController:editNavigationController animated:YES];
}


- (void)editMetrics
{
    if(!metricsVC)
    {
        metricsVC = [[MetricsListVC alloc] initWithNibName:@"MetricsListView" bundle:nil];
    }
    metricsVC.editedWorkout = workout;
    [[self navigationController] pushViewController:metricsVC animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc
{
    [metricsVC release];
	[dateFormatter release];
	[workout release];
	[editWorkoutController release];
	[editNavigationController release];
    [super dealloc];
}

@end
