//
//  RepeatStepSelectVC.m
//  FitnessPlan
//
//  Created by Evgeny Kondratiev on 23.01.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RepeatStepSelectVC.h"
#import "Settings.h"


@implementation RepeatStepSelectVC

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
	self.navigationItem.title = NSLocalizedString(@"Repeat", nil);
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

- (void) setValue:(int)step
{
	selected = step;
	
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
	// every none, 1,2,3,4,5,6,7,14,30
	return 10;
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"EveryDay"];
	if(cell == nil)
		cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"EveryDay"];
	
    if(indexPath.row == 0)
        cell.textLabel.text = [settings.repList objectAtIndex:indexPath.row];   // "Never" string
    else
        cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"EveryList", nil), [settings.repList objectAtIndex:indexPath.row]];
	
	if(indexPath.row == selected)
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	cell.textLabel.font = settings.labelsFont;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
//	cell.detailTextLabel.font = settings.detailsFont;
//	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	
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

@end
