    //
//  WeightEditVC.m
//  FitnessPlan2
//
//  Created by Женя on 13.10.10.
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import "WeightEditVC.h"
#import "FitnessPlanAppDelegate.h"
#import "Constants.h"
#import "Settings.h"

@implementation WeightEditVC

@synthesize valueLabel;

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
		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)
												 style:UITableViewStyleGrouped];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		tableView.bounces = FALSE;
		tableView.delegate = self;
		tableView.dataSource = self;
		//tableView.sectionHeaderHeight = 50;
		[self.view addSubview:tableView];
		
		textField = [[UITextField alloc] initWithFrame:CGRectMake(180, 8, 120, 31)];
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		textField.keyboardType = (iosVersion >= __IPHONE_4_1) ? UIKeyboardTypeDecimalPad : UIKeyboardTypeNumbersAndPunctuation;
		textField.textAlignment = UITextAlignmentRight;
		textField.placeholder = @"0.0";
		textField.textColor = EDITABLE_TEXT_COLOR;
		textField.font = settings.digitsFont;
	}
	return self;
}

- (void) viewDidLoad
{
	self.navigationItem.prompt = NSLocalizedString(@"EditWorkoutPrompt", nil);
	self.navigationItem.title = NSLocalizedString(@"Weight", nil);
}

- (void) viewWillAppear:(BOOL)animated
{
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

- (void) setTarget:(id)aTarget action:(SEL)anAction
{
	target = aTarget;
	action = anAction;
}

- (void) setValue:(float)value
{
	textField.text = (value > 0) ? [NSString stringWithFormat:@"%0.2f", value] : nil;
}

- (void) cancel
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) save
{
	if(target != nil && action != nil)
	{
		[target performSelector:action withObject:textField.text];
	}
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
	return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	
	if(indexPath.row == 0)
	{
		cell = [tv dequeueReusableCellWithIdentifier:@"ValueCell"];
		if(cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ValueCell"];
			cell.textLabel.text = NSLocalizedString(@"Weight", nil);
			
			[cell addSubview:textField];
		}
	}
	
	cell.textLabel.font = settings.labelsFont;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
//	cell.detailTextLabel.font = settings.digitsFont;
//	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	
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
