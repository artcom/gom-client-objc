//
//  ViewController.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) GOMClient *gomClient;
@end

@implementation ViewController
@synthesize gomClient = _gomClient;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //NSURL *url = [NSURL URLWithString:@"172.40.2.20"];
    NSURL *url = [NSURL URLWithString:@"http://gom.staging.t-gallery"];
    _gomClient = [[GOMClient alloc] initWithGOMRoot:url];
    _gomClient.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gomClientDidBecomeReady:(GOMClient *)gomClient
{
    [_gomClient registerGOMObserverForPath:@"/areas/home/audio:volume" options:nil completionBlock:^(NSDictionary *dict) {
        NSString *text = [NSString stringWithFormat:@"%@\n\n%@", dict.description, self.consoleView.text];
        self.consoleView.text = text;
    }];
}

@end
