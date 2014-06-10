//
//  ExportViewController.h
//  FitnessPlan
//
//  Created by Женя on 21.04.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ExportViewController : UIViewController
{
    NSOperationQueue *q;
}

- (void)makeExportFile;

@end
