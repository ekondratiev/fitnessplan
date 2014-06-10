//
//  AboutViewController.h
//  FitnessPlan2
//
//  Created by Женя on 09.09.10.
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutView.h"
#import "BuyProViewController.h"

@interface AboutViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	AboutView *aboutView;
	NSString *helpText;
}

@end
