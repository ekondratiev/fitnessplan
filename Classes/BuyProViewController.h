//
//  BuyProViewController.h
//  FitnessPlan
//
//  Created by Женя on 15.04.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>


@interface BuyProViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    IBOutlet UIButton *buyButton;
    UIView *waitingView;
    UIActivityIndicatorView *ai;
}

@property (nonatomic, retain) UIButton *buyButton;

- (IBAction)buyPro:(id)sender;

@end
