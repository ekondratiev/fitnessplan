//
//  ChartViewController.m
//  FitnessPlan
//
//  Created by Женя on 26.03.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ChartViewController.h"
#import "FitnessPlanAppDelegate.h"
#import "Settings.h"


#define MAX_BARS    14

extern UIImage *bulletColors[8];

@implementation ChartViewController

@synthesize toolbar, workoutName;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        
        baseUrl = [[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]] retain];
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"bar" ofType:@"html"];
        //    NSData *htmlData = [NSData dataWithContentsOfFile:htmlFile];
        barTemplate = [[NSString alloc] initWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        
        htmlFile = [[NSBundle mainBundle] pathForResource:@"line" ofType:@"html"];
        lineTemplate = [[NSString alloc] initWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        
        //        NSString *template = [[NSString alloc] initWithContentsOfFile:yourTemplateFile];
        //        template = [template stringByReplacingOccuresOfString:@"__feed_url__" withString:yourFeedURL];
        //        [webView loadData:[template dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"text/html" textEncodingName:@"utf8"];
    }
    return self;
}

- (void)viewDidLoad
{
    toolbar.barStyle = UIBarStyleBlackOpaque;
	toolbar.tintColor = settings.app_tint_color;
    
    UIImageView *darkShade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dark_shade.png"]];
    darkShade.frame = CGRectMake(0, 43, 480, 2);
    [self.view addSubview:darkShade];
    [darkShade release];
    
    periodsSeg = [[UISegmentedControl alloc] initWithFrame:CGRectMake(90, 10, 380, 26)];
    periodsSeg.tintColor = settings.app_tint_color;
    periodsSeg.segmentedControlStyle = UISegmentedControlStyleBar;
    
    [periodsSeg insertSegmentWithTitle:NSLocalizedString(@"1w", nil) atIndex:0 animated:NO];
    [periodsSeg insertSegmentWithTitle:NSLocalizedString(@"2w", nil) atIndex:1 animated:NO];
    [periodsSeg insertSegmentWithTitle:NSLocalizedString(@"1m", nil) atIndex:2 animated:NO];
    [periodsSeg insertSegmentWithTitle:NSLocalizedString(@"3m", nil) atIndex:3 animated:NO];
    [periodsSeg insertSegmentWithTitle:NSLocalizedString(@"6m", nil) atIndex:4 animated:NO];
    [periodsSeg insertSegmentWithTitle:NSLocalizedString(@"1y", nil) atIndex:5 animated:NO];
    [periodsSeg insertSegmentWithTitle:NSLocalizedString(@"2y", nil) atIndex:6 animated:NO];
    [periodsSeg insertSegmentWithTitle:NSLocalizedString(@"All", nil) atIndex:7 animated:NO];
    
    [periodsSeg addTarget:self
                   action:@selector(periodChanged:)
         forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *b = [[[UIBarButtonItem alloc] initWithCustomView:periodsSeg] autorelease];
    
    UIBarButtonItem *b1 = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStyleDone target:self action:@selector(close)] autorelease];
    
    [toolbar setItems:[NSArray arrayWithObjects:b1, b, nil]];
    
    //    [self.view addSubview:periodsSeg];
    //    [periodsSeg release];
    
    //        
    //        mImages[0] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 49, 9, 8)];
    //        
    //        mLabels[0] = [[UILabel alloc] initWithFrame:CGRectMake(0, 42, 0, 20)];
    //        mLabels[0].backgroundColor = [UIColor clearColor];
    //        mLabels[0].adjustsFontSizeToFitWidth = YES;
    //        mLabels[0].font = labelsFont;
    //        
    //        mImages[1] = [[UIImageView alloc] initWithFrame:CGRectMake(0, 49, 9, 8)];
    //        
    //        mLabels[1] = [[UILabel alloc] initWithFrame:CGRectMake(0, 42, 0, 20)];
    //        mLabels[1].backgroundColor = [UIColor clearColor];
    //        mLabels[1].adjustsFontSizeToFitWidth = YES;
    //        mLabels[1].font = labelsFont;
    
    // Chart
    
    graphView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 45, 460, 225)];
    graphView.backgroundColor = [UIColor clearColor];
    graphView.opaque = NO;
    graphView.delegate = self;
    [self.view addSubview:graphView];
    for (id subview in graphView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;
    
    // NoData View
    
    nodataView = [[UIView alloc] initWithFrame:CGRectMake(80, 106, 320, 94)];
    nodataView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [nodataView.layer setCornerRadius:10];
    
    UILabel *nodataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 94)];
    nodataLabel.backgroundColor = [UIColor clearColor];
    nodataLabel.textColor = [UIColor whiteColor];
    nodataLabel.font = [UIFont boldSystemFontOfSize:18];
    nodataLabel.textAlignment = UITextAlignmentCenter;
    nodataLabel.text = NSLocalizedString(@"NoData", nil);
    [nodataLabel.layer setShadowOffset:CGSizeMake(0, -1)];
    [nodataLabel.layer setShadowColor:[[UIColor blackColor] CGColor]];
    [nodataLabel.layer setShadowOpacity:0.3];
    [nodataLabel.layer setShadowRadius:1];
    [nodataView addSubview:nodataLabel];
    [nodataLabel release];
}


