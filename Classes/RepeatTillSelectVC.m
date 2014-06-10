//
//  RepeatTillSelectVC.m
//  FitnessPlan
//
//  Created by Evgeny Kondratiev on 23.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RepeatTillSelectVC.h"
#import "Constants.h"
#import "FitnessPlanAppDelegate.h"
#import "Settings.h"


@implementation RepeatTillSelectVC

- (id) init
{
	if(self = [super init])
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
		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)
												 style:UITableViewStyleGrouped];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		tableView.bounces = FALSE;
		tableView.delegate = self;
		tableView.dataSource = self;
		tableView.sectionFooterHeight = 0;
		[self.view addSubview:tableView];
        [tableView release];
		
		dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		
		datePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
		datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		datePicker.datePickerMode = UIDatePickerModeDate;
		
		// note we are using CGRectZero for the dimensions of our picker view,
		// this is because picker views have a built in optimum size,
		// you just need to set the correct origin in your view.
		//
		// position the picker at the bottom
		CGSize pickerSize = [datePicker sizeThatFits:CGSizeZero];
		CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
		datePicker.frame = CGRectMake(0.0, screenRect.size.height - 40 - 34.0 - pickerSize.height, pickerSize.width, pickerSize.height);
		[datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
		
		[self.view addSubview:datePicker];
		[datePicker release];		
	}
	return self;
}

- (void) viewDidLoad
{
	self.navigationItem.prompt = NSLocalizedString(@"EditWorkoutPrompt", nil);
	self.navigationItem.title = NSLocalizedString(@"EndRepeat", nil);
}

- (void) viewWillAppear:(BOOL)animated
{
	[datePicker setDate:[date date] animated:NO];
	[self dateChanged:nil];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void) dealloc
{
    [dateFormatter release];
    [super dealloc];
}

- (void) setTarget:(id)aTarget action:(SEL)anAction
{
	target = aTarget;
	action = anAction;
}

- (void) cancel
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) save
{
	if(target != nil && action != nil)
	{
		[target performSelector:action withObject:datePicker.date];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) dateChanged:(id)sender
{
	[tableView reloadData];
}

- (void) setValue:(THCalendarInfo *)newDate min:(THCalendarInfo *)minDate
{
	date = newDate;
	[datePicker setMinimumDate:[minDate date]];
}

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    return 1; // date
}

- (NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	if(indexPath.section == 0)
	{
		cell = [tv dequeueReusableCellWithIdentifier:@"EndRepeat"];
		if(cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EndRepeat"];
			cell.textLabel.text = NSLocalizedString(@"EndRepeat", nil);
		}
		cell.detailTextLabel.text = [dateFormatter stringFromDate:datePicker.date];
	}
	
	cell.textLabel.font = settings.labelsFont;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.detailTextLabel.font = settings.detailsFont;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	
	return cell;
}

- (CGFloat) tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}


- (NSString *) tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

/*- (UITableViewCellAccessoryType) tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryNone;
}*/

@end
