//
//  FeelingSelectVC.m
//  FitnessPlan
//
//  Created by Женя on 14.03.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import "FeelingSelectVC.h"
#import "FitnessPlanAppDelegate.h"
#import "Settings.h"


@implementation FeelingSelectVC

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
		
		//CGRect r = [[UIScreen mainScreen] applicationFrame];		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)
												 style:UITableViewStyleGrouped];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		tableView.bounces = YES;
		tableView.delegate = self;
		tableView.dataSource = self;
		//tableView.sectionHeaderHeight = 100;
		[self.view addSubview:tableView];		
	}
	return self;
}

- (void) viewDidLoad
{
	self.navigationItem.prompt = NSLocalizedString(@"EditWorkoutPrompt", nil);;
	self.navigationItem.title = NSLocalizedString(@"Feeling", nil);
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

- (void) setValue:(int)index
{
	selected = index;
	
	[tableView reloadData];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:selected inSection:0];
	[tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
	// one section for all input parameters
    return 1;
}

- (NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
	return [settings.emoList count];
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIImageView *iv;
	UILabel *l;
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"EveryFeeling"];
	if(cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"EveryFeeling"];
		
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
	l = (UILabel *) [cell viewWithTag:2];
    
	iv.image = [settings.emoImages objectAtIndex:indexPath.row];
	l.text = [settings.emoList objectAtIndex:indexPath.row];
	
	if(indexPath.row == selected)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	l.font = settings.labelsFont;
	l.adjustsFontSizeToFitWidth = YES;
	//	cell.detailTextLabel.font = settings.detailsFont;
	//	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	
	return cell;
}

- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	selected = indexPath.row;
	[tv reloadData];
	[tv deselectRowAtIndexPath:indexPath animated:YES];
}

@end
