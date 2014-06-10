//
//  HelpViewController.h
//  FitnessPlan
//
//  Created by Женя on 13.04.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HelpViewController : UIViewController
{
    UIWebView *webView;
}

- (void)gotoAnchor:(NSString *)name;

@end
