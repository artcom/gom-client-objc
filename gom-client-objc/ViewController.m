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
    
    self.consoleView.frame = CGRectMake(self.consoleView.frame.origin.x, self.consoleView.frame.origin.y, self.consoleView.frame.size.width, self.view.bounds.size.height * 0.7);
    self.inputContainer.frame = CGRectMake(self.inputContainer.frame.origin.x, self.view.bounds.size.height * 0.7, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
    
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

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetGOMClient) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ManageObservers"]) {
        ObserverViewController *destViewController = segue.destinationViewController;
        destViewController.observers = self.observers;
        destViewController.delegate = self;
    }
}

#pragma mark - ObserverViewControllerDelegate

- (void)observerViewController:(ObserverViewController *)observerViewController didAddObserverWithPath:(NSString *)path
{
    [self.gomClient registerGOMObserverForPath:path options:nil completionBlock:^(NSDictionary *dict) {
        [self writeToConsole:dict];
    }];
}

- (void)observerViewController:(ObserverViewController *)observerViewController didRemoveObserverWithPath:(NSString *)path
{
    [self. gomClient unregisterGOMObserverForPath:path options:nil completionBlock:^(NSDictionary *dict){
        [self writeToConsole:dict];
    }];
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


#pragma mark - GOMClientDelegate

- (void)gomClientDidBecomeReady:(GOMClient *)gomClient
{
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
        CGFloat fraction = 0.4;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            fraction = 0.5;
        }
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.consoleView.frame = CGRectMake(self.consoleView.frame.origin.x, self.consoleView.frame.origin.y, self.consoleView.frame.size.width, self.view.bounds.size.height * fraction);
                             self.inputContainer.frame = CGRectMake(self.inputContainer.frame.origin.x, self.view.bounds.size.height * fraction, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
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
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.consoleView.frame = CGRectMake(self.consoleView.frame.origin.x, self.consoleView.frame.origin.y, self.consoleView.frame.size.width, self.view.bounds.size.height * 0.7);
                             self.inputContainer.frame = CGRectMake(self.inputContainer.frame.origin.x, self.view.bounds.size.height * 0.7, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             isSlidUp = NO;
                         }
         ];
    }
}

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

- (IBAction)sendToGOM:(id)sender
{
    
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
