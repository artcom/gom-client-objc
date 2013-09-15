//
//  ViewController.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import "ViewController.h"
#import "ObserverViewController.h"

@interface ViewController ()
{
    BOOL isSlidUp;
}
@property (nonatomic, strong) GOMClient *gomClient;
@property (nonatomic, strong) NSURL *gomRoot;
@property (nonatomic, strong) NSMutableArray *observers;
@end

@implementation ViewController
@synthesize gomClient = _gomClient;
@synthesize gomRoot = _gomRoot;
@synthesize observers = _observers;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.attributeField.delegate = self;
    self.valueField.delegate = self;
    
    isSlidUp = NO;
    
    _observers = [[NSMutableArray alloc] init];
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

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetGOMClient) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

#pragma mark - GOMClient

- (void)resetGOMClient
{
    self.attributeField.text = @"";
    self.valueField.text = @"";
    self.consoleView.text = @"";
    
    self.gomClient = nil;
    NSString *gomRootPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"gom_address_preference"];
    if (gomRootPath && [gomRootPath isEqualToString:@""] == NO) {
        self.gomRoot = [NSURL URLWithString:gomRootPath];
        _gomClient = [[GOMClient alloc] initWithGomURI:_gomRoot];
        self.gomClient.delegate = self;
    }
}

#pragma mark - GOMClientDelegate

- (void)gomClientDidBecomeReady:(GOMClient *)gomClient
{
    NSLog(@"GOMClient did become ready");
}

- (void)gomClient:(GOMClient *)gomClient didFailWithError:(NSError *)error
{
    NSLog(@"GOMClient setup did fail with error:\n%@", error);
    self.gomClient = nil;
}

#pragma - mark UI handling

- (void)slideUp
{
    if (isSlidUp == NO) {
        CGFloat height = 350.0;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            height = 400.0;
        }
        [UIView animateWithDuration:0.4
                         animations:^{
                             self.consoleView.frame = CGRectMake(self.consoleView.frame.origin.x, self.consoleView.frame.origin.y, self.consoleView.frame.size.width, self.view.bounds.size.height - height);
                             self.inputContainer.frame = CGRectMake(self.inputContainer.frame.origin.x, self.view.bounds.size.height - height, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             isSlidUp = YES;
                         }
         ];
    }
}

- (void)slideDown
{
    if (isSlidUp) {
        [UIView animateWithDuration:0.4
                         animations:^{
                             self.consoleView.frame = CGRectMake(self.consoleView.frame.origin.x, self.consoleView.frame.origin.y, self.consoleView.frame.size.width, self.view.bounds.size.height - self.inputContainer.frame.size.height);
                             self.inputContainer.frame = CGRectMake(self.inputContainer.frame.origin.x, self.view.bounds.size.height - self.inputContainer.frame.size.height, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             isSlidUp = NO;
                         }
         ];
    }
}

- (void)writeToConsole:(NSDictionary *)output
{
    CGPoint offset = self.consoleView.contentOffset;
    NSString *text = [NSString stringWithFormat:@"%@\n\n%@", self.consoleView.text, output.description];
    self.consoleView.text = text;
    [self.consoleView setContentOffset:offset animated:NO];
    NSRange range = NSMakeRange(text.length, 1);
    [self.consoleView scrollRangeToVisible:range];
}

#pragma mark - UITextFielDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self slideUp];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self slideDown];
    return YES;
}

#pragma mark - ObserverViewControllerDelegate

- (void)observerViewController:(ObserverViewController *)observerViewController didAddObserverWithPath:(NSString *)path
{
    [self.gomClient registerGOMObserverForPath:path options:nil clientCallback:^(NSDictionary *dict) {
        [self writeToConsole:dict];
    }];
}

- (void)observerViewController:(ObserverViewController *)observerViewController didRemoveObserverWithPath:(NSString *)path
{
    [self. gomClient unregisterGOMObserverForPath:path options:nil];
}

- (void)didFinishManagingObservers:(ObserverViewController *)observerViewController
{
    [observerViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ManageObservers"]) {
        ObserverViewController *destViewController = segue.destinationViewController;
        destViewController.observers = self.observers;
        destViewController.delegate = self;
    }
}



- (IBAction)retrievePressed:(id)sender {
    
}

- (IBAction)createPressed:(id)sender {
}

- (IBAction)updatePressed:(id)sender {
}

- (IBAction)deletePressed:(id)sender {
}

- (IBAction)manageObservers:(id)sender {
    UITextField *textfield = nil;
    if (self.attributeField.isFirstResponder) {
        textfield = self.attributeField;
    } else if (self.valueField.isFirstResponder) {
        textfield = self.valueField;
    }
    [textfield resignFirstResponder];
    [self slideDown];
    
    
}

@end
