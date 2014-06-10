//
//  AmountEditVC.m
//  FitnessPlan2
//
//  Copyright 2010 Evgeny Kondratiev. All rights reserved.
//

#import "ExpendedTimeEditVC.h"
#import "CircularPickerView.h"
#import "FitnessPlanAppDelegate.h"
//#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "Settings.h"


// TODO keyboard and DatePicker animation


@implementation ExpendedTimeEditVC

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
		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 244)
												 style:UITableViewStyleGrouped];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		tableView.bounces = FALSE;
		tableView.delegate = self;
		tableView.dataSource = self;
		[self.view addSubview:tableView];
				
		timePicker = [[CircularPickerView alloc] initWithFrame:CGRectZero];
		timePicker.showsSelectionIndicator = YES;
		[timePicker setDelegate:self];
		[timePicker setDataSource:self];
		//timePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		//[timePicker setTarget:self action:@selector(timeChanged:)];
		//datePickerView.frame = CGRectMake(0, r.size.height - 216, 320, 216);
		
		times[0] = [[NSDateComponents alloc] init];
		times[1] = [[NSDateComponents alloc] init];
        times[2] = [[NSDateComponents alloc] init];
		
		// note we are using CGRectZero for the dimensions of our picker view,
		// this is because picker views have a built in optimum size,
		// you just need to set the correct origin in your view.
		//
		// position the picker at the bottom
		CGSize pickerSize = [timePicker sizeThatFits:CGSizeZero];
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		timePicker.frame = CGRectMake(0.0, screenRect.size.height - 40 - 34.0 - pickerSize.height,
									  pickerSize.width, pickerSize.height);
		[self.view addSubview:timePicker];
		[timePicker release];
	}
	return self;
}

- (void) viewDidLoad
{
	self.navigationItem.prompt = NSLocalizedString(@"EditWorkoutPrompt", nil);
	self.navigationItem.title = NSLocalizedString(@"Time", nil);
}

- (void) viewWillAppear:(BOOL)animated
{
    [tableView reloadData];

    if(settings.isPro)
        [tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:0];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void) dealloc
{
    [times[2] release];
	[times[1] release];
	[times[0] release];
	[tableView release];
	[timePicker release];
    [super dealloc];
}


- (void) setTarget:(id)aTarget action:(SEL)anAction
{
	target = aTarget;
	action = anAction;
}

- (void) setValue:(Workout *)workout
{
	editedWorkout = workout;
	
	long time_1 = workout.time_1;
	long time_2 = workout.time_2;
    long time_3 = workout.time_3;
	
	int hours = time_1 / 3600;
	int mins = (time_1 % 3600) / 60;
	int secs = time_1 % 60;
	
	[times[0] setHour:hours];
	[times[0] setMinute:mins];
	[times[0] setSecond:secs];
	
	[timePicker selectRow:hours inComponent:0 animated:NO];
	[timePicker selectRow:mins inComponent:1 animated:NO];
	[timePicker selectRow:secs inComponent:2 animated:NO];
	
	hours = time_2 / 3600;
	mins = (time_2 % 3600) / 60;
	secs = time_2 % 60;
	
	[times[1] setHour:hours];
	[times[1] setMinute:mins];
	[times[1] setSecond:secs];
    
    hours = time_3 / 3600;
	mins = (time_3 % 3600) / 60;
	secs = time_3 % 60;
	
	[times[2] setHour:hours];
	[times[2] setMinute:mins];
	[times[2] setSecond:secs];
}

- (void) save
{
	if(target != nil && action != nil)
	{
		editedWorkout.time_1  = [times[0] hour] * 3600 + [times[0] minute] * 60 + [times[0] second];
		editedWorkout.time_2 = [times[1] hour] * 3600 + [times[1] minute] * 60 + [times[1] second];
        editedWorkout.time_3 = [times[2] hour] * 3600 + [times[2] minute] * 60 + [times[2] second];
		
		[target performSelector:action withObject:editedWorkout];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) cancel
{
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark PickerView delegate methods

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSIndexPath *indexPath = (settings.isPro) ? [tableView indexPathForSelectedRow] : [NSIndexPath indexPathForRow:0 inSection:0];
	if(indexPath == nil) return;
	
	int hours = [pickerView selectedRowInComponent:0];
	int mins = [pickerView selectedRowInComponent:1];
	int secs = [pickerView selectedRowInComponent:2];
	
	[times[indexPath.row] setHour:hours];
	[times[indexPath.row] setMinute:mins];
	[times[indexPath.row] setSecond:secs];
	
	[tableView reloadData];
    
    if(settings.isPro)
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:NO];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [[NSNumber numberWithInt:row] stringValue];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return 60;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	int n = 0;
	switch (component)
	{
		case 0:
			n = 24;
			break;
		case 1:
		case 2:
			n = 60;
			break;
	}
	return n;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 3;
}


#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
	return (settings.isPro) ? 3 : 1;
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellName = [NSString stringWithFormat:@"Time%d", indexPath.row+1];
    
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:cellName];
	
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
        cell.textLabel.text = NSLocalizedString(cellName, nil);
    }
	
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",
										[times[indexPath.row] hour],
										[times[indexPath.row] minute],
										[times[indexPath.row] second]];
	
	cell.textLabel.font = settings.labelsFont;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.detailTextLabel.font = settings.digitsFont;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	
	return cell;
}

/*
 - (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 }
 */

- (NSString *) tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section
{
    return nil;
}


/*- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return indexPath;
 }*/

- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath == nil)
		return;
	
	[timePicker selectRow:[times[indexPath.row] hour] inComponent:0 animated:YES];
	[timePicker selectRow:[times[indexPath.row] minute] inComponent:1 animated:YES];
	[timePicker selectRow:[times[indexPath.row] second] inComponent:2 animated:YES];
    
    if(!settings.isPro)
        [tv deselectRowAtIndexPath:indexPath animated:YES];
}


/*- (UITableViewCellAccessoryType) tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
 {
 return UITableViewCellAccessoryNone;
 }*/

@end
