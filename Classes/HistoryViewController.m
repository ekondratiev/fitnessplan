//
//  HistoryViewController.m
//  FitnessPlan
//
//  Created by Женя on 25.03.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "HistoryViewController.h"
#import "ChartViewController.h"
#import "FitnessPlanAppDelegate.h"
#import "ExportViewController.h"
#import "Settings.h"
#import "ZIStoreButton.h"
#import "BuyProViewController.h"


extern UIImage *bulletColors[8];


@interface HistoryViewController ()

- (void) clearMetricsSelection;

@end



@implementation HistoryViewController

@synthesize workoutsList, metricsList;


- (id)init
{
    self = [super init];
    if(self)
    {
        self.navigationItem.title = NSLocalizedString(@"History", nil);
        UIBarButtonItem *b = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize
                                                                           target:self
                                                                           action:@selector(goExport)];
        self.navigationItem.rightBarButtonItem = b;
        [b release];
        
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
        
        workoutSelected = -1;
        metricsSelected[0] = [[SelectedIndexPath alloc] init];
        metricsSelected[1] = [[SelectedIndexPath alloc] init];
        
        UILabel *titleLabel;
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 280, 30)];
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = NSLocalizedString(@"SelectWorkoutName", nil);
        titleLabel.shadowColor = [UIColor whiteColor];
        titleLabel.shadowOffset = CGSizeMake(0, 2);
        [self.view addSubview:titleLabel];
        [titleLabel release];
        
        if(settings.isPro)
        {
            workoutsTable = [[UITableView alloc] initWithFrame:CGRectMake(20, 40, 280, 130) style:UITableViewStylePlain];
            [workoutsTable.layer setCornerRadius:5];
            [workoutsTable.layer setBorderColor:[[UIColor colorWithWhite:0.6 alpha:1] CGColor]];
            [workoutsTable.layer setBorderWidth:1];
            workoutsTable.delegate = self;
            workoutsTable.dataSource = self;
            [self.view addSubview:workoutsTable];
            [workoutsTable release];
            
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 280, 30)];
            titleLabel.font = [UIFont boldSystemFontOfSize:16];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = NSLocalizedString(@"SelectMetrics", nil);
            titleLabel.shadowColor = [UIColor whiteColor];
            titleLabel.shadowOffset = CGSizeMake(0, 2);
            [self.view addSubview:titleLabel];
            [titleLabel release];
            
            metricsTable = [[UITableView alloc] initWithFrame:CGRectMake(20, 210, 280, 130) style:UITableViewStylePlain];
            [metricsTable.layer setCornerRadius:5];
            [metricsTable.layer setBorderColor:[[UIColor colorWithWhite:0.6 alpha:1] CGColor]];
            [metricsTable.layer setBorderWidth:1];
            metricsTable.delegate = self;
            metricsTable.dataSource = self;
            [self.view addSubview:metricsTable];
            [metricsTable release];
        }
        else
        {
            workoutsTable = [[UITableView alloc] initWithFrame:CGRectMake(20, 40, 280, 230) style:UITableViewStylePlain];
            [workoutsTable.layer setCornerRadius:5];
            [workoutsTable.layer setBorderColor:[[UIColor colorWithWhite:0.6 alpha:1] CGColor]];
            [workoutsTable.layer setBorderWidth:1];
            workoutsTable.delegate = self;
            workoutsTable.dataSource = self;
            [self.view addSubview:workoutsTable];
            [workoutsTable release];
            
            ZIStoreButton *b = [[ZIStoreButton alloc] initWithFrame:CGRectMake(50, 280, 220, 30)];
            [b setTitle:NSLocalizedString(@"ProFeatures", nil) forState:UIControlStateNormal];
            [b setTitleFont:[UIFont boldSystemFontOfSize:14]];
            [b addTarget:self action:@selector(buyPro) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:b];
            [b release];            
        }

        proceedButton = [[ZIStoreButton alloc] initWithFrame:CGRectMake(40, 360, 240, 40)];
        [proceedButton setTitle:NSLocalizedString(@"ProceedChart", nil) forState:UIControlStateNormal];
        [proceedButton setTitleFont:[UIFont boldSystemFontOfSize:18]];
        [proceedButton addTarget:self action:@selector(viewChart) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:proceedButton];
        
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
//    [super viewWillAppear:animated];
    if([UIDevice currentDevice].orientation != UIDeviceOrientationPortrait)
		[[UIDevice currentDevice] performSelector:@selector(setOrientation:) withObject:(void *)UIDeviceOrientationPortrait];
    
    [self clearMetricsSelection];
    
//    NSIndexPath *selectedRow = [workoutsTable indexPathForSelectedRow];
//    if(selectedRow)
//    {
//        workoutSelected = -1;
//        [self tableView:workoutsTable didSelectRowAtIndexPath:selectedRow];
//    }
}


