//
//  AboutView.h
//  FitnessPlan2
//
//  Created by Женя on 09.09.10.
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AboutView : UIView
{
	UIImageView *iconImage;
    UILabel *appNameLabel;
}

@property (nonatomic, readonly) UILabel *appNameLabel;

@end