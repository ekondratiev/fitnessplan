//
//  AboutView.m
//  FitnessPlan2
//
//  Created by Женя on 09.09.10.
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import "AboutView.h"
#import "Constants.h"


@implementation AboutView

@synthesize appNameLabel;


- (id) initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
	{
		iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fitnessplan-72.png"]];
		iconImage.frame = CGRectMake(205, 0, 72, 72);
		[self addSubview:iconImage];
		
		NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		
		CGFloat offset_h = 0;
		CGFloat offset_v = 0;
		
		UIFont *aFont;
		NSString *aString;
		CGSize aSize;
		UILabel *aLabel;
		
		aFont = [UIFont boldSystemFontOfSize:18];
		//aFont = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:20];
		aString = APP_NAME;
		aSize = [aString sizeWithFont:aFont];
		appNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(offset_h, offset_v, 200, aSize.height)];
		appNameLabel.font = aFont;
		appNameLabel.text = aString;
		[self addSubview:appNameLabel];
		[appNameLabel release];
		
		offset_v += aSize.height + 8;
		
		aFont = [UIFont systemFontOfSize:16];
		aString = [NSString stringWithFormat:@"%@ %@", APP_VERSION_LABEL, version];
		aSize = [aString sizeWithFont:aFont];
		aLabel = [[UILabel alloc] initWithFrame:CGRectMake(offset_h, offset_v, aSize.width, aSize.height)];
		aLabel.font = aFont;
		aLabel.text = aString;
		[self addSubview:aLabel];
		[aLabel release];
		
		offset_v += aSize.height + 8;
		
		aFont = [UIFont systemFontOfSize:14];
		aString = APP_COPY_LABEL;
		aSize = [aString sizeWithFont:aFont];
		aLabel = [[UILabel alloc] initWithFrame:CGRectMake(offset_h, offset_v, aSize.width, aSize.height)];
		aLabel.font = aFont;
		aLabel.text = aString;
		[self addSubview:aLabel];
		[aLabel release];
		
		offset_v += aSize.height + 2;
		
		aFont = [UIFont systemFontOfSize:14];
		aString = APP_AUTHOR;
		aSize = [aString sizeWithFont:aFont];
		aLabel = [[UILabel alloc] initWithFrame:CGRectMake(offset_h, offset_v, aSize.width, aSize.height)];
		aLabel.font = aFont;
		aLabel.text = aString;
		[self addSubview:aLabel];
		[aLabel release];
		
		offset_v += aSize.height + 2;
		
		aFont = [UIFont systemFontOfSize:14];
		aString = APP_CONTACT;
		aSize = [aString sizeWithFont:aFont];
		aLabel = [[UILabel alloc] initWithFrame:CGRectMake(offset_h, offset_v, aSize.width, aSize.height)];
		aLabel.font = aFont;
		aLabel.text = aString;
		[self addSubview:aLabel];
		[aLabel release];
		
		frame.size.height = offset_v + aSize.height + 2;
		self.frame = frame;
    }
    return self;
}

- (void) dealloc
{
	[iconImage release];
    [super dealloc];
}

@end
