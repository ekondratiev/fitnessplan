//
//  WeatherEditVC.m
//  FitnessPlan2
//
//  Created by Женя on 10.12.10.
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import "WeatherEditVC.h"
#import "FitnessPlanAppDelegate.h"
#import "Constants.h"
#import "Settings.h"


@implementation WeatherEditVC

@synthesize valueLabel;


- (id)init
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
		
		seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
														 [UIImage imageNamed:@"plus.png"],
														 [UIImage imageNamed:@"minus.png"], nil]];
		seg.frame = CGRectMake(170, 9, 80, 28);
		seg.segmentedControlStyle = UISegmentedControlStyleBar;
		seg.tintColor = settings.app_tint_color;
		seg.selectedSegmentIndex = 0;
		
		textField = [[UITextField alloc] initWithFrame:CGRectMake(250, 12, 40, 26)];
		textField.keyboardType = UIKeyboardTypeNumberPad;
		//textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
		textField.textAlignment = UITextAlignmentRight;
		textField.placeholder = @"18";
		textField.textColor = EDITABLE_TEXT_COLOR;
	}
	return self;
}

- (void) viewDidLoad
{
	self.navigationItem.prompt = NSLocalizedString(@"EditWorkoutPrompt", nil);
	self.navigationItem.title = NSLocalizedString(@"Weather", nil);
}

- (void) viewWillAppear:(BOOL)animated
{
	// Unselect the selected row if any
	NSIndexPath *selection = [tableView indexPathForSelectedRow];
	
	if (selection)
		[tableView deselectRowAtIndexPath:selection animated:YES];
	
	
	[textField becomeFirstResponder];
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

/*- (void) addDot
 {
 if ([textFieldA.text rangeOfString:@"." options:NSBackwardsSearch].length == 0) {
 textFieldA.text = [textFieldA.text stringByAppendingString:@"."];
 }
 }*/

- (void)setTarget:(id)aTarget action:(SEL)anAction
{
	target = aTarget;
	action = anAction;
}

- (void)setValueT:(long)t C:(long)c
{
	if(t != -9999)
	{
		if(t < 0)
		{
			textField.text = [NSString stringWithFormat:@"%d", -t];
			seg.selectedSegmentIndex = 1;
		}
		else
		{
			textField.text = [NSString stringWithFormat:@"%d", t];
			seg.selectedSegmentIndex = 0;
		}
	}
	else
		textField.text = nil;
	
	valueC = c;
}

- (void)cancel
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)save
{
	long t = -9999;
	
	NSString *text = textField.text;
	if([text length] > 0)
	{
		t = [text intValue];
		
		if(seg.selectedSegmentIndex == 1)
			t = -t;
	}
	
	if(target != nil && action != nil)
	{
		[target performSelector:action withObject:(id)t withObject:(id)valueC];
	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)saveCloudiness:(long)value
{
	valueC = value;
	[tableView reloadData];
}

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
	if(indexPath.row == 0)
	{
		cell = [tv dequeueReusableCellWithIdentifier:@"TemperatureCell"];
		if(cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TemperatureCell"];
			cell.textLabel.text = [NSString stringWithFormat:@"%@ (\u00B0%@)", NSLocalizedString(@"Temperature", nil), (settings.temperatureUnit) ? @"C" : @"F"];
			
			[cell addSubview:seg];
			[cell addSubview:textField];
		}
	}
	else if(indexPath.row == 1)
	{
		UIImageView *iv;
		UILabel *l;
		
		cell = [tv dequeueReusableCellWithIdentifier:@"WeatherCell"];
		if(cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"WeatherCell"];
			cell.textLabel.text = NSLocalizedString(@"Weather", nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			iv = [[UIImageView alloc] initWithFrame:CGRectMake(250, 7, 30, 30)];
			iv.tag = 1;
			[cell addSubview:iv];
			[iv release];
			
			l = [[UILabel alloc] initWithFrame:CGRectMake(100, 8, 140, 31)];
			l.textAlignment = UITextAlignmentRight;
			l.tag = 2;
			[cell addSubview:l];
			[l release];
		}
		
		iv = (UIImageView *) [cell viewWithTag:1];
		iv.image = [settings.cloudinessImages objectAtIndex:indexPath.row];
		
		l = (UILabel *) [cell viewWithTag:2];
		l.text = [settings.cloudinessList objectAtIndex:indexPath.row];
		
		if(valueC)
		{
			l.textColor = EDITABLE_TEXT_COLOR;
			l.text = [settings.cloudinessList objectAtIndex:valueC];
			iv.image = [settings.cloudinessImages objectAtIndex:valueC];
		}
		else
		{
			l.textColor = [UIColor lightGrayColor];
			l.text = NSLocalizedString(@"IsNotSet", nil);
			iv.image = [settings.cloudinessImages objectAtIndex:0];
		}
		l.font = settings.detailsFont;
	}
	
	return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (indexPath.row == 0) ? nil : indexPath;
}

- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath == nil)
		return;
	
	if(indexPath.section == 0)
	{
		if(indexPath.row == 1)
		{
			if(cloudVC == nil)
				cloudVC = [[CloudinessSelectVC alloc] init];
			[cloudVC setTarget:self action:@selector(saveCloudiness:)];
			[cloudVC setValue:valueC];
			[[self navigationController] pushViewController:cloudVC animated:YES];
		}
	}
}

/*- (UITableViewCellAccessoryType) tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
 {
 return UITableViewCellAccessoryNone;
 }*/

@end
