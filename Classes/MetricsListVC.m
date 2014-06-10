//
//  MetricsListVC.m
//  FitnessPlan
//
//  Created by Женя on 16.03.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import "MetricsListVC.h"
#import "Metric.h"
#import "FitnessPlanAppDelegate.h"
#import "HelpViewController.h"


@implementation MetricsListVC

@synthesize tableView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Metrics", nil);
    tableView.editing = YES;
}


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


- (void)setEditedWorkout:(Workout *)w
{
    editedWorkout = w;
    
    [metrics release];
    FitnessPlanAppDelegate *delegate = (FitnessPlanAppDelegate *) [[UIApplication sharedApplication] delegate];
    //metrics = [delegate getMetricsForWorkout:w];
    metrics = [delegate allMetricsForWorkoutName:w.name];
    if(metrics)
        [metrics retain];
    
    [tableView reloadData];
}


- (Workout *)editedWorkout
{
    return editedWorkout;
}


- (void)addMetric:(Metric *)metric
{
    FitnessPlanAppDelegate *delegate = (FitnessPlanAppDelegate *) [[UIApplication sharedApplication] delegate];
    
//    // if there are foreings metrics -- copy them to editedWorkout
//    for(Metric *m in metrics)
//    {
//        if(m.wid != editedWorkout.wid)
//        {
//            m.wid = editedWorkout.wid;
//            m.wname = editedWorkout.name;
//            [delegate addMetric:m];
//        }
//    }
    
//    metric.wid = editedWorkout.wid;
    metric.wname = editedWorkout.name;

    [delegate addMetric:metric];
    
    if(!metrics)
        metrics = [[NSMutableArray arrayWithCapacity:5] retain];
    [metrics addObject:metric];
    [tableView reloadData];
}


- (void)modMetric:(Metric *)metric
{
    FitnessPlanAppDelegate *delegate = (FitnessPlanAppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate modMetric:metric];
    [tableView reloadData];
}


- (void)delMetric:(Metric *)metric
{
    FitnessPlanAppDelegate *delegate = (FitnessPlanAppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate delMetric:metric];
}


#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return 2; // Help & FAQs, metrics
}

- (NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 1; // Help & FAQs

    return (metrics) ? [metrics count] + 1 : 1;
}


- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section
{
    return nil;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tv editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return UITableViewCellEditingStyleNone;
    else if(indexPath.row == 0)
        return UITableViewCellEditingStyleInsert;
    else
    {
        //Metric *m = [metrics objectAtIndex:indexPath.row - 1];
        //return (m.wid == editedWorkout.wid) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
        return UITableViewCellEditingStyleDelete;
    }
}


- (BOOL)tableView:(UITableView *)tv shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return NO;
    else
        return  YES;
}


- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if(indexPath.section == 0)
    {
        cell = [tv dequeueReusableCellWithIdentifier:@"MetricsListTextCell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MetricsListTextCell"];
        }
        
        cell.textLabel.text = NSLocalizedString(@"MetricsManual", nil);
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if(indexPath.row == 0)
    {
        cell = [tv dequeueReusableCellWithIdentifier:@"MetricsListTextCell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MetricsListTextCell"];
        }
        
        cell.textLabel.text = NSLocalizedString(@"AddMetric", nil);
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell = [tv dequeueReusableCellWithIdentifier:@"MetricsListValueCell"];
        if(!cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"MetricsListValueCell"];
        }
        
        Metric *m = [metrics objectAtIndex:indexPath.row - 1];
        cell.textLabel.text = m.text;
        cell.detailTextLabel.text = (m.type == 1) ? NSLocalizedString(@"TypeTime", nil) : NSLocalizedString(@"TypeValue", nil);
    }
        
    return cell;
}


- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        Metric *m = [metrics objectAtIndex:indexPath.row - 1];
        [self delMetric:m];
        [metrics removeObjectAtIndex:indexPath.row - 1];
        [tv reloadData];
    }
    else if(editingStyle == UITableViewCellEditingStyleInsert)
    {
        if(metricEditVC == nil)
            metricEditVC = [[EditMetricVC alloc] init];
        [metricEditVC setTarget:self action:@selector(addMetric:)];
        metricEditVC.editedMetric = [[[Metric alloc] init] autorelease];
        [[self navigationController] pushViewController:metricEditVC animated:YES];
    }
}


- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        HelpViewController *helpVC = [[[HelpViewController alloc] init] autorelease];
        [helpVC gotoAnchor:@"#metrics"];
        [self.navigationController pushViewController:helpVC animated:YES];
    }
    else if(indexPath.row == 0)
    {
        if(metricEditVC == nil)
            metricEditVC = [[EditMetricVC alloc] init];
        [metricEditVC setTarget:self action:@selector(addMetric:)];
        metricEditVC.editedMetric = [[[Metric alloc] init] autorelease];
        [[self navigationController] pushViewController:metricEditVC animated:YES];
    }
    else
    {
        Metric *m = [metrics objectAtIndex:indexPath.row - 1];
        
        if(metricEditVC == nil)
            metricEditVC = [[EditMetricVC alloc] init];
        [metricEditVC setTarget:self action:@selector(modMetric:)];
        metricEditVC.editedMetric = m;
        [[self navigationController] pushViewController:metricEditVC animated:YES];
    }
    [tv deselectRowAtIndexPath:indexPath animated:YES];
}

/*- (UITableViewCellAccessoryType) tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
 {
 return (indexPath.section == 2 && editedWorkout.wid != -1) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
 }*/


@end
