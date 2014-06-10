//
//  TouchedScrollView.h
//  FitnessPlan
//
//  Created by Evgeny Kondratiev on 09.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TouchedScrollView : UIScrollView
{
	id target;
	SEL action;
}

- (void)setTouchEndedTarget:(id)newTarget action:(SEL)newAction;

@end