- (void)dealloc
{
    [metricsSelected[0] release];
    [metricsSelected[1] release];
    [workoutsList release];
    [metricsList release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)buyPro
{
    BuyProViewController *buyProVC = [[[BuyProViewController alloc] init] autorelease];
    [self.navigationController pushViewController:buyProVC animated:YES];
}


- (void)updateWorkouts
{
    FitnessPlanAppDelegate *delegate = (FitnessPlanAppDelegate *) [[UIApplication sharedApplication] delegate];
    self.workoutsList = [delegate groupedNames:@"" from:0];
    [workoutsTable reloadData];
    workoutSelected = -1;
}


- (void)clearMetricsSelection
{
    for(int i = 0; i < MAX_METRICS_SELECTED; i++)
    {
        metricsSelected[i].section = -1;
    }

    metricsSelectStep = 0;
    
    if(settings.isPro)
        [metricsTable reloadData];
}


- (void)viewChart
{
    if(workoutSelected == -1)
        return;
    
    Metric *m1 = nil, *m2 = nil;
    
    if(metricsSelected[0].section == -1 && metricsSelected[1].section == -1)
    {
        if(settings.isPro)
        {
            // XXX display warning message!
            return;
        }
        else
        {
            m1 = [[[Metric alloc] init] autorelease];
            m1.text = @"Amount";
            m1.type = METRIC_TYPE_VALUE;
            
            m2 = [[[Metric alloc] init] autorelease];
            m2.text = @"Time";
            m2.type = METRIC_TYPE_TIME;
        }
    }
    else
    {
        if(metricsSelected[0].section != -1)
        {
            if(metricsSelected[0].section == 0)
                m1 = [metricsList objectAtIndex:metricsSelected[0].row];
            else
                m1 = [settings.predefinedMetrics objectAtIndex:metricsSelected[0].row];
        }
        
        if(metricsSelected[1].section != -1)
        {
            if(metricsSelected[1].section == 0)
                m2 = [metricsList objectAtIndex:metricsSelected[1].row];
            else
                m2 = [settings.predefinedMetrics objectAtIndex:metricsSelected[1].row];
        }
    }

    if(!chartVC)
        chartVC = [[ChartViewController alloc] initWithNibName:@"ChartView" bundle:nil];
    
    if(workoutSelected < [workoutsList count])
        [chartVC setWorkoutName:[workoutsList objectAtIndex:workoutSelected] metric1:m1 metric2:m2];
    else
        [chartVC setWorkoutName:nil metric1:m1 metric2:m2];
    
    [self presentModalViewController:chartVC animated:YES];
}


- (void)goExport
{
    ExportViewController *exportVC = [[[ExportViewController alloc] init] autorelease];
    [self.navigationController pushViewController:exportVC animated:YES];
}


#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == metricsTable)
        return 2;
    else
        return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == workoutsTable)
    {
        int c = [workoutsList count];
        if(c && settings.showAll)
            c++;
        return c;
    }
    else //(tableView == metricsTable)
    {
        if(workoutSelected == -1)
            return 0;
        else
        {
            if(section == 0)
                return [metricsList count];
            else
                return [settings.predefinedMetrics count];
        }
    }
}


- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(tableView == metricsTable)
    {
        if(section == 0)
            return NSLocalizedString(@"UserMetrics", nil);
        else
            return NSLocalizedString(@"PredefinedMetrics", nil);
    }
    else
        return nil;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MetricCell"];
	if(cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MetricCell"];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	}
    
    if(tableView == workoutsTable)
    {
        if(indexPath.row < [workoutsList count])
            cell.textLabel.text = [workoutsList objectAtIndex:indexPath.row];
        else
            cell.textLabel.text = NSLocalizedString(@"AllRecords", nil);
    }
    else //(tableView == metricsTable)
    {
        Metric *m = (indexPath.section == 0) ? [metricsList objectAtIndex:indexPath.row] : [settings.predefinedMetrics objectAtIndex:indexPath.row];
        cell.textLabel.text = m.text;
        cell.detailTextLabel.text = m.mname;
        cell.imageView.image = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
	
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == workoutsTable)
    {
        if(workoutSelected != indexPath.row)
        {
            workoutSelected = indexPath.row;
            
            if(settings.isPro)
            {
                FitnessPlanAppDelegate *delegate = (FitnessPlanAppDelegate *) [[UIApplication sharedApplication] delegate];
                if(workoutSelected < [workoutsList count])
                    self.metricsList = [delegate allMetricsForWorkoutName:[workoutsList objectAtIndex:workoutSelected]];
                else
                    self.metricsList = [delegate allMetricsForAllWorkouts];
                
                [self clearMetricsSelection];
            }
        }
    }
    else //(tableView == metricsTable)
    {
        UITableViewCell *cell;
        int index = metricsSelectStep % MAX_METRICS_SELECTED;
        
        cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if(cell.accessoryType == UITableViewCellAccessoryNone)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.imageView.image = (!index) ? bulletColors[1] : bulletColors[5];
            
            // clear one of the selected cells
            cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:metricsSelected[index].row inSection:metricsSelected[index].section]];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = nil;
        
            metricsSelected[index].row = indexPath.row;
            metricsSelected[index].section = indexPath.section;
            metricsSelectStep++;
        }
        else //(cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.imageView.image = nil;
            
            for(index = 0; index < MAX_METRICS_SELECTED; index++)
                if(metricsSelected[index].row == indexPath.row && metricsSelected[index].section == indexPath.section)
                {
                    metricsSelected[index].section = -1;
                    metricsSelectStep = index;
                    break;
                }
                
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


@end
