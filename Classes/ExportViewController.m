//
//  ExportViewController.m
//  FitnessPlan
//
//  Created by Женя on 21.04.11.
//  Copyright 2011 ekondratiev.com. All rights reserved.
//

#import "ExportViewController.h"
#import "FitnessPlanAppDelegate.h"
#import "Settings.h"


@implementation ExportViewController

- (id)init
{
    self = [super init];
    if(self)
    {
        self.navigationItem.title = NSLocalizedString(@"Export", nil);
        
        UIWebView *webView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)] autorelease];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.view = webView;
        
        q = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
	NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self
                                                                     selector:@selector(makeExportFile)
                                                                       object:nil];
	[q addOperation:op];
	[op release];
    
    //[self performSelectorInBackground:@selector(makeExportFile) withObject:nil];
    
    NSString *helpFile = [[NSBundle mainBundle] pathForResource:@"export" ofType:@"html"];
    [((UIWebView *)self.view) loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:helpFile]]];
}

- (void)dealloc
{
    [q release];
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


- (void)makeExportFile
{
    NSString *fileName;
    if(settings.isPro)
        fileName = [[NSBundle mainBundle] pathForResource:@"excel_template_pro" ofType:@"xml"];
    else
        fileName = [[NSBundle mainBundle] pathForResource:@"excel_template" ofType:@"xml"];
    
    NSString *template = [[NSString alloc] initWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableString *buf = [NSMutableString stringWithCapacity:2000];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    FitnessPlanAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSArray *items = [delegate allWorkoutsForPeriod:nil to:nil];
    for(Workout *w in items)
    {
        [buf appendString:@"<Row>\n"];
        [buf appendFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>\n", w.name];
        [buf appendFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>\n", [dateFormatter stringFromDate:[w.wdate date]]];
        
        if(settings.isPro)
        {
            [buf appendFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>\n", w.amount_name_1];
            [buf appendFormat:@"<Cell><Data ss:Type=\"Number\">%.3f</Data></Cell>\n", w.amount_1];
            [buf appendFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>\n", w.amount_name_2];
            [buf appendFormat:@"<Cell><Data ss:Type=\"Number\">%.3f</Data></Cell>\n", w.amount_2];
            [buf appendFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>\n", w.amount_name_3];
            [buf appendFormat:@"<Cell><Data ss:Type=\"Number\">%.3f</Data></Cell>\n", w.amount_3];
            
            [buf appendFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>\n", [FitnessPlanAppDelegate stringFromTimestamp:w.time_1]];
            [buf appendFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>\n", [FitnessPlanAppDelegate stringFromTimestamp:w.time_2]];
            [buf appendFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>\n", [FitnessPlanAppDelegate stringFromTimestamp:w.time_3]];
            
            [buf appendFormat:@"<Cell><Data ss:Type=\"Number\">%d</Data></Cell>\n", w.hrate];
            [buf appendFormat:@"<Cell><Data ss:Type=\"Number\">%.2f</Data></Cell>\n", w.weight];
            [buf appendFormat:@"<Cell><Data ss:Type=\"Number\">%d</Data></Cell>\n", w.feeling];
            if(w.weather_t != -9999)
                [buf appendFormat:@"<Cell><Data ss:Type=\"Number\">%d</Data></Cell>\n", w.weather_t];
            else
                [buf appendFormat:@"<Cell><Data ss:Type=\"Number\"></Data></Cell>\n"];
            if(w.weather_c != 0)
                [buf appendFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>\n", [settings.cloudinessList objectAtIndex:w.weather_c]];
            else
                [buf appendFormat:@"<Cell><Data ss:Type=\"String\"></Data></Cell>\n"];
        }
        else
        {
            [buf appendFormat:@"<Cell><Data ss:Type=\"Number\">%.3f</Data></Cell>\n", w.amount_1];
            [buf appendFormat:@"<Cell><Data ss:Type=\"Number\">%@</Data></Cell>\n", [FitnessPlanAppDelegate stringFromTimestamp:w.time_1]];
        }
        [buf appendFormat:@"<Cell><Data ss:Type=\"String\">%@</Data></Cell>\n", (w.notes) ? w.notes : @""];
        [buf appendString:@"</Row>\n"];
    }

    // clean up old files
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    NSError *error = nil;
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error])
    {
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, file] error:&error];
    }
    
    NSString *exportData = [template stringByReplacingOccurrencesOfString:@"__EXPORT_DATA__" withString:buf];
    NSString *exportFilePath = [documentsDirectory stringByAppendingPathComponent:@"fitnessplan3.xls"];
    [fileManager createFileAtPath:exportFilePath contents:[exportData dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    [dateFormatter release];
    [template release];
}

@end
