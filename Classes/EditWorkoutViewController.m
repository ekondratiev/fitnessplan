//
//  EditWorkoutViewController.m
//  FitnessPlan2
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import "EditWorkoutViewController.h"
#import "FitnessPlanAppDelegate.h"
#import "Settings.h"
#import "Constants.h"
#import "AmountEditVC.h"
#import "ExpendedTimeEditVC.h"
#import "HRateEditVC.h"
#import "ColorSelectVC.h"
#import "NotesEditVC.h"


extern UIImage *buttonColors[8];

@implementation EditWorkoutViewController

@synthesize tableView;


- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
		self.navigationController.navigationBar.tintColor = settings.app_tint_color;
		
		self.title = NSLocalizedString(@"EditWorkout", nil);
		self.navigationItem.prompt = NSLocalizedString(@"EditWorkoutPrompt", nil);
		
		/*self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
		 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
		 target:self
		 action:@selector(cancel)]
		 autorelease];*/
		
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
												   target:self
												   action:@selector(done)]
												  autorelease];
		
		dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];		
	}
    return self;
}

- (void) viewDidLoad
{	
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationController.navigationBar.tintColor = settings.app_tint_color;
    
	UIImage *backImage = [[UIImage imageNamed:@"red-delete.png"] stretchableImageWithLeftCapWidth:7 topCapHeight:4];
	
	UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, tableView.sectionHeaderHeight)];
	tableView.tableHeaderView = v;
	[v release];
	
	footerView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 55)];
	UIButton *b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[b setBackgroundImage:backImage forState:UIControlStateNormal];
	[b setTitle:NSLocalizedString(@"DeleteWorkout", nil) forState:UIControlStateNormal];
	b.frame = CGRectMake(0, 0, 300, 45);
	b.titleLabel.font = [UIFont boldSystemFontOfSize:20];
	[b setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [b setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
	[b setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.5] forState:UIControlStateNormal];
    [b setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.5] forState:UIControlStateHighlighted];
	b.titleLabel.shadowOffset = CGSizeMake(0, -1);
	
	[b addTarget:self action:@selector(confirmDelete) forControlEvents:UIControlEventTouchUpInside];
	[footerView addSubview:b];
	
	//tableView.tableFooterView = footerView;
	//[footerView release];
	
	tableView.sectionHeaderHeight = 0;
	
	//man5 = [[UIImage imageNamed:@"man5.png"] retain];
	//man4 = [[UIImage imageNamed:@"man4.png"] retain];
	//detailsHeaderImage = [[self createDetailsHeaderImage] retain];
	//notesHeaderImage = [[self createNotesHeaderImage] retain];
}

- (void) viewWillAppear:(BOOL)animated
{
	if(editedWorkout && editedWorkout.wid >= 0)
		tableView.tableFooterView = footerView;
	else
		tableView.tableFooterView = nil;
	
	// Unselect the selected row if any
	NSIndexPath *selection = [self.tableView indexPathForSelectedRow];
	
	if (selection)
		[self.tableView deselectRowAtIndexPath:selection animated:YES];
	
	[self.tableView reloadData];
}

- (void) setEditedWorkout:(Workout *)workout
{
	[workout retain];
	[editedWorkout release];
	editedWorkout = workout;
	
	changed = NO;
	
	CGRect r = CGRectMake(0, 0, 1, 1);
	[tableView scrollRectToVisible:r animated:NO];
}

- (Workout *) editedWorkout
{
	return editedWorkout;
}

- (void) cancel
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void) done
{
	if(changed)
	{
		if(![editedWorkout hasName])
		{
			[self showAlert:@"NameNotSpecified"];
			return;
		}
		
		FitnessPlanAppDelegate *delegate = (FitnessPlanAppDelegate *) [[UIApplication sharedApplication] delegate];
		int rc = [delegate modWorkout:editedWorkout];
		if(rc)
		{
			[self showAlert:@"ModifyWorkoutError"];
			return;
		}
		[delegate updateButtons];
	}
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void) confirmDelete
{
	UIActionSheet *confirm;
	
	if([editedWorkout hasRepeat])
		confirm = [[UIActionSheet alloc] initWithTitle:nil
											  delegate:self
									 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
								destructiveButtonTitle:NSLocalizedString(@"DeleteThis", nil)
									 otherButtonTitles:NSLocalizedString(@"DeleteNext", nil), nil];
	else
		confirm = [[UIActionSheet alloc] initWithTitle:nil
											  delegate:self
									 cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
								destructiveButtonTitle:NSLocalizedString(@"Delete", nil)
									 otherButtonTitles:nil];
	
	[confirm showInView:self.view];
}

