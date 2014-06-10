//
//  AboutViewController.m
//  FitnessPlan2
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//
#import "AboutViewController.h"
#import "Settings.h"
#import "Constants.h"
#import "HelpViewController.h"
#import "BuyProViewController.h"

// XXX rework About page

@implementation AboutViewController

- init
{
	self = [super init];
	if(self)
	{
		self.navigationItem.title = NSLocalizedString(@"AboutTitle", nil);
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
												   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
												   target:self
												   action:@selector(dismiss)]
												  autorelease];
        
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)
												 style:UITableViewStyleGrouped];
		tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		tableView.bounces = YES;
		tableView.delegate = self;
		tableView.dataSource = self;
        tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
		//tableView.sectionHeaderHeight = 100;
		[self.view addSubview:tableView];
		
		helpText = NSLocalizedString(@"ManualText", nil);
	}
	return self;
}

- (void) viewDidLoad
{	
	aboutView = [[AboutView alloc] initWithFrame:CGRectMake(20, 10, 270, 0)];
}

- (void) dismiss
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	self.navigationController.navigationBar.tintColor = settings.app_tint_color;
	//self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    aboutView.appNameLabel.text = (settings.isPro) ? APP_NAME_PRO : APP_NAME;
    [tableView reloadData];
}

- (void) dealloc
{
	[helpText release];
	[tableView release];
	[aboutView release];
	[super dealloc];
}

#pragma mark -
#pragma mark <UITableViewDelegate, UITableViewDataSource> Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tv
{
    if(settings.isPro)
        return 2; // help, about
    else
        return 3; // buy pro, help, about
}

- (NSInteger) tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell;
    int section = indexPath.section;
    
    if(settings.isPro)
        section++;
    
    if(section == 0)
	{
		cell = [tv dequeueReusableCellWithIdentifier:@"BuyProCell"];
		if(cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"BuyProCell"];
            cell.textLabel.text = NSLocalizedString(@"BuyPro", nil);
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else if(section == 1)
	{
		cell = [tv dequeueReusableCellWithIdentifier:@"HelpCell"];
		if(cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"HelpCell"];
            cell.textLabel.text = helpText;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else if(section == 2)
	{
		cell = [tv dequeueReusableCellWithIdentifier:@"AboutCell"];
		if(cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"AboutCell"];
			[cell addSubview:aboutView];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
	}
	
	return cell;
}

- (CGFloat) tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat h = 0;
    int section = indexPath.section;
    
    if(settings.isPro)
        section++;
	
	if(section == 0 || section == 1)
        h = 44;
	else if(section == 2)
	{
		h = aboutView.frame.size.height + 18;
	}
	return h;
}


- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section
{
    if(settings.isPro)
        section++;

    if(section == 0)
	{
		return NSLocalizedString(@"BuyPROVersion", nil);
	}
	else if(section == 1)
	{
		return NSLocalizedString(@"Manual", nil);
	}
	else if(section == 2)
	{
		return NSLocalizedString(@"AboutTitle", nil);
	}
    return nil;
}


- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    if(settings.isPro)
        section++;
    
    if(section == 0)
    {
        BuyProViewController *buyProVC = [[[BuyProViewController alloc] init] autorelease];
        [self.navigationController pushViewController:buyProVC animated:YES];
    }
    else if(section == 1)
    {
        HelpViewController *helpVC = [[[HelpViewController alloc] init] autorelease];
        [self.navigationController pushViewController:helpVC animated:YES];
    }
    [tv deselectRowAtIndexPath:indexPath animated:YES];
}

@end
