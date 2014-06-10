//
//  AddWorkoutController.m
//  FitnessPlan2
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import "AddWorkoutViewController.h"
#import "FitnessPlanAppDelegate.h"
#import "Settings.h"


@implementation AddWorkoutViewController

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		self.title = NSLocalizedString(@"NewWorkout", nil);
		self.navigationItem.prompt = NSLocalizedString(@"EnterWorkoutPrompt", nil);
		
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
													initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
													target:self
													action:@selector(cancel)]
												 autorelease];
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
													initWithBarButtonSystemItem:UIBarButtonSystemItemSave
													target:self
													action:@selector(done)]
												  autorelease];
	}
    return self;
}

- (void) done
{	
	if(![editedWorkout hasName])
	{
		[self showAlert:@"NameNotSpecified"];
		return;
	}
	
	FitnessPlanAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	
	// XXX
	int rc = [delegate addRepeatedWorkout:editedWorkout];
	
	if(rc)
	{
		if(rc == -2 || ![editedWorkout hasRepeat])
		{
			[self showAlert:@"CreateWorkoutError"];
			return;
		}
		else
			[self showAlert:@"RepeatWorkoutError"];
	}
	
	[delegate displayMonth:NO];
	
	self.editedWorkout = nil;
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

@end