- (void) dealloc
{
	//[disciplineVC release];
	//[dateVC release];
	//[amountVC release];
	//[timeVC release];
	//[notesVC release];
	
	[dateFormatter release];
	//[man4 release];
	//[man5 release];
	//[detailsHeaderImage release];
	//[notesHeaderImage release];
	//[notesHeaderImage release];
	[tableView release];
	[editedWorkout release];
	[super dealloc];
}

- (void) showAlert:(NSString *)msg
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attention", nil)
													message:NSLocalizedString(msg, nil)
												   delegate:self
										  cancelButtonTitle:NSLocalizedString(@"OK", nil)
										  otherButtonTitles:nil];
	[alert show];
}

- (void) saveName:(NSString *)newName
{
	changed = YES;
	editedWorkout.name = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	
	FitnessPlanAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	
	Workout *lastWorkout = [delegate getLastWorkoutFor:editedWorkout];
	if(lastWorkout)
	{
		editedWorkout.color = lastWorkout.color;
		
		editedWorkout.amount_name_1 = lastWorkout.amount_name_1;
		editedWorkout.amount_name_2 = lastWorkout.amount_name_2;
		editedWorkout.amount_name_3 = lastWorkout.amount_name_3;
		
		if(settings.copyNotes)
			editedWorkout.notes = lastWorkout.notes;
	}
	
	[tableView reloadData];
}

- (void) saveDate:(NSDate *)newDate
{
	changed = YES;
	
	long step = [editedWorkout.wdate unixEpoch];
	
	if(editedWorkout.wdate == nil)
		editedWorkout.wdate = [THCalendarInfo calendarInfo];
	
	[editedWorkout.wdate setDate:newDate];
	step = [editedWorkout.wdate unixEpoch] - step;
	
	if(editedWorkout.wid == -1) // shift end repeat date when create workout
	{
		if(step > 0 && [editedWorkout hasRepeat])
			[editedWorkout.rtill adjustSeconds:step];
	}
	else if ([editedWorkout hasRepeat])
	{
		editedWorkout.rstep = 0;
		editedWorkout.rtill = nil;
		[self showAlert:@"RepeatLost"];
	}
}

- (void) saveRstep:(int)selected
{
	changed = YES;
	
	editedWorkout.rstep = selected;
	if(editedWorkout.rstep > 0)
	{
		if(editedWorkout.rtill == nil)
		{
			editedWorkout.rtill = [THCalendarInfo calendarInfo];
			[editedWorkout.rtill setDate:[editedWorkout.wdate date]];
			[editedWorkout.rtill moveToNextMonth];
			[editedWorkout.rtill setHour:23 minute:59 second:59];
		}
	}
	else
		editedWorkout.rtill = nil;
	
	[tableView reloadData];
}

- (void) saveRtill:(NSDate *)newDate
{
	changed = YES;
	editedWorkout.rtill = [THCalendarInfo calendarInfo];
	[editedWorkout.rtill setDate:newDate];
	// XXX check time here
}

- (void) saveAmounts:(NSArray *)amounts
{
	changed = YES;
	//float a = ([amounts count] > 0) ? [[amounts objectAtIndex:0] floatValue] : 0;
	//float b = ([amounts count] > 1) ? [[amounts objectAtIndex:1] floatValue] : 0;
	//float c = ([amounts count] > 2) ? [[amounts objectAtIndex:2] floatValue] : 0;
	
	//editedWorkout.amount_a = a;
	//editedWorkout.amount_b = b;
	//editedWorkout.amount_c = c;
	
	/* XXX
	 changed = YES;
	 editedWorkout.amount = [newAmount floatValue];
	 
	 float multiplier = pow(10, 2); // two digits after dot
	 editedWorkout.amount *= multiplier;
	 float xfloor = floor(editedWorkout.amount);
	 float roundUp = 0;
	 if (editedWorkout.amount - xfloor >= (float)0.5) roundUp = 1;
	 editedWorkout.amount = (xfloor + roundUp) / multiplier;
	 
	 [tableView reloadData];
	 */
	[tableView reloadData];
}

