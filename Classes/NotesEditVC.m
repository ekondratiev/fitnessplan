//
//  TextFieldEditVC.m
//  FitPlan
//
//  Created by Evgeny Kondratiev on 20.12.08.
//  Copyright 2008 Kondratiev. All rights reserved.
//

#import "FitnessPlanAppDelegate.h"
#import "NotesEditVC.h"
#import "Constants.h"


@implementation NotesEditVC

//@dynamic text;

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
		[self.view addSubview:tableView];
		
		textView = [[UITextView alloc] initWithFrame:CGRectMake(12, 6, 296, 132)];
		textView.bounces = NO;
		textView.font = [UIFont systemFontOfSize:17];
		textView.textColor = EDITABLE_TEXT_COLOR;
		[textView becomeFirstResponder];
	}
	return self;
}

- (void) viewDidLoad
{
	self.navigationItem.prompt = NSLocalizedString(@"EditWorkoutPrompt", nil);
	self.navigationItem.title = NSLocalizedString(@"Notes", nil);
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void) dealloc
{
	//[text release];
	[tableView release];
	[textView release];
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
		[target performSelector:action withObject:textView.text];
	}
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) setText:(NSString *)newText
{
	textView.text = newText;
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
	// number of parameters will be edited together
	return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"TextEditCell"];
	if(cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"TextEditCell"];
		[cell addSubview:textView];
	}
	//textView.text = text;
	return cell;
}

- (CGFloat) tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 128 + 16;
}

- (NSString *) tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section
{
    return nil;
}


- (NSIndexPath *)tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//return (indexPath.section == 6) ? nil : indexPath;
	return nil;
}


- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

/*- (UITableViewCellAccessoryType) tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryNone;
}*/

@end
