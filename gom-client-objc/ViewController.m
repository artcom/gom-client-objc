//
//  ViewController.m
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "ViewController.h"
#import "ObserverViewController.h"

@interface ViewController ()
{
    BOOL isSlidUp;
}
@property (nonatomic, strong) GOMClient *gomClient;
@property (nonatomic, strong) NSURL *gomRoot;
@property (nonatomic, strong) NSMutableDictionary *observers;


- (void)registerObservers;
- (void)removeObservers;
- (void)slideUp;
- (void)slideDown;
- (void)writeToConsole:(NSDictionary *)output;
- (void)resetTextfields;
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
    self.inputContainer.alpha = 0.5;
    self.inputContainer.userInteractionEnabled = NO;
    
    _observers = [[NSMutableDictionary alloc] init];
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
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.inputContainer.alpha = 1.0;
                     }
                     completion:^(BOOL isComplete) {
                         self.inputContainer.userInteractionEnabled = YES;
                     }
     ];
}

- (void)gomClient:(GOMClient *)gomClient didFailWithError:(NSError *)error
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.inputContainer.alpha = 0.5;
                     }
                     completion:^(BOOL isComplete){
                         self.inputContainer.userInteractionEnabled = NO;
                     }
     ];
    
    NSLog(@"GOMClient did fail with error:\n%@", error);
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
                         completion:^(BOOL isComplete) {
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
                         completion:^(BOOL isComplete) {
                             isSlidUp = NO;
                         }
         ];
    }
}

- (void)writeToConsole:(NSDictionary *)output
{
    NSString *text = [NSString stringWithFormat:@"%@\n\n%@", output.description, self.consoleView.text];
    self.consoleView.text = text;
    NSRange range = NSMakeRange(0, 1);
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
    [self.gomClient unregisterGOMObserverForPath:path options:nil];
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
        destViewController.gomClient = self.gomClient;
    }
}

- (IBAction)retrievePressed:(id)sender {
    [self resetTextfields];
    [self.gomClient retrieve:self.attributeField.text completionBlock:^(NSDictionary *response) {
        [self writeToConsole:response];
    }];
}

- (IBAction)createPressed:(id)sender {
    [self resetTextfields];
    [self.gomClient create:self.attributeField.text withAttributes:nil completionBlock:^(NSDictionary *response) {
        [self writeToConsole:response];
    }];
}

- (IBAction)updatePressed:(id)sender {
    [self resetTextfields];
    [self.gomClient updateAttribute:self.attributeField.text withValue:self.valueField.text completionBlock:^(NSDictionary *response) {
        [self writeToConsole:response];
    }];
}

- (IBAction)deletePressed:(id)sender {
    [self resetTextfields];
    [self.gomClient destroy:self.attributeField.text completionBlock:^(NSDictionary *response) {
        [self writeToConsole:response];
    }];
}

- (void)resetTextfields
{
    UITextField *textfield = nil;
    if (self.attributeField.isFirstResponder) {
        textfield = self.attributeField;
    } else if (self.valueField.isFirstResponder) {
        textfield = self.valueField;
    }
    [textfield resignFirstResponder];
    [self slideDown];
}

- (IBAction)manageObservers:(id)sender {
    
    [self resetTextfields];
}

@end
