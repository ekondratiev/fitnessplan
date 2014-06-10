//
//  WorkoutButton.m
//  FitnessPlan2
//
//  Copyright 2010 ekondratiev.com. All rights reserved.
//

#import "WorkoutButton.h"
#import "Settings.h"
#import "Constants.h"


extern UIImage *buttonMasks[4];
extern UIImage *buttonColors[8];
extern UIImage *ast;

extern int buttonsView;
extern NSString *buttonsViewLabels[10];

@implementation WorkoutButton

@synthesize backImage;
@synthesize backImageP;
@synthesize workout;


+ (WorkoutButton *)createWithWorkout:(Workout *)workout
{
	THCalendarInfo *date = workout.wdate;
	
	//int shift = [FitnessPlanAppDelegate daytime:[date hour]];
	// XXX
	int shift = ([date hour] / 6) - 1;
	
	CGRect rect = CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
	//rect.origin.x = 30 + ((BUTTON_WIDTH +1) * shift);
	rect.origin.x = 28 + (BUTTON_WIDTH * shift);
	rect.origin.y = (([date dayOfMonth] - 1) * DAYSVIEW_LINE_HEIGHT) + DAYSVIEW_PADDING;
	
	WorkoutButton *wb = [[[WorkoutButton alloc]
                          initWithFrame:rect
                          workout:workout]
						 autorelease];
	return wb;
}

+ (WorkoutButton *)createWithWorkout:(Workout *)workout pos:(CGFloat)pos width:(int)width padding:(int)padding
{
	THCalendarInfo *date = workout.wdate;
	
	CGRect rect = CGRectMake(0, 0, width, (settings.bigButtons) ? BUTTON_HEIGHT_B : BUTTON_HEIGHT);
	rect.origin.x = 28 + ((int)pos);
	rect.origin.y = (([date dayOfMonth] - 1) * DAYSVIEW_LINE_HEIGHT) + DAYSVIEW_PADDING + padding;
	
	WorkoutButton *wb = [[[WorkoutButton alloc]
                          initWithFrame:rect
                          workout:workout]
						 autorelease];
	return wb;
}


- (id)initWithFrame:(CGRect)frame
{
    if((self = [super initWithFrame:frame]))
	{
        // Initialization code
        [super setBackgroundColor:[UIColor clearColor]];
        [self addTarget:self action:@selector(onTapEnd:) forControlEvents:UIControlEventTouchUpInside+UIControlEventTouchUpOutside];
        [self addTarget:self action:@selector(onTapBegin:) forControlEvents:UIControlEventTouchDown];
    }
	
    return self;
}

- (id)initWithFrame:(CGRect)frame workout:(Workout *)newWorkout
{
    if((self = [self initWithFrame:frame]))
	{
		self.workout = newWorkout;
		
		if(settings.futureInGray && [workout.wdate unixEpoch] > [THCalendarInfo currentUnixEpoch])
		{
			// XXX in future
			backImage = buttonColors[0]; // grey color for future
		}
		else
		{
			// XXX in past or no futureColor
			backImage = buttonColors[workout.color];
		}
    }
	
    return self;
}

- (void)onTapBegin:sender
{
    inButton = TRUE;
    [self setNeedsDisplay];
}

- (void)onTapEnd:sender
{
    inButton = FALSE;
    [self setNeedsDisplay];
}


