//
//  EditMetricVC.m
//  FitnessPlan
//
//  Created by Женя on 23.03.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import "EditMetricVC.h"
#import "Settings.h"
#import "Constants.h"
#import "HelpViewController.h"


@implementation EditMetricVC

@synthesize valueLabel;

- (id) init
{
	if((self = [super init]))
	{
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
												  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
												  target:self 
												  action:@selector(cancel)] 
												 autorelease];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
												   target:self 
												   action:@selector(save)] 
												  autorelease];
		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)
												 style:UITableViewStyleGrouped];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		tableView.bounces = FALSE;
		tableView.delegate = self;
		tableView.dataSource = self;
		//tableView.sectionHeaderHeight = 50;
		[self.view addSubview:tableView];
		
		textField = [[UITextField alloc] initWithFrame:CGRectMake(105, 10, 200, 26)];
		textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		textField.textAlignment = UITextAlignmentRight;
		textField.placeholder = @"(a1+a2)/t1";
		textField.textColor = EDITABLE_TEXT_COLOR;
		//textField.font = settings.digitsFont;
	}
	return self;
}

- (void) viewDidLoad
{
	//self.navigationItem.prompt = NSLocalizedString(@"EditMetricsPrompt", nil);
	self.navigationItem.title = NSLocalizedString(@"EditMetric", nil);
}

- (void) viewWillAppear:(BOOL)animated
{
	[textField becomeFirstResponder];
    [tableView reloadData];
}


- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void) dealloc
{
	[valueLabel dealloc];
    [super dealloc];
}


- (void) setTarget:(id)aTarget action:(SEL)anAction
{
	target = aTarget;
	action = anAction;
}


- (void) setEditedMetric:(Metric *)metric
{
    [metric retain];
    [editedMetric release];
    editedMetric = metric;
    
    if(metric)
        textField.text = metric.text;
    else
        textField.text = nil;
}


- (Metric *)editedMetric
{
    return editedMetric;
}


- (void) cancel
{
	[self.navigationController popViewControllerAnimated:YES];
}


- (void) save
{
	if(target != nil && action != nil)
	{
        editedMetric.text = textField.text;
        [target performSelector:action withObject:editedMetric];
	}
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return 2;
}

- (NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 2;
    else
        return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            cell = [tv dequeueReusableCellWithIdentifier:@"EditMetricsValueCell"];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EditMetricsValueCell"];
                cell.textLabel.text = NSLocalizedString(@"Metric", nil);
                
                [cell addSubview:textField];
            }
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
        }
        else if(indexPath.row == 1)
        {
            cell = [tv dequeueReusableCellWithIdentifier:@"EditMetricsTypeCell"];
            if(cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EditMetricsTypeCell"];
                cell.textLabel.text = NSLocalizedString(@"MetricType", nil);
            }
            cell.detailTextLabel.text = (editedMetric.type == 1) ? NSLocalizedString(@"TypeTime", nil)
                                                                            : NSLocalizedString(@"TypeValue", nil);
        }
    }
    else
    {
        cell = [tv dequeueReusableCellWithIdentifier:@"EditMetricsHelpCell"];
        if(cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EditMetricsHelpCell"];
            cell.textLabel.text = NSLocalizedString(@"MetricsManual", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.font = settings.labelsFont;
    }
	
	return cell;
}


- (NSIndexPath *) tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1 || (indexPath.section == 0 && indexPath.row == 1))
       return indexPath;

	return nil;
}


- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1)
    {
        HelpViewController *helpVC = [[[HelpViewController alloc] init] autorelease];
        [helpVC gotoAnchor:@"#metrics"];
        [self.navigationController pushViewController:helpVC animated:YES];
    }
    else if(indexPath.section == 0 && indexPath.row == 1)
    {
        if(editedMetric.type == 0)
            editedMetric.type = 1;
        else if(editedMetric.type == 1)
            editedMetric.type = 0;
        
        UITableViewCell *cell = [tv cellForRowAtIndexPath:indexPath];
        cell.detailTextLabel.text = (editedMetric.type == 1) ? NSLocalizedString(@"TypeTime", nil) : NSLocalizedString(@"TypeValue", nil);
    }
}

/*- (UITableViewCellAccessoryType) tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
 {
 return UITableViewCellAccessoryNone;
 }*/

@end
