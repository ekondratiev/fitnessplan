//
//  ColorSelectVC.m
//  FitnessPlan
//
//  Created by Evgeny Kondratiev on 22.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ColorSelectVC.h"

extern UIImage *buttonColors[8];

@implementation ColorSelectVC

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

		delegate = [[UIApplication sharedApplication] delegate];
		
		//colors = [FitnessPlanAppDelegate buttonColors];
				
		//CGRect r = [[UIScreen mainScreen] applicationFrame];		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)
												 style:UITableViewStyleGrouped];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		tableView.bounces = YES;
		tableView.delegate = self;
		tableView.dataSource = self;
		
		[self.view addSubview:tableView];		
	}
	return self;
}

- (void) viewDidLoad
{
	self.navigationItem.prompt = NSLocalizedString(@"EditWorkoutPrompt", nil);;
	self.navigationItem.title = NSLocalizedString(@"Color", nil);
}

- (void) viewWillAppear:(BOOL)animated
{
}

- (void) setTarget:(id)aTarget action:(SEL)anAction
{
	target = aTarget;
	action = anAction;
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void) dealloc
{
	[tableView release];
    [super dealloc];
}

- (void) cancel
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) save
{
	if(target != nil && action != nil)
	{
		[target performSelector:action withObject:(id)(selected + 1)];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) setValue:(int)color
{
	selected = color - 1;
	[tableView reloadData];
}


#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
	return 1;
}

- (NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
	return 7;
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIImageView *l;
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"ColorCell"];
	if(cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"ColorCell"];
		l = [[UIImageView alloc] initWithFrame:CGRectMake(20, 8, 260, 31)];
		l.tag = 1;
		[cell addSubview:l];
		[l release];
	}
	
	l = (UIImageView *) [cell viewWithTag:1];
	l.image = buttonColors[indexPath.row + 1];
	
	if(indexPath.row == selected)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	return cell;
}

- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tv cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selected inSection:0]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell = [tv cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
	selected = indexPath.row;
    
	[tv deselectRowAtIndexPath:indexPath animated:YES];
}

/*- (UITableViewCellAccessoryType) tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.row == selected)
		return UITableViewCellAccessoryCheckmark;
	else
		return UITableViewCellAccessoryNone;
}*/

@end