- (void) saveTimes:(Workout *)workout
{
	changed = YES;
	//editedWorkout.time_t1 = t1;
	//editedWorkout.time_r = r;
	[tableView reloadData];
}

- (void) saveHrate:(NSString *)h
{
	changed = YES;
	editedWorkout.hrate = [h intValue];
	[tableView reloadData];
}


- (void) saveWeight:(NSString *)w
{
	changed = YES;
	editedWorkout.weight = [[w stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
	[tableView reloadData];
}


- (void) saveFeeling:(int)selected
{
	changed = YES;
	
	editedWorkout.feeling = [Workout indexToFeeling:selected];
	[tableView reloadData];
}


- (void)saveWeatherT:(long)t C:(long)c
{
	changed = YES;
	editedWorkout.weather_t = t;
	editedWorkout.weather_c = c;
	[tableView reloadData];
}


- (void) saveColor:(int)newColor
{
    changed = YES;
    editedWorkout.color = newColor;
    [tableView reloadData];
}

- (void) saveNotes:(NSString *)text
{
    changed = YES;
    editedWorkout.notes = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [tableView reloadData];
}


#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[alertView release];
}


#pragma mark -
#pragma mark <UIActionSheetDelegate> Delete Workout

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	FitnessPlanAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
	int rc = 0;
	
	if(buttonIndex == 0)
	{
		rc = [delegate delWorkout:editedWorkout allNext:NO];
	}
	else if(buttonIndex == 1 && [editedWorkout hasRepeat]) // delete this and all next
	{
		rc = [delegate delWorkout:editedWorkout allNext:YES];
		if(!rc)
		{
			editedWorkout.rtill = editedWorkout.wdate;
			[editedWorkout.rtill adjustDays:-1];
			[delegate modChain:editedWorkout];
		}
	}
	else
		return;
	
	if(rc)
	{
		// it should never happens
		[self showAlert:@"DeleteWorkoutError"];
		return;
	}
	
	[delegate displayMonth:NO];
	[[delegate.rootVC navigationController] popToRootViewControllerAnimated:NO];
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    if(settings.isPro)
        return 5; // name+date+repeat, details (amount, time), hrate+weight+feeling, weather, color+notes
    else
        return 3; // name+date+repeat, details (amount, time), color+notes
}

- (NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
    if(settings.isPro)
    {
        switch(section)
        {
            case 0: return [editedWorkout hasRepeat] ? 4 : 3;	// name, date, repeat
            case 1: return 2;									// amounts, times
            case 2: return 3;									// hrate, weight, feeling
            case 3: return 1;									// weather
            case 4: return 2;									// color, notes
        }
    }
    else
    {
        switch(section)
        {
            case 0: return [editedWorkout hasRepeat] ? 4 : 3;	// name, date, repeat
            case 1: return 2;									// amounts, times
            case 2: return 2;									// color, notes
        }
    }
	
	return 1;
}

