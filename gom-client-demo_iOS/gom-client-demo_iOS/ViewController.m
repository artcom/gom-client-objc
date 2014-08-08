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
@property (nonatomic, strong) NSURL *gomRoot;
@property (nonatomic, strong) GOMClient *gomClient;
@property (nonatomic, strong) GOMObserver *gomObserver;

- (void)registerObservers;
- (void)removeObservers;
- (void)slideUp;
- (void)slideDown;
- (void)writeToConsole:(id)object error:(NSError *)error;
- (void)resetTextfields;

- (void)resetGOMClient;
- (void)setupGomObserver;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.attributeField.delegate = self;
    self.valueField.delegate = self;
    
    isSlidUp = NO;
    self.inputContainer.alpha = 0.5;
    self.inputContainer.userInteractionEnabled = NO;
    
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
    }
    
    [self setupGomObserver];
}

- (void)setupGomObserver
{
    NSString *websocketProxyPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"websocket_proxy_path_preference"];
    if (websocketProxyPath == nil) {
        return;
    }
    __block NSURL *webSocketUri = nil;
    [self.gomClient retrieveAttribute:websocketProxyPath completionBlock:^(GOMAttribute *attribute, NSError *error) {
        if (attribute) {
            webSocketUri = [NSURL URLWithString:attribute.value];
            self.gomObserver = [[GOMObserver alloc] initWithWebsocketUri:webSocketUri delegate:self];
        }
    }];
    
}

#pragma mark - GOMObserverDelegate

- (void)gomObserverDidBecomeReady:(GOMObserver *)gomObserver
{
    NSLog(@"GOMObserver did become ready");
    
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.inputContainer.alpha = 1.0;
                     }
                     completion:^(BOOL isComplete) {
                         self.inputContainer.userInteractionEnabled = YES;
                     }
     ];
}

- (void)gomObserver:(GOMObserver *)gomObserver didFailWithError:(NSError *)error
{
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.inputContainer.alpha = 0.5;
                     }
                     completion:^(BOOL isComplete){
                         self.inputContainer.userInteractionEnabled = NO;
                     }
     ];
    
    NSLog(@"GOMObserver did fail with error:\n%@", error);
    self.gomObserver = nil;
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

- (void)writeToConsole:(id)object error:(NSError *)error
{
    NSString *output = nil;
    
    if (object == nil) {
        output = error.description;
    } else {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dictionary = object;
            output = dictionary.description;
        } else if ([object isKindOfClass:[GOMGnp class]]) {
            GOMGnp *gnp = object;
            output = gnp.debugDescription;
        } else if ([object isKindOfClass:[GOMAttribute class]]) {
            GOMAttribute *attribute = object;
            output = attribute.debugDescription;
        } else if ([object isKindOfClass:[GOMNode class]]) {
            GOMNode *node = object;
            output = node.debugDescription;
        }
    }
    NSLog(@"%@", output);
    
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
    [self.gomObserver registerGOMObserverForPath:path clientCallback:^(GOMGnp *dict) {
        [self writeToConsole:dict error:nil];
    }];
}

- (void)observerViewController:(ObserverViewController *)observerViewController didRemoveObserverWithPath:(NSString *)path
{
    [self.gomObserver unregisterGOMObserverForPath:path];
}

- (void)didFinishManagingObservers:(ObserverViewController *)observerViewController
{
    [observerViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ManageObservers"]) {
        ObserverViewController *destViewController = segue.destinationViewController;
        destViewController.delegate = self;
        destViewController.gomObserver = self.gomObserver;
    }
}

- (IBAction)retrievePressed:(id)sender {
    [self resetTextfields];
    NSString *enteredText = self.attributeField.text;
    if ([enteredText rangeOfString:@":"].location == NSNotFound) {
        [self.gomClient retrieveNode:self.attributeField.text completionBlock:^(GOMNode *node, NSError *error) {
            [self writeToConsole:(GOMEntry *)node error:error];
        }];
    } else {
        [self.gomClient retrieveAttribute:self.attributeField.text completionBlock:^(GOMAttribute *attribute, NSError *error) {
            [self writeToConsole:(GOMEntry *)attribute error:error];
        }];
    }
}

- (IBAction)createPressed:(id)sender {
    [self resetTextfields];
    [self.gomClient create:self.attributeField.text withAttributes:nil completionBlock:^(NSDictionary *response, NSError *error) {
        [self writeToConsole:response error:error];
    }];
}

- (IBAction)updatePressed:(id)sender {
    [self resetTextfields];
    [self.gomClient updateAttribute:self.attributeField.text withValue:self.valueField.text completionBlock:^(NSDictionary *response, NSError *error) {
        [self writeToConsole:response error:error];
    }];
}

- (IBAction)deletePressed:(id)sender {
    [self resetTextfields];
    [self.gomClient destroy:self.attributeField.text completionBlock:^(NSDictionary *response, NSError *error) {
        [self writeToConsole:response error:error];
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
