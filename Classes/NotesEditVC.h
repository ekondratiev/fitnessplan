//
//  TextFieldEditVC.h
//  FitPlan
//
//  Created by Evgeny Kondratiev on 20.12.08.
//  Copyright 2008 Kondratiev. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NotesEditVC : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	UITableView *tableView;
	UITextView *textView;
	//NSString *text;
	id target;
	SEL action;
}

//@property (nonatomic, retain) NSString *text;

- (void) setTarget:(id)aTarget action:(SEL)anAction;
- (void) setText:(NSString *)newText;

@end