- (void)updateTitles
{
    //    CGPoint pos = CGPointMake(480 - 20, 44);
    //    
    //    UIFont *font = mLabels[0].font;
    //    
    //    for(int i = 1; i >= 0; i--)
    //    {
    //        if(mLabels[i].superview)
    //        {
    //            [mLabels[i] removeFromSuperview];
    //            [mImages[i] removeFromSuperview];
    //        }
    //        
    //        if(!metrics[i])
    //            continue;
    //        
    //        CGSize sz = [metrics[i].text sizeWithFont:font];
    //        
    //        pos.x -= sz.width;
    //        
    //        CGRect r = mLabels[i].frame;
    //        r.size.width = sz.width;
    //        r.origin.x = pos.x;
    //        mLabels[i].frame = r;
    //        mLabels[i].text = metrics[i].text;
    //        [self.view addSubview:mLabels[i]];
    //        
    //        pos.x -= 12;
    //        
    //        r = mImages[i].frame;
    //        r.origin.x = pos.x;
    //        mImages[i].frame = r;
    //        mImages[i].image = bulletColors[colors[i]];
    //        [self.view addSubview:mImages[i]];
    //        
    //        pos.x -= 10;
    //    }
}


- (void) close
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void)setWorkoutName:(NSString *)wname metric1:(Metric *)m1 metric2:(Metric *)m2
{
    self.workoutName = wname;
    
    metrics[0] = [m1 retain];
    metrics[1] = [m2 retain];
    
    if(!metrics[0])
    {
        metrics[0] = metrics[1];
        metrics[1] = nil;
    }
    
    [self periodChanged:nil];
}


- (void)displayTotal
{
    NSMutableString *total = [NSMutableString stringWithFormat:@"%@: %d", NSLocalizedString(@"Total", nil), count];
    NSMutableString *s1 = [NSMutableString stringWithCapacity:50];
    NSMutableString *s2 = nil;
    
    [s1 appendString:@"("];
    if(metrics[0].type == METRIC_TYPE_VALUE)
    {
        [s1 appendFormat:@"%.2f", sum[0]];
        if(sum[0])
            [s1 appendFormat:@", %.2f - %.2f", min[0], max[0]];
    }
    else
    {
        [s1 appendString:[FitnessPlanAppDelegate stringFromTimestamp:sum[0]]];
        if(sum[0])
        {
            [s1 appendString:@", "];
            [s1 appendString:[FitnessPlanAppDelegate stringFromTimestamp:min[0]]];
            [s1 appendString:@" - "];
            [s1 appendString:[FitnessPlanAppDelegate stringFromTimestamp:max[0]]];
        }
    }
    [s1 appendString:@")"];
    
    if(metrics[1])
    {
        s2 = [NSMutableString stringWithString:@"("];
        if(metrics[1].type == METRIC_TYPE_VALUE)
        {
            [s2 appendFormat:@"%.2f", sum[1]];
            if(sum[1])
                [s2 appendFormat:@", %.2f - %.2f", min[1], max[1]];
        }
        else
        {
            [s2 appendString:[FitnessPlanAppDelegate stringFromTimestamp:sum[1]]];
            if(sum[1])
            {
                [s2 appendString:@", "];
                [s2 appendString:[FitnessPlanAppDelegate stringFromTimestamp:min[1]]];
                [s2 appendString:@" - "];
                [s2 appendString:[FitnessPlanAppDelegate stringFromTimestamp:max[1]]];
            }
        }
        [s2 appendString:@")"];
    }
    
    if(totalLabel)
    {
        [totalLabel removeFromSuperview];
        [im1 removeFromSuperview];
        [l1 removeFromSuperview];
        totalLabel = nil;
        im1 = nil;
        l1 = nil;
        if(im2)
        {
            [im2 removeFromSuperview];
            [l2 removeFromSuperview];
            im2 = nil;
            l2 = nil;
        }
        
    }
    
    CGPoint pos;
    pos.x = 10;
    pos.y = 280;
    
    UIFont *labelsFont = [UIFont boldSystemFontOfSize:12];
    
    CGSize sz = [total sizeWithFont:labelsFont];
    totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(pos.x, pos.y, sz.width, 16)];
    totalLabel.backgroundColor = [UIColor clearColor];
    totalLabel.font = labelsFont;
    totalLabel.text = total;
    totalLabel.shadowColor = [UIColor whiteColor];
    totalLabel.shadowOffset = CGSizeMake(0, 2);
    [self.view addSubview:totalLabel];
    [totalLabel release];
    
    pos.x += sz.width + 8;
    
    im1 = [[UIImageView alloc] initWithImage:bulletColors[1]];
    im1.frame = CGRectMake(pos.x, pos.y + 6, 9, 8);
    [self.view addSubview:im1];
    [im1 release];
    
    pos.x += 9 + 4;
    
    sz = [s1 sizeWithFont:labelsFont];
    l1 = [[UILabel alloc] initWithFrame:CGRectMake(pos.x, pos.y, sz.width, 16)];
    l1.backgroundColor = [UIColor clearColor];
    l1.font = labelsFont;
    l1.text = s1;
    l1.shadowColor = [UIColor whiteColor];
    l1.shadowOffset = CGSizeMake(0, 2);
    [self.view addSubview:l1];
    [l1 release];
    
    pos.x += sz.width + 8;
    
    if(metrics[1])
    {
        im2 = [[UIImageView alloc] initWithImage:bulletColors[5]];
        im2.frame = CGRectMake(pos.x, pos.y + 6, 9, 8);
        [self.view addSubview:im2];
        [im2 release];
        
        pos.x += 9 + 4;
        
        sz = [s2 sizeWithFont:labelsFont];
        l2 = [[UILabel alloc] initWithFrame:CGRectMake(pos.x, pos.y, sz.width, 16)];
        l2.backgroundColor = [UIColor clearColor];
        l2.font = labelsFont;
        l2.text = s2;
        l2.shadowColor = [UIColor whiteColor];
        l2.shadowOffset = CGSizeMake(0, 2);
        [self.view addSubview:l2];
        [l2 release];
    }
}


