//
//  CloudinessEditVC.m
//  FitnessPlan
//
//  Created by Женя on 04.01.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import "CloudinessSelectVC.h"
#import "Settings.h"


@implementation CloudinessSelectVC

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
	self.navigationItem.title = NSLocalizedString(@"Cloudiness", nil);
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
		[target performSelector:action withObject:(id)selected];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) setValue:(long)cloudiness
{
	selected = cloudiness;
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
	return [settings.cloudinessList count];
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIImageView *iv;
	UILabel *l;
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"CloudinessCell"];
	if(cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"CloudinessCell"];
		
		iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, 7, 30, 30)];
		iv.tag = 1;
		[cell addSubview:iv];
		[iv release];
		
		l = [[UILabel alloc] initWithFrame:CGRectMake(60, 8, 200, 31)];
		l.tag = 2;
		[cell addSubview:l];
		[l release];
	}
	
	iv = (UIImageView *) [cell viewWithTag:1];
	iv.image = [settings.cloudinessImages objectAtIndex:indexPath.row];
	
	l = (UILabel *) [cell viewWithTag:2];
	l.text = [settings.cloudinessList objectAtIndex:indexPath.row];
		
	if(indexPath.row == selected)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	l.font = settings.labelsFont;
	l.adjustsFontSizeToFitWidth = YES;
	
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