//- (UIView *) tableView:(UITableView *)tv viewForHeaderInSection:(NSInteger)section
//{
//	// XXX
//	if(section == 3)
//	 return [[UIImageView alloc] initWithImage:detailsHeaderImage];
//	 else if(section == 4)
//	 return [[UIImageView alloc] initWithImage:notesHeaderImage];
//	return nil;
//}
//
//- (CGFloat) tableView:(UITableView *)tv heightForHeaderInSection:(NSInteger)section
//{
//	switch(section)
//	{
//		case 1:
//			return 42;
//		case 2:
//			return 40;
//	}
//	return 0;
//}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
	
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//// name, date, repeat
	//////////////////////////////////////////////////////////////////////////////////////////////////
	if(indexPath.section == 0) // name, date
	{
		if(indexPath.row == 0) // name
		{
			cell = [tv dequeueReusableCellWithIdentifier:@"Name"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"Name"];
				
				UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 260, 25)];
				l.tag = 1;
				l.font = settings.labelsFont;
				l.lineBreakMode = UILineBreakModeClip;
				[cell addSubview:l];
				[l release];
				
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			UILabel *l = (UILabel *) [cell viewWithTag:1];
			if(editedWorkout && [editedWorkout hasName])
			{
				l.textColor = EDITABLE_TEXT_COLOR;
				l.text = editedWorkout.name;
			}
			else
			{
				l.textColor = [UIColor lightGrayColor];
				l.text = NSLocalizedString(@"Name", nil);
			}
		}
		else if(indexPath.row == 1) // date
		{
			cell = [tv dequeueReusableCellWithIdentifier:@"Date"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Date"];
				cell.textLabel.text = NSLocalizedString(@"Date", nil);
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			
			if(editedWorkout)
			{
				[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
				cell.detailTextLabel.text = [dateFormatter stringFromDate:[editedWorkout.wdate date]];
			}
		}
		else if(indexPath.row == 2) // repeat
		{
			cell = [tv dequeueReusableCellWithIdentifier:@"Repeat"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Repeat"];
				cell.textLabel.text = NSLocalizedString(@"Repeat", nil);
			}
			
			if(editedWorkout && [editedWorkout hasRepeat])
			{
				cell.detailTextLabel.textColor = (editedWorkout.wid == -1) ? EDITABLE_TEXT_COLOR : [UIColor blackColor];
				
				int rstep = editedWorkout.rstep; // to speedup the process
//				NSString *s;
//				if(rstep >= 1 && rstep <= 6)
//					s = NSLocalizedString(([NSString stringWithFormat:@"Every%dd", rstep]), nil);
//				else if(rstep == 7)
//					s = NSLocalizedString(@"EveryWeek", nil);
//				else if(rstep == 8)
//					s = NSLocalizedString(@"Every2Weeks", nil);
//				else if(rstep == 9)
//					s = NSLocalizedString(@"EveryMonth", nil);
				
				cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"EveryList", nil), [settings.repList objectAtIndex:rstep]];
			}
			else
			{
				cell.detailTextLabel.textColor = (editedWorkout.wid == -1) ? [UIColor lightGrayColor] : [UIColor blackColor];
				cell.detailTextLabel.text = NSLocalizedString(@"Never", nil);
			}
			
			cell.accessoryType = (editedWorkout.wid != -1) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
			
		}
		else if(indexPath.row == 3) // end repeat
		{
			cell = [tv dequeueReusableCellWithIdentifier:@"EndRepeat"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EndRepeat"];
				cell.textLabel.text = NSLocalizedString(@"EndRepeat", nil);
			}
			
			cell.accessoryType = (editedWorkout.wid != -1) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
			
			[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
			cell.detailTextLabel.text = [dateFormatter stringFromDate:[editedWorkout.rtill date]];
            cell.detailTextLabel.textColor = (editedWorkout.wid == -1) ? EDITABLE_TEXT_COLOR : [UIColor blackColor];
		}
		cell.detailTextLabel.font = settings.detailsFont;
	}
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//// amounts, times
	//////////////////////////////////////////////////////////////////////////////////////////////////
	else if(indexPath.section == 1) // amount & time
	{
		if(indexPath.row == 0)
		{
			cell = [tv dequeueReusableCellWithIdentifier:@"AmountCell"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AmountCell"];
				cell.textLabel.text = NSLocalizedString(@"Amount", nil);
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
            
			if(editedWorkout && (editedWorkout.amount_1 > 0 || editedWorkout.amount_2 > 0 || editedWorkout.amount_3 > 0))
			{
				// XXX
				NSMutableString *s = [NSMutableString stringWithCapacity:18];
				double whole, mod;
				
				mod = modf(editedWorkout.amount_1, &whole);
				if(mod)
					[s appendFormat:@"%.2f", editedWorkout.amount_1];
				else
					[s appendFormat:@"%.0f", editedWorkout.amount_1];
				
                if(settings.isPro)
                {
                    mod = modf(editedWorkout.amount_2, &whole);
                    if(mod)
                        [s appendFormat:@" / %.2f / ", editedWorkout.amount_2];
                    else
                        [s appendFormat:@" / %.0f / ", editedWorkout.amount_2];
                    
                    mod = modf(editedWorkout.amount_3, &whole);
                    if(mod)
                        [s appendFormat:@"%.2f", editedWorkout.amount_3];
                    else
                        [s appendFormat:@"%.0f", editedWorkout.amount_3];
                    
                }
				cell.detailTextLabel.textColor = EDITABLE_TEXT_COLOR;
				cell.detailTextLabel.text = s;
			}
			else
			{
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                if(settings.isPro)
                    cell.detailTextLabel.text = @"0 / 0 / 0";
                else
                    cell.detailTextLabel.text = @"0";
			}
		}
		else if(indexPath.row == 1)
		{
			cell = [tv dequeueReusableCellWithIdentifier:@"TimeCell"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"TimeCell"];
				cell.textLabel.text = NSLocalizedString(@"Time", nil);
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
            
			if(editedWorkout && (editedWorkout.time_1 > 0 || editedWorkout.time_2 > 0 || editedWorkout.time_3 > 0))
			{
				cell.detailTextLabel.textColor = EDITABLE_TEXT_COLOR;

                if(settings.isPro)
                {
                    NSMutableString *text = [NSMutableString stringWithCapacity:40];
                    
                    if(editedWorkout.time_1 > 0)
                        [text appendFormat:@"%02d:%02d:%02d", editedWorkout.time_1 / 3600, (editedWorkout.time_1 % 3600) / 60, editedWorkout.time_1 % 60];
                    else
                        [text appendString:@"0"];
                    
                    [text appendString:@" / "];
                    
                    if(editedWorkout.time_2 > 0)
                        [text appendFormat:@"%02d:%02d:%02d", editedWorkout.time_2 / 3600, (editedWorkout.time_2 % 3600) / 60, editedWorkout.time_2 % 60];
                    else
                        [text appendString:@"0"];
                    
                    [text appendString:@" / "];
                    
                    if(editedWorkout.time_3 > 0)
                        [text appendFormat:@"%02d:%02d:%02d", editedWorkout.time_3 / 3600, (editedWorkout.time_3 % 3600) / 60, editedWorkout.time_3 % 60];
                    else
                        [text appendString:@"0"];
                    
                    
                    cell.detailTextLabel.text = text;
                    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
                }
                else
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",
                                                 editedWorkout.time_1 / 3600,
                                                 (editedWorkout.time_1 % 3600) / 60,
                                                 editedWorkout.time_1 % 60
                                                 ];
			}
			else
			{
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
                if(settings.isPro)
                    cell.detailTextLabel.text = @"00:00:00 / 00:00:00";
                else
                    cell.detailTextLabel.text = @"00:00:00";
			}
		}
		cell.detailTextLabel.font = settings.digitsFont;
	}
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//// hrate, weight, feeling
	//////////////////////////////////////////////////////////////////////////////////////////////////
	else if(settings.isPro && indexPath.section == 2) // hrate, weight, feeling
	{
		if(indexPath.row == 0) // hrate
		{
			cell = [tv dequeueReusableCellWithIdentifier:@"HrateCell"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"HrateCell"];
				cell.textLabel.text = NSLocalizedString(@"HRate", nil);
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
            
			if(editedWorkout && editedWorkout.hrate > 0)
			{
				cell.detailTextLabel.textColor = EDITABLE_TEXT_COLOR;
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", editedWorkout.hrate];
			}
			else
			{
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = @"0";
			}
			cell.detailTextLabel.font = settings.digitsFont;
		}
		else if(indexPath.row == 1) // weight
		{
			cell = [tv dequeueReusableCellWithIdentifier:@"WeightCell"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"WeightCell"];
				cell.textLabel.text = NSLocalizedString(@"Weight", nil);
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
            
			if(editedWorkout && editedWorkout.weight > 0)
			{
				cell.detailTextLabel.textColor = EDITABLE_TEXT_COLOR;
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%0.2f", editedWorkout.weight];
			}
			else
			{
				cell.detailTextLabel.textColor = [UIColor lightGrayColor];
				cell.detailTextLabel.text = @"0.0";
			}
			cell.detailTextLabel.font = settings.digitsFont;
		}
		else if(indexPath.row == 2) // feeling
		{
			UIImageView *iv;
			UILabel *l;
			
			cell = [tv dequeueReusableCellWithIdentifier:@"FeelingCell"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FeelingCell"];
				cell.textLabel.text = NSLocalizedString(@"Feeling", nil);				
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
			
			if(editedWorkout.feeling == 0)
				l.textColor = [UIColor lightGrayColor];
			else
				l.textColor = EDITABLE_TEXT_COLOR;
			
			iv.image = [settings.emoImages objectAtIndex:[Workout feelingToIndex:editedWorkout.feeling]];
			l.text = [settings.emoList objectAtIndex:[Workout feelingToIndex:editedWorkout.feeling]];
			l.font = settings.detailsFont;
		}
	}
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//// weather
	//////////////////////////////////////////////////////////////////////////////////////////////////
	else if(settings.isPro && indexPath.section == 3) // weather
	{
		if(indexPath.row == 0) // weather
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
			
			if([editedWorkout hasWeather])
			{
				l.textColor = EDITABLE_TEXT_COLOR;
				if(editedWorkout.weather_t != -9999)
					l.text = [NSString stringWithFormat:@"%d\u00B0%@", editedWorkout.weather_t, (settings.temperatureUnit) ? @"C" : @"F"];
				else
					l.text = nil;
				
				iv.image = [settings.cloudinessImages objectAtIndex:editedWorkout.weather_c];
			}
			else
			{
				l.textColor = [UIColor lightGrayColor];
				l.text = NSLocalizedString(@"IsNotSet", nil);
				iv.image = [settings.cloudinessImages objectAtIndex:0];
			}
			l.font = settings.detailsFont;
		}
	}
	///////////////////////////////////////////////////////////////////////////////////////////////////
	//// colors, notes
	//////////////////////////////////////////////////////////////////////////////////////////////////
	else if((settings.isPro && indexPath.section == 4) || (!settings.isPro && indexPath.section == 2)) // notes
	{
		if(indexPath.row == 0) // colors
		{
			cell = [tv dequeueReusableCellWithIdentifier:@"ColorCell"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ColorCell"];
				cell.textLabel.text = NSLocalizedString(@"Color", nil);
				
				UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(90, 10, 190, 29)];
				iv.tag = 1;
				[cell addSubview:iv];
				[iv release];
				
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			UIImageView *iv = (UIImageView *) [cell viewWithTag:1];
			iv.image = buttonColors[editedWorkout.color];
		}
		else if(indexPath.row == 1) // notes
		{
			cell = [tv dequeueReusableCellWithIdentifier:@"NotesCell"];
			if(cell == nil)
			{
				cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NotesCell"];
				UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 260, 22)];
				l.tag = 1;
				l.font = [UIFont systemFontOfSize:17];
				l.numberOfLines = 10;
				l.lineBreakMode = UILineBreakModeWordWrap;
				[cell addSubview:l];
				[l release];
				
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			UILabel *l = (UILabel *) [cell viewWithTag:1];
			if(editedWorkout && [editedWorkout hasNotes])
			{
				l.textColor = EDITABLE_TEXT_COLOR;
				l.text = [editedWorkout notes];
				
				CGSize notesSize = [l.text sizeWithFont:l.font
									  constrainedToSize:CGSizeMake(260, 200) // TODO
										  lineBreakMode:UILineBreakModeWordWrap];
				if(notesSize.height < 22) notesSize.height = 22;
				l.frame = CGRectMake(20, 10, notesSize.width, notesSize.height); // TODO
			}
			else
			{
				l.frame = CGRectMake(20, 10, 260, 22);
				l.textColor = [UIColor lightGrayColor];
				l.text = NSLocalizedString(@"Notes", nil);
			}
		}
		cell.detailTextLabel.font = settings.detailsFont;
	}
	
	cell.textLabel.font = settings.labelsFont;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
	
	return cell;
}