- (void)periodChanged:(id)sender
{
    [self.view setNeedsDisplay];
    
    THCalendarInfo *today = [THCalendarInfo calendarInfo];
	//[today setHour:23 minute:59 second:59];
	[today adjustDays:1];
	[today setHour:0 minute:0 second:0];
	
	THCalendarInfo *sday = [THCalendarInfo calendarInfo];
	
	int period = periodsSeg.selectedSegmentIndex;
	switch(period)
	{
		case 0: // 1w
			if(settings.fullPeriod)
				[today adjustDays:-[today dayOfWeek]+1];
			[sday setDate:[today date]];
			[sday adjustDays:-7];
			break;
		case 1: // 2w
			if(settings.fullPeriod)
				[today adjustDays:-[today dayOfWeek]+1];
			[sday setDate:[today date]];
			[sday adjustDays:-14];
			break;
		case 2: // 1m
			if(settings.fullPeriod)
				[today moveToFirstDayOfMonth];
			[sday setDate:[today date]];
			[sday adjustMonths:-1];
			break;
		case 3: // 3m
			if(settings.fullPeriod)
				[today moveToFirstDayOfMonth];
			[sday setDate:[today date]];
			[sday adjustMonths:-3];
			break;
		case 4: // 6m
			if(settings.fullPeriod)
				[today moveToFirstDayOfMonth];
			[sday setDate:[today date]];
			[sday adjustMonths:-6];
			break;
		case 5: // 1y
			if(settings.fullPeriod)
			{
				[today moveToFirstDayOfMonth];
				[today adjustMonths:-[today month]+1];
			}
			[sday setDate:[today date]];
			[sday adjustYears:-1];
			break;
		case 6: // 2y
			if(settings.fullPeriod)
			{
				[today moveToFirstDayOfMonth];
				[today adjustMonths:-[today month]+1];
			}
			[sday setDate:[today date]];
			[sday adjustYears:-2];
			break;
        case 7: // All
			[sday setUnixEpoch:0];
			break;
	}
    
	FitnessPlanAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	
	[items release];
	
	if(workoutName)
		items = [[delegate workoutsForPeriod:sday to:today forName:workoutName] retain];
	else
		items = [[delegate allWorkoutsForPeriod:sday to:today] retain];
    
    NSMutableString *workoutsData1 = [NSMutableString stringWithCapacity:1000];
    NSMutableString *workoutsData2 = [NSMutableString stringWithCapacity:1000];
    NSMutableString *labels = [NSMutableString stringWithCapacity:1000];
    NSMutableString *metricsNames = [NSMutableString stringWithCapacity:100];
    
    [metricsNames appendFormat:@"'%@',", [metrics[0].text lowercaseString]];
    if(metrics[1])
        [metricsNames appendFormat:@"'%@'", [metrics[1].text lowercaseString]];
    else
        [metricsNames appendString:@"null"];
    
    GCMathParser *parser = [GCMathParser parser];
    
    count = [items count];
    
    float labelStep = (count > MAX_BARS) ? ((float)MAX_BARS) / count : 1;
    float step = 1;
    
    int addictions[2];
    addictions[0] = addictions[1] = 0;
    
    NSMutableArray *values1 = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray *values2 = [NSMutableArray arrayWithCapacity:count];
    
    max[0] = max[1] = 0;
    min[0] = min[1] = LONG_MAX;
    sum[0] = sum[1] = 0;
    
    // first step -- calculate max, min and sum
    for(int i = 0; i < count; i++)
    {
        Workout *w = [items objectAtIndex:i];
        
        [w setupExpressionParameters:parser];
        
        double y1 = [parser evaluate:[metrics[0].text lowercaseString]];
        if(isnan(y1) || isinf(y1))
            y1 = 0;
        
        [values1 addObject:[NSNumber numberWithDouble:y1]];
        
        if(y1 > max[0])
            max[0] = y1;
        if(y1 < min[0])
            min[0] = y1;
        sum[0] += y1;
        
        if(metrics[1])
        {            
            double y2 = [parser evaluate:[metrics[1].text lowercaseString]];
            if(isnan(y1) || isinf(y1))
                y1 = 0;
            
            [values2 addObject:[NSNumber numberWithDouble:y2]];
            
            if(y2 > max[1])
                max[1] = y2;
            if(y2 < min[1])
                min[1] = y2;
            sum[1] += y2;
        }
    }
    
    [self displayTotal];
    
    double diff, oscil;
    
    diff = max[0] - min[0];
    //NSLog(@"********* diff1 = %f", diff);
    if(diff != 0 && diff < (max[0] / 10))
    {
        oscil = diff * 3;
        if(oscil < 1) oscil = 1;
        oscil++;
        addictions[0] = (int) (max[0] - oscil);
    }
    max[0] = ceil(max[0]);
    
    if(metrics[1])
    {
        diff = max[1] - min[1];
        //NSLog(@"********* diff2 = %f", diff);
        if(diff != 0 && diff < (max[1] / 10))
        {
            oscil = diff * 3;
            if(oscil < 1) oscil = 1;
            oscil++;
            addictions[1] = (int) (max[1] - oscil);
        }
        max[1] = ceil(max[1]);
    }
    
    
    // second step -- build graph data
    for(int i = 0; i < count; i++)
    {
        Workout *w = [items objectAtIndex:i];
        
        step -= labelStep;
        if(step <= 0 || i == count-1)
        {
            [labels appendFormat:@"'%@',", [dateFormatter stringFromDate:[w.wdate date]]];
            step = 1.0;
        }
        
        double y1 = [[values1 objectAtIndex:i] doubleValue] - addictions[0];
        
        if(count <= MAX_BARS)
            [workoutsData1 appendFormat:@"[%f, null],", y1];
        else
            [workoutsData1 appendFormat:@"%f," , y1];
        
        if(metrics[1])
        {
            double y2 = [[values2 objectAtIndex:i] doubleValue] - addictions[1];
            
            if(count <= MAX_BARS)
                [workoutsData2 appendFormat:@"[null, %f],", y2];
            else
                [workoutsData2 appendFormat:@"%f,", y2];
        }
        else
        {
            if(count <= MAX_BARS)
                [workoutsData2 appendString:@"[null, null],"];
            else
                [workoutsData2 appendString:@"null,"];
        }
    }
    
    if([labels length])
        [labels deleteCharactersInRange:NSMakeRange([labels length]-1, 1)];
    
    if([workoutsData1 length])
        [workoutsData1 deleteCharactersInRange:NSMakeRange([workoutsData1 length]-1, 1)];
    
    if([workoutsData2 length])
        [workoutsData2 deleteCharactersInRange:NSMakeRange([workoutsData2 length]-1, 1)];
    
    NSString *html2;
    
    if(count)
    {
        if(nodataView.superview)
            [nodataView removeFromSuperview];
    }
    else
    {
        if(!nodataView.superview)
            [self.view addSubview:nodataView];
    }
    
    double optimizedMax0 = max[0] - addictions[0];
    if(optimizedMax0 < 5)
        optimizedMax0 = 5;
    
    double optimizedMax1 = max[1] - addictions[1];
    if(optimizedMax1 < 5)
        optimizedMax1 = 5;
    
    if(count <= MAX_BARS)
    {
        html2 = [barTemplate stringByReplacingOccurrencesOfString:@"__WORKOUTS_DATA_1__" withString:workoutsData1];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__WORKOUTS_DATA_2__" withString:workoutsData2];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__LABELS__" withString:labels];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__METRICS_NAMES__" withString:metricsNames];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__YMAX_1__" withString:[NSString stringWithFormat:@"%0.0f", optimizedMax0]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__YMAX_2__" withString:[NSString stringWithFormat:@"%0.0f", optimizedMax1 * 1.2]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__ADDICTION_1__" withString:[NSString stringWithFormat:@"%d", addictions[0]]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__ADDICTION_2__" withString:[NSString stringWithFormat:@"%d", addictions[1]]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__IS_TIME_VALUE_1__" withString:[NSString stringWithFormat:@"%d", metrics[0].type]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__IS_TIME_VALUE_2__" withString:[NSString stringWithFormat:@"%d", metrics[1].type]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__IS_METRIC_2__" withString:[NSString stringWithFormat:@"%d", metrics[1]]];
    }
    else // if(count > MAX_BARS)
    {
        html2 = [lineTemplate stringByReplacingOccurrencesOfString:@"__WORKOUTS_DATA_1__" withString:workoutsData1];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__WORKOUTS_DATA_2__" withString:workoutsData2];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__LABELS__" withString:labels];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__METRICS_NAMES__" withString:metricsNames];        
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__YMAX_1__" withString:[NSString stringWithFormat:@"%0.0f", optimizedMax0]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__YMAX_2__" withString:[NSString stringWithFormat:@"%0.0f", optimizedMax1 * 1.2]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__ADDICTION_1__" withString:[NSString stringWithFormat:@"%d", addictions[0]]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__ADDICTION_2__" withString:[NSString stringWithFormat:@"%d", addictions[1]]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__IS_TIME_VALUE_1__" withString:[NSString stringWithFormat:@"%d", metrics[0].type]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__IS_TIME_VALUE_2__" withString:[NSString stringWithFormat:@"%d", metrics[1].type]];
        html2 = [html2 stringByReplacingOccurrencesOfString:@"__IS_METRIC_2__" withString:[NSString stringWithFormat:@"%d", metrics[1]]];
    }
    
    //NSLog(@"===========================================");
    //NSLog(@"%@", html2);
    
    [graphView loadHTMLString:html2 baseURL:baseUrl];
	
    /*
     dia.time1 = sday;
     dia.time2 = today;
     dia.period = period;
     dia.items = items;
     [dia setNeedsDisplay];
     
     totalAct.text = [NSString stringWithFormat:@"%d", [items count]];
     
     if(dia.amountSum > 0)
     {
     if(dia.amountCheck > 0)
     totalAmount.text = [NSString stringWithFormat:@"%.2f (%.2f - %.2f)", dia.amountSum, dia.amountMin, dia.amountMax];
     else
     totalAmount.text = [NSString stringWithFormat:@"%.0f (%.0f - %.0f)", dia.amountSum, dia.amountMin, dia.amountMax];
     }
     else
     totalAmount.text = @"0";
     
     totalTime.text = (dia.timeSum) ? [NSString stringWithFormat:@"%02d:%02d:%02d (%02d:%02d:%02d - %02d:%02d:%02d)",
     dia.timeSum / 3600, (dia.timeSum % 3600) / 60, dia.timeSum % 60,
     dia.timeMin / 3600, (dia.timeMin % 3600) / 60, dia.timeMin % 60,
     dia.timeMax / 3600, (dia.timeMax % 3600) / 60, dia.timeMax % 60] : @"00:00:00";
     */
}


- (void)dealloc
{
    [items release];
    [barTemplate release];
    [lineTemplate release];
    [nodataView release];
    [baseUrl release];
    
    [workoutName release];
    
    [mImages[0] release];
    [mImages[1] release];
    [mLabels[0] release];
    [mLabels[1] release];
    
    [graphView release];
    
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void) viewWillAppear:(BOOL)animated
{
    [self updateTitles];
    
    periodsSeg.selectedSegmentIndex = 0;
}


- (void)viewDidDisappear:(BOOL)animated
{
    if(metrics[0])
        [metrics[0] release];
    if(metrics[1])
        [metrics[1] release];
    
    metrics[0] = nil;
    metrics[1] = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
       interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        return YES;
    
    return NO;
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    //    NSLog(@"webViewDidFinishLoad");
}

@end
