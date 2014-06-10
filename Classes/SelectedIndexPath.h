//
//  SelectedIndexPath.h
//  FitnessPlan
//
//  Created by Женя on 20.04.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SelectedIndexPath : NSObject
{
    int row;
    int section;
}

@property (nonatomic, assign) int row;
@property (nonatomic, assign) int section;

@end
