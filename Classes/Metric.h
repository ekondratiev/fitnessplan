//
//  Metric.h
//  FitnessPlan
//
//  Created by Женя on 11.02.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#define METRIC_TYPE_VALUE 0
#define METRIC_TYPE_TIME 1

@interface Metric : NSObject
{
	long rowid;
	long wid;
	NSString *wname;
	long type;              // 1 - time, 0 - value
	NSString *mname;
	NSString *text;
}

@property (nonatomic, assign) long rowid;
@property (nonatomic, assign) long wid;
@property (nonatomic, copy) NSString *wname;
@property (nonatomic, assign) long type;
@property (nonatomic, copy) NSString *mname;
@property (nonatomic, copy) NSString *text;

@end
