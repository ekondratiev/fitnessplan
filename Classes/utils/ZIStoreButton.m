//
//  ZIStoreButton.m
//  ZIStoreButtonDemo
//
//  Created by Brandon Emrich on 7/20/10.
//  Copyright 2010 Zueos, Inc. All rights reserved.
//

/*
//	Copyright 2010 Brandon Emrich
//
//	Licensed under the Apache License, Version 2.0 (the "License");
//	you may not use this file except in compliance with the License.
//	You may obtain a copy of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
//	Unless required by applicable law or agreed to in writing, software
//	distributed under the License is distributed on an "AS IS" BASIS,
//	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	See the License for the specific language governing permissions and
//	limitations under the License.
*/

#import "ZIStoreButton.h"



@implementation ZIStoreButton

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // Initialization code
        inButton = NO;
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		self.autoresizesSubviews = YES;
		self.layer.needsDisplayOnBoundsChange = YES;
		
		[self setTitleShadowColor:[UIColor colorWithWhite:0.200 alpha:0.8] forState:UIControlStateNormal];
		[self setTitleShadowColor:[UIColor colorWithWhite:0.200 alpha:0.8] forState:UIControlStateSelected];
		[self.titleLabel setShadowOffset:CGSizeMake(0.0, -1)];
		[self.titleLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
		self.titleLabel.textColor = [UIColor colorWithWhite:0.902 alpha:1.000];
		
//		[self addTarget:self action:@selector(touchedUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
//		[self addTarget:self action:@selector(onTapEnd:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(onTapBegin:) forControlEvents:UIControlEventTouchDown];
		
		CAGradientLayer *bevelLayer2 = [CAGradientLayer layer];
		//bevelLayer2.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0.4 alpha:1.0] CGColor], [[UIColor whiteColor] CGColor], nil];
        bevelLayer2.colors = [NSArray arrayWithObjects:(id)[[UIColor darkGrayColor] CGColor], nil];
		bevelLayer2.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(frame), CGRectGetHeight(frame));
		bevelLayer2.cornerRadius = 5.0;
		bevelLayer2.needsDisplayOnBoundsChange = YES;
		
		CAGradientLayer *innerLayer2 = [CAGradientLayer layer];
		innerLayer2.colors = [NSArray arrayWithObjects:(id)[[UIColor darkGrayColor] CGColor], [[UIColor lightGrayColor] CGColor], nil];
		innerLayer2.frame = CGRectMake(0.5, 0.5, CGRectGetWidth(frame) - 1.0, CGRectGetHeight(frame) - 1.0);
		innerLayer2.cornerRadius = 4.6;
		innerLayer2.needsDisplayOnBoundsChange = YES;
		
        UIColor *green1		= [UIColor colorWithRed:0.48 green:0.61 blue:0.48 alpha:1.000];
        UIColor *green2		= [UIColor colorWithRed:0.38 green:0.53 blue:0.38 alpha:1.000];
        UIColor *green3	    = [UIColor colorWithRed:0.26 green:0.44 blue:0.26 alpha:1.000];
        UIColor *green4		= [UIColor colorWithRed:0.12 green:0.34 blue:0.12 alpha:1.000];
		
		normalColors  = [[NSArray arrayWithObjects:(id)green1.CGColor, green2.CGColor, green3.CGColor, green4.CGColor, nil] retain];
        
        green1		= [UIColor colorWithRed:0.41 green:0.48 blue:0.41 alpha:1.000];
        green2		= [UIColor colorWithRed:0.27 green:0.36 blue:0.27 alpha:1.000];
        green3	    = [UIColor colorWithRed:0.16 green:0.26 blue:0.16 alpha:1.000];
        green4		= [UIColor colorWithRed:0 green:0.12 blue:0 alpha:1.000];
		
		selectedColors  = [[NSArray arrayWithObjects:(id)green1.CGColor, green2.CGColor, green3.CGColor, green4.CGColor, nil] retain];
		
		innerLayer3 = [CAGradientLayer layer];
		innerLayer3.colors = normalColors;
		innerLayer3.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.200], [NSNumber numberWithFloat:0.400], [NSNumber numberWithFloat:0.500], nil];		
		innerLayer3.frame = CGRectMake(0.75, 0.75, CGRectGetWidth(frame) - 1.5, CGRectGetHeight(frame) - 1.5);
		innerLayer3.cornerRadius = 4.5;
		innerLayer3.needsDisplayOnBoundsChange = YES;
		
		[self.layer addSublayer:bevelLayer2];
		[self.layer addSublayer:innerLayer2];
		[self.layer addSublayer:innerLayer3];
		
		[self bringSubviewToFront:self.titleLabel];
		
    }
    return self;
}


- (void)setTitleFont:(UIFont *)font
{
    self.titleLabel.font = font;
}


- (void) update
{	
	[CATransaction begin];
	[CATransaction setAnimationDuration:0.2];

	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"colors"];
    
    animation.fromValue = (!inButton) ? normalColors : selectedColors;
	animation.toValue = (inButton) ? normalColors : selectedColors;

	animation.duration = 0.2;
	animation.removedOnCompletion = NO;
	animation.fillMode = kCAFillModeForwards;
	animation.delegate = self;
	
	[innerLayer3 layoutIfNeeded];
	[innerLayer3 addAnimation:animation forKey:@"changeToDark"];

	//for (CALayer *la in self.layer.sublayers)
	//	[la layoutIfNeeded];
	
	[CATransaction commit];
}


- (void)onTapBegin:sender
{
    inButton = TRUE;
    [self update];
}


- (void)onTapEnd:sender
{
    //inButton = FALSE;
    //[self update];
}


- (void)dealloc
{
    [normalColors release];
    [selectedColors release];
    [super dealloc];
}


@end
