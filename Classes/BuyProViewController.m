//
//  BuyProViewController.m
//  FitnessPlan
//
//  Created by Женя on 15.04.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import "BuyProViewController.h"
#import "UIAlertView+Helper.h"
#import "Constants.h"
#import "Settings.h"
#import "FitnessPlanAppDelegate.h"
#import "ZIStoreButton.h"


@implementation BuyProViewController

@synthesize buyButton;

- (id)init
{
    self = [super initWithNibName:@"BuyProView" bundle:nil];
    if (self)
    {
        // Custom initialization
        
        // notification view
        
        waitingView = [[UIView alloc] initWithFrame:CGRectMake(40, 100, 240, 150)];
        waitingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [waitingView.layer setCornerRadius:10];
        [waitingView.layer setShadowColor:[[UIColor blackColor] CGColor]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 220, 100)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:18];
        label.text = NSLocalizedString(@"AccessingItunes", nil);
        label.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
        label.shadowOffset = CGSizeMake(1, 2);
        [waitingView addSubview:label];
        [label release];
        
        ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGSize sz = ai.frame.size;
        ai.frame = CGRectMake((240 - sz.width) / 2, 100, sz.width, sz.height);
        [waitingView addSubview:ai];
        
        [buyButton removeFromSuperview];
        
        ZIStoreButton *b = [[ZIStoreButton alloc] initWithFrame:CGRectMake(20, 359, 280, 37)];
        [b setTitle:NSLocalizedString(@"BuyProPrice", nil) forState:UIControlStateNormal];
        [b setTitleFont:[UIFont boldSystemFontOfSize:18]];
        [b addTarget:self action:@selector(buyPro:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:b];
        [b release];
    
        self.navigationItem.title = NSLocalizedString(@"BuyPro", nil);
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.png"]];
    }
    return self;
}


- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)goPro
{
    settings.isPro = YES;
    FitnessPlanAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate saveUserDefaults];

    [buyButton removeFromSuperview];
    // XXX change text
    //[self.navigationController popViewControllerAnimated:YES];
}


- (void)requestProductData
{
    self.navigationItem.hidesBackButton = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    buyButton.enabled = NO;
    [self.view addSubview:waitingView];
    [ai startAnimating];
    
    SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kProFeatureIdentifier]];
    request.delegate = self;
    [request start];
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    //NSArray *myProduct = response.products;
    
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:kProFeatureIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    [request autorelease];
    
    [waitingView removeFromSuperview];
    [ai stopAnimating];
}


- (IBAction)buyPro:(id)sender
{
    if([SKPaymentQueue canMakePayments])
    {
        [self requestProductData];
    }
    else
    {
        UIAlertViewQuick(NSLocalizedString(@"StoreKit", nil),
                         NSLocalizedString(@"StoreNotAccesible", nil),
                         NSLocalizedString(@"Dismiss", nil));
    }
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    [self goPro];
    
    // Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self goPro];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


#pragma mark -
#pragma mark Handling Transactions

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    self.navigationItem.hidesBackButton = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    buyButton.enabled = YES;

    for(SKPaymentTransaction *transaction in transactions)
    {
        switch(transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction]; 
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
        }
    }
}


@end
