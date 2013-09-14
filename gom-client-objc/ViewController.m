//
//  ViewController.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    BOOL isSlidUp;
}
@property (nonatomic, strong) GOMClient *gomClient;
@property (nonatomic, strong) NSURL *gomRoot;
@property (nonatomic, strong) NSString *observerPath;
@end

@implementation ViewController
@synthesize gomClient = _gomClient;
@synthesize gomRoot = _gomRoot;
@synthesize observerPath = _observerPath;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.observerPath = @"/areas/home/audio:volume";
    self.attributeField.text = self.observerPath;
    self.attributeField.delegate = self;
    self.valueField.delegate = self;
    
    self.consoleView.frame = CGRectMake(self.consoleView.frame.origin.x, self.consoleView.frame.origin.y, self.consoleView.frame.size.width, self.view.bounds.size.height * 0.7);
    self.inputContainer.frame = CGRectMake(self.inputContainer.frame.origin.x, self.view.bounds.size.height * 0.7, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
    
    isSlidUp = NO;
    
    [self registerObservers];
    [self resetGOMClient];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self removeObservers];
}

- (void)dealloc
{
    [self removeObservers];
}

- (void)resetGOMClient
{
    self.attributeField.text = self.observerPath;
    self.valueField.text = @"";
    self.consoleView.text = @"";
    
    self.gomClient = nil;
    NSString *gomRootPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"gom_address_preference"];
    if (gomRootPath && [gomRootPath isEqualToString:@""] == NO) {
        self.gomRoot = [NSURL URLWithString:gomRootPath];
        _gomClient = [[GOMClient alloc] initWithGOMRoot:_gomRoot];
        self.gomClient.delegate = self;
    }
}

- (void)gomClientDidBecomeReady:(GOMClient *)gomClient
{
    [gomClient registerGOMObserverForPath:self.observerPath options:nil completionBlock:^(NSDictionary *dict) {
        
        CGPoint offset = self.consoleView.contentOffset;
        NSString *text = [NSString stringWithFormat:@"%@\n\n%@", self.consoleView.text, dict.description];
        self.consoleView.text = text;
        [self.consoleView setContentOffset:offset animated:NO];
        NSRange range = NSMakeRange(text.length, 1);
        [self.consoleView scrollRangeToVisible:range];
        self.valueField.text = dict[@"attribute"][@"value"];
    }];
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetGOMClient) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)slideUp
{
    CGFloat fraction = 0.4;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        fraction = 0.5;
    }
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.sendButton.alpha = 0.0;
                         self.consoleView.frame = CGRectMake(self.consoleView.frame.origin.x, self.consoleView.frame.origin.y, self.consoleView.frame.size.width, self.view.bounds.size.height * fraction);
                         self.inputContainer.frame = CGRectMake(self.inputContainer.frame.origin.x, self.view.bounds.size.height * fraction, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         isSlidUp = YES;
                         self.sendButton.enabled = NO;
                     }
     ];
}

- (void)slideDown
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.sendButton.alpha = 1.0;
                         self.consoleView.frame = CGRectMake(self.consoleView.frame.origin.x, self.consoleView.frame.origin.y, self.consoleView.frame.size.width, self.view.bounds.size.height * 0.7);
                         self.inputContainer.frame = CGRectMake(self.inputContainer.frame.origin.x, self.view.bounds.size.height * 0.7, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         isSlidUp = NO;
                         self.sendButton.enabled = YES;
                     }
     ];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (isSlidUp == NO) {
        [self slideUp];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (isSlidUp) {
        [self slideDown];
    }
    return NO;
}

- (IBAction)sendToGOM:(id)sender
{
    
}

@end