- (CGFloat) tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(indexPath.section == ((settings.isPro) ? 4 : 2)) // notes
	{
		if(indexPath.row == 0)
		{
			return 44;
		}
		else if(indexPath.row == 1)
		{
			CGFloat h = 0;
			if(editedWorkout != nil && [editedWorkout hasNotes])
			{
				CGSize notesSize = [editedWorkout.notes sizeWithFont:[UIFont systemFontOfSize:17]
												   constrainedToSize:CGSizeMake(260, 200)
													   lineBreakMode:UILineBreakModeWordWrap];
				h = notesSize.height + 20;
			}
			return (h < 44.0) ? 44.0 : h;
		}
	}
	return 44;
}

- (NSIndexPath *) tableView:(UITableView *)tv willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"willSelectRow: indexPath=%@ {%d,%d}", indexPath, indexPath.section, indexPath.row);
	return (indexPath.section == 0 && indexPath.row >= 2 && editedWorkout.wid != -1) ? nil : indexPath;
}

- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//NSLog(@"didSelectRow: indexPath=%@ {%d,%d}", indexPath, indexPath.section, indexPath.row);
	if(indexPath == nil)
		return;
	
	if(indexPath.section == 0)
	{
		if(indexPath.row == 0)
		{
			if(nameEditVC == nil)
				nameEditVC = [[NameEditVC alloc] init];
			[nameEditVC setTarget:self action:@selector(saveName:)];
			[nameEditVC setText:editedWorkout.name];
			[[self navigationController] pushViewController:nameEditVC animated:YES];
		}
		else if(indexPath.row == 1)
		{
			if(dateSelectVC == nil)
				dateSelectVC = [[DateSelectVC alloc] init];
			[dateSelectVC setTarget:self action:@selector(saveDate:)];
			[dateSelectVC setValue:editedWorkout.wdate];
			dateSelectVC.repeated = [editedWorkout hasRepeat];
			[[self navigationController] pushViewController:dateSelectVC animated:YES];
		}
		else if(indexPath.row == 2)
		{
			
			if(rstepVC == nil)
				rstepVC = [[RepeatStepSelectVC alloc] init];
			[rstepVC setTarget:self action:@selector(saveRstep:)];
			[rstepVC setValue:editedWorkout.rstep];
			[[self navigationController] pushViewController:rstepVC animated:YES];
		}
		else if(indexPath.row == 3)
		{
			if(rtillVC == nil)
				rtillVC = [[RepeatTillSelectVC alloc] init];
			[rtillVC setTarget:self action:@selector(saveRtill:)];
			[rtillVC setValue:editedWorkout.rtill min:editedWorkout.wdate];
			
			[[self navigationController] pushViewController:rtillVC animated:YES];
		}
	}
	else if(indexPath.section == 1)
	{
		if(indexPath.row == 0)
		{
			if(amountVC == nil)
				amountVC = [[AmountEditVC alloc] init];
			[amountVC setTarget:self action:@selector(saveAmounts:)];
			[amountVC setValue:editedWorkout];
			[[self navigationController] pushViewController:amountVC animated:YES];
		}
		else if(indexPath.row == 1)
		{
			if(timeVC == nil)
				timeVC = [[ExpendedTimeEditVC alloc] init];
			[timeVC setTarget:self action:@selector(saveTimes:)];
			[timeVC setValue:editedWorkout];
			[[self navigationController] pushViewController:timeVC animated:YES];
		}
	}
	else if(settings.isPro && indexPath.section == 2)
	{
		if(indexPath.row == 0) // hrate
		{
			if(hrateVC == nil)
				hrateVC = [[HRateEditVC alloc] init];
			[hrateVC setTarget:self action:@selector(saveHrate:)];
			[hrateVC setValue:editedWorkout.hrate];
			[[self navigationController] pushViewController:hrateVC animated:YES];
		}
		else if(indexPath.row == 1) // weight
		{
			if(weightVC == nil)
				weightVC = [[WeightEditVC alloc] init];
			[weightVC setTarget:self action:@selector(saveWeight:)];
			[weightVC setValue:editedWorkout.weight];
			[[self navigationController] pushViewController:weightVC animated:YES];
		}
		else if(indexPath.row == 2) // feeling
		{
			if(feelingVC == nil)
				feelingVC = [[FeelingSelectVC alloc] init];
			[feelingVC setTarget:self action:@selector(saveFeeling:)];
			[feelingVC setValue:[Workout feelingToIndex:editedWorkout.feeling]];
			[[self navigationController] pushViewController:feelingVC animated:YES];
		}
	}
	else if(settings.isPro && indexPath.section == 3) // weather
	{
		if(weatherVC == nil)
			weatherVC = [[WeatherEditVC alloc] init];
		[weatherVC setTarget:self action:@selector(saveWeatherT:C:)];
		[weatherVC setValueT:editedWorkout.weather_t C:editedWorkout.weather_c];
		[[self navigationController] pushViewController:weatherVC animated:YES];
	}
	else if((settings.isPro && indexPath.section == 4) || (!settings.isPro && indexPath.section == 2))
	{
		if(indexPath.row == 0)
		{
			if(colorsVC == nil)
				colorsVC = [[ColorSelectVC alloc] init];
			
			[colorsVC setTarget:self action:@selector(saveColor:)];
			[colorsVC setValue:editedWorkout.color];
			[[self navigationController] pushViewController:colorsVC animated:YES];
		}
		else if(indexPath.row == 1)
		{
			if(notesVC == nil)
				notesVC = [[NotesEditVC alloc] init];
			[notesVC setTarget:self action:@selector(saveNotes:)];
			[notesVC setText:editedWorkout.notes];
			[[self navigationController] pushViewController:notesVC animated:YES];
		}
	}
}

/*- (UITableViewCellAccessoryType) tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
 {
 return (indexPath.section == 2 && editedWorkout.wid != -1) ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
 }*/

@end
