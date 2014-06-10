//
//  TouchedScrollView.m
//  FitnessPlan
//
//  Created by Evgeny Kondratiev on 09.02.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TouchedScrollView.h"


@implementation TouchedScrollView

- (void)setTouchEndedTarget:(id)newTarget action:(SEL)newAction
{
	target = newTarget;
	action = newAction;
}

-(void) touchesEnded: (NSSet *) touches withEvent: (UIEvent *) event 
{
	[super touchesEnded: touches withEvent: event];
	
	if(!self.dragging)
	{
		UITouch *touch = [touches anyObject];
		UIView *view = touch.view;
		if(view.tag == 5432)
		{
			CGPoint p = [touch locationInView:view]; 
			if(target != nil)
				[target performSelector:action withObject:[NSValue valueWithCGPoint:p]];
		}
		
		[self.nextResponder touchesEnded:touches withEvent:event]; 
	}
}

@end