- (NSString *)getWorkoutDataValue
{
    NSMutableString *s = [NSMutableString stringWithCapacity:20];
    
    double whole, mod;
    
    if(buttonsView == 1)
    {
        [s appendString:@"a1: "];
        if(workout.amount_1)
        {
            mod = modf(workout.amount_1, &whole);
            if(mod)
                [s appendFormat:@"%.2f", workout.amount_1];
            else
                [s appendFormat:@"%.0f", workout.amount_1];
        }
        else
            [s appendString:@"--"];
    }
    else if(buttonsView == 2)
    {
        [s appendString:@"a2: "];
        if(workout.amount_1)
        {
            mod = modf(workout.amount_2, &whole);
            if(mod)
                [s appendFormat:@"%.2f", workout.amount_2];
            else
                [s appendFormat:@"%.0f", workout.amount_2];
        }
        else
            [s appendString:@"--"];    
    }
    else if(buttonsView == 3)
    {
        [s appendString:@"a3: "];
        if(workout.amount_1)
        {
            mod = modf(workout.amount_3, &whole);
            if(mod)
                [s appendFormat:@"%.2f", workout.amount_3];
            else
                [s appendFormat:@"%.0f", workout.amount_3];
        }
        else
            [s appendString:@"--"];
    }
    else if(buttonsView == 4)
    {
        [s appendString:@"t1: "];
        if(workout.time_1)
        {
            [s appendFormat:@"%02d:%02d:%02d", workout.time_1 / 3600, (workout.time_1 % 3600) / 60, workout.time_1 % 60];
            showAst = NO;
        }
        else
            [s appendString:@"--"];
    }
    else if(buttonsView == 5)
    {
        [s appendString:@"t2: "];
        if(workout.time_2)
        {
            [s appendFormat:@"%02d:%02d:%02d", workout.time_2 / 3600, (workout.time_2 % 3600) / 60, workout.time_2 % 60];
            showAst = NO;
        }
        else
            [s appendString:@"--"];
    }
    else if(buttonsView == 6)
    {
        [s appendString:@"t3: "];
        if(workout.time_3)
        {
            [s appendFormat:@"%02d:%02d:%02d", workout.time_3 / 3600, (workout.time_3 % 3600) / 60, workout.time_3 % 60];
            showAst = NO;
        }
        else
            [s appendString:@"--"];
    }
    else if(buttonsView == 7)
    {
        [s appendString:@"hr: "];
        if(workout.hrate)
            [s appendFormat:@"%d", workout.hrate];
        else
            [s appendString:@"--"];
    }
    else if(buttonsView == 8)
    {
        [s appendString:@"w: "];
        if(workout.weight)
            [s appendFormat:@"%0.2f", workout.weight];
        else
            [s appendString:@"--"];
    }
    else if(buttonsView == 9)
    {
        if(settings.temperatureUnit)
            [s appendString:@"t\u00B0C: "];
        else
            [s appendString:@"t\u00B0F: "];
        if([workout hasWeather])
            [s appendFormat:@"%d", workout.weather_t];
        else
            [s appendString:@"--"];
    }
    return s;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    showAst = [workout hasNotes];
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	if(!inButton)
	{
		[buttonMasks[2] drawInRect:rect];
		[backImage drawInRect:rect];
	}
	else
	{
		[buttonMasks[2] drawInRect:rect];
		[backImage drawInRect:rect];
		[buttonMasks[1] drawInRect:rect];
		
		//CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
		//CGContextSetAlpha(context, 0.80);
		//CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
		//CGContextFillRect(context, rect);
	}
	
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	//CGContextSetRGBStrokeColor(context, 1, 1, 1, 1.0);
    CGContextSetRGBFillColor(context, 1, 1, 1, 1.0);
	CGContextSetShadow(context, CGSizeMake(0, 1), 1);
	CGContextSetAlpha(context, 1);
	
	NSMutableString *theLabel = [NSMutableString string];
    if(settings.bigButtons)
        [theLabel appendString:workout.name];
    else
    {
        if(buttonsView == 0)
            [theLabel appendString:workout.name];
        else
            [theLabel appendString:[self getWorkoutDataValue]];
        
    }
	
    UIFont *theFont = [UIFont boldSystemFontOfSize:12];
    CGSize textSize = [theLabel sizeWithFont:theFont
									forWidth:rect.size.width - 8
							   lineBreakMode:UILineBreakModeTailTruncation];
	
    CGRect labelRect = CGRectMake(6, 4, textSize.width, textSize.height);
    
    [theLabel drawInRect:labelRect withFont:theFont 
		   lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
	
	if(showAst)
	{
		[ast drawAtPoint:CGPointMake(rect.size.width - 13, 3)];
	}
    
    if(settings.bigButtons)
    {
        NSString *details = [self getWorkoutDataValue];
        
        UIFont *theFont2 = [UIFont systemFontOfSize:12];
        CGRect detRect = CGRectMake(6, 8 + textSize.height, rect.size.width - 6, textSize.height);
        [details drawInRect:detRect
                   withFont:theFont2
              lineBreakMode:UILineBreakModeTailTruncation
                  alignment:UITextAlignmentLeft];
        
        //CGContextStrokeRectWithWidth(context, CGRectMake(0,0, rect.size.width-1, rect.size.height-1), width);
    }
}

- (void)dealloc
{
	[workout release];
    [super dealloc];
}

@end
