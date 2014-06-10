//
//  HelpViewController.m
//  FitnessPlan
//
//  Created by Женя on 13.04.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import "HelpViewController.h"


@implementation HelpViewController

- (id)init
{
    if((self = [super init]))
    {
        self.navigationItem.title = NSLocalizedString(@"Manual", nil);
        
        webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)] autorelease];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        NSString *helpFile = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:helpFile]]];
        
        self.view = webView;
    }
    return self;
}


- (void)gotoAnchor:(NSString *)name
{
    NSString *helpFile = [[NSBundle mainBundle] pathForResource:@"help" ofType:@"html"];
    NSURL *baseURL = [NSURL fileURLWithPath:helpFile];
    NSURL *anchorURL = [NSURL URLWithString:name relativeToURL:baseURL];
    
    [webView loadRequest:[NSURLRequest requestWithURL:anchorURL]];
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

@end
