//
//  ViewController.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import "ViewController.h"
#import "GOMObserver.h"

@interface ViewController ()
@property (nonatomic, strong) GOMObserver *gomClient;
@end

@implementation ViewController
@synthesize gomClient = _gomClient;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    _gomClient = [[GOMObserver alloc] init];
    
    [_gomClient reconnect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
