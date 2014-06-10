//
//  AmountEditVC.m
//  FitnessPlan2
//
//  Copyright 2010 Evgeny Kondratiev. All rights reserved.
//

#import "AmountEditVC.h"
#import "FitnessPlanAppDelegate.h"
#import "Constants.h"
#import "Settings.h"


@implementation AmountEditVC

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
		
		for(int i = 0; i < 3; i++)
		{
			labelFields[i] = [[UITextField alloc] initWithFrame:CGRectMake(20, 8, 160, 31)];
            labelFields[i].contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			labelFields[i].font = settings.labelsFont;//[UIFont boldSystemFontOfSize:labelFields[i].font.pointSize];
			labelFields[i].textColor = [UIColor blackColor];
			
			textFields[i] = [[UITextField alloc] initWithFrame:CGRectMake(180, 8, 120, 31)]; //(180, 16, 120, 26)];
            textFields[i].contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			textFields[i].keyboardType = (iosVersion >= __IPHONE_4_1) ? UIKeyboardTypeDecimalPad : UIKeyboardTypeNumbersAndPunctuation;
			textFields[i].textAlignment = UITextAlignmentRight;
			textFields[i].placeholder = @"0.00";
			textFields[i].textColor = EDITABLE_TEXT_COLOR;
			textFields[i].font = settings.digitsFont;
		}		
	}
	return self;
}

- (void) viewDidLoad
{
	self.navigationItem.prompt = NSLocalizedString(@"EditWorkoutPrompt", nil);
	self.navigationItem.title = NSLocalizedString(@"Amount", nil);
}

- (void) viewWillAppear:(BOOL)animated
{
	[textFields[0] becomeFirstResponder];
}

/*
- (void) viewWillDisappear:(BOOL)animated
{
}
*/

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void) dealloc
{
	for(int i; i < 3; i++)
	{
		[labelFields[i] release];
		[textFields[i] release];
	}
	
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
	
	textFields[0].text = (workout.amount_1 > 0) ? [NSString stringWithFormat:@"%0.2f", workout.amount_1] : nil;
	textFields[1].text = (workout.amount_2 > 0) ? [NSString stringWithFormat:@"%0.2f", workout.amount_2] : nil;
	textFields[2].text = (workout.amount_3 > 0) ? [NSString stringWithFormat:@"%0.2f", workout.amount_3] : nil;
	
	labelFields[0].text = workout.amount_name_1;
	labelFields[1].text = workout.amount_name_2;
	labelFields[2].text = workout.amount_name_3;
}

- (void) cancel
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) save
{
	editedWorkout.amount_1 = [[textFields[0].text stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
	editedWorkout.amount_2 = [[textFields[1].text stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
	editedWorkout.amount_3 = [[textFields[2].text stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
	
	editedWorkout.amount_name_1 = [labelFields[0].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	editedWorkout.amount_name_2 = [labelFields[1].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	editedWorkout.amount_name_3 = [labelFields[2].text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if(target != nil && action != nil)
		[target performSelector:action withObject:editedWorkout];

	[self.navigationController popViewControllerAnimated:YES];
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
	UITableViewCell *cell = nil;
	
	if(indexPath.row == 0)
	{
		cell = [tv dequeueReusableCellWithIdentifier:@"ValueCellA"];
		if(cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ValueCellA"];
			//labelFields[indexPath.row].text = NSLocalizedString(@"Amount1", nil);
			[cell addSubview:labelFields[indexPath.row]];
			
			[cell addSubview:textFields[indexPath.row]];
		}
	}
	else if(indexPath.row == 1)
	{
		cell = [tv dequeueReusableCellWithIdentifier:@"ValueCellB"];
		if(cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ValueCellB"];
			//labelFields[indexPath.row].text = NSLocalizedString(@"Amount2", nil);
			[cell addSubview:labelFields[indexPath.row]];
			
			[cell addSubview:textFields[indexPath.row]];
		}
	}
	else if(indexPath.row == 2)
	{
		cell = [tv dequeueReusableCellWithIdentifier:@"ValueCellC"];
		if(cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ValueCellC"];
			//labelFields[indexPath.row].text = NSLocalizedString(@"Amount3", nil);
			[cell addSubview:labelFields[indexPath.row]];
			
			[cell addSubview:textFields[indexPath.row]];
		}
	}
	
	return cell;
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
