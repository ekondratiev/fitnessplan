//
//  ParameterEditVC.m
//  FitPlan
//
//  Created by Evgeny Kondratiev on 20.12.08.
//  Copyright 2008 Kondratiev. All rights reserved.
//

#import "NameEditVC.h"
#import "Constants.h"
#import "Settings.h"


static BOOL isToRefresh = NO;
static int lookupFlag = 1;

// XXX
int historyDepth = 1;

@implementation NameEditVC

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
		delegate = [[UIApplication sharedApplication] delegate];
		
		textField = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		textField.delegate = self;
		textField.showsCancelButton = NO;
		textField.showsBookmarkButton = NO;
        textField.translucent = YES;
        textField.barStyle = UIBarStyleBlack;
		textField.placeholder = NSLocalizedString(@"EnterTextPrompt", nil);
		[self.view addSubview:textField];
		
		/*
		 проставить свойство returnKeyType непосредственно UISearchBar если он конформится
		 протоколу UITextInputTraits (можешь это проверить с помошью conformsToProtocol:).
		 
		 ну а если не конформится то вытягивай свойство _searchField у UISearchBar и
		 проставляй для него returnKeyType:
		 
		 [[theSearchBar valueForKey:@"searchField"] setReturnKeyType:UIReturnKeyDone];
		 
		 */
		
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, 320, 204)
												 style:UITableViewStylePlain];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		tableView.bounces = YES;
		tableView.delegate = self;
		tableView.dataSource = self;
		[self.view addSubview:tableView];
		
		//disciplineText = [[UITextField alloc] initWithFrame:CGRectMake(20, 12, 280, 31)];
		//disciplineText.placeholder = NSLocalizedString(@"EnterTextPrompt", nil);
		//disciplineText.textColor = EDITABLE_TEXT_COLOR;
	}
	return self;
}

- (void) viewDidLoad
{
	self.navigationItem.prompt = NSLocalizedString(@"EditWorkoutPrompt", nil);;
	self.navigationItem.title = NSLocalizedString(@"Name", nil);
}

- (void) viewWillAppear:(BOOL)animated
{
	[self reloadNames:nil];
	[textField becomeFirstResponder];
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
	[textField release];
	//[disciplineText release];
	[tableView release];
    [super dealloc];
}

- (void) setText:(NSString *)newText
{
	textField.text = newText;
	//disciplineText.text = newText;
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


- (void) reloadNames:(UISearchBar *)searchBar
{
	THCalendarInfo *now = [THCalendarInfo calendarInfo];
	
	switch (historyDepth)
	{
		case 1: // no limits
			[now setUnixEpoch:0];
			break;
		case 2: // 1 week
			[now adjustDays:-7];
			break;
		case 3: // 2 weeks
			[now adjustDays:-14];
			break;
		case 4: // 3 weeks
			[now adjustDays:-21];
			break;
		case 5: // 1 month
			[now adjustMonths:-1];
			break;
		case 6: // 2 months
			[now adjustMonths:-2];
			break;
		case 7: // 3 months
			[now adjustMonths:-3];
			break;
		case 8: // 6 months
			[now adjustMonths:-6];
			break;
		default:
			[now setUnixEpoch:0];
	}
	
	isToRefresh = NO;
	[items release];
	items = [delegate groupedNames:(searchBar) ? searchBar.text : @"" from:[now unixEpoch]];
	[items retain];
	[tableView reloadData];
}

#pragma mark -
#pragma mark UISearchBarDelegate delegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if(lookupFlag) // lookupFlag = 0 when user select discipline from table and we skip lookup
	{
		if(isToRefresh == NO)
		{
			isToRefresh = YES;
			[self performSelector:@selector(reloadNames:) withObject:searchBar afterDelay:1];
		}
	}
	else
		lookupFlag++;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	if(isToRefresh == NO)
	{
		isToRefresh = YES;
		[self performSelector:@selector(reloadNames:) withObject:searchBar];
	}
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
	return [items count];
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tv dequeueReusableCellWithIdentifier:@"NameCell"];
	if(cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"NameCell"];
	}
	cell.textLabel.text = [items objectAtIndex:indexPath.row];
	
	cell.textLabel.font = settings.labelsFont;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	
	return cell;
}

 - (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40;
}

- (void) tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	lookupFlag = 0;
	textField.text = [items objectAtIndex:indexPath.row];
	[tv deselectRowAtIndexPath:indexPath animated:YES];
}

/*- (UITableViewCellAccessoryType) tableView:(UITableView *)tv accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryNone;
}*/

@end
