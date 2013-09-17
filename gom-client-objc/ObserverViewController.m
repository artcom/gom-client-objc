//
//  ObserverViewController.m
//  gom-client-objc
//
//  Created by Julian Krumow on 14.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import "ObserverViewController.h"

@interface ObserverViewController ()
{
    BOOL isSlidUp;
}

- (void)slideUp;
- (void)slideDown;
@end

@implementation ObserverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.observerPathField.delegate = self;
    isSlidUp = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setGomClient:(GOMClient *)gomClient
{
    _gomClient = gomClient;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.gomClient.bindings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"observerCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"observerCell"];
    }
    
    GOMBinding *binding = self.gomClient.bindings.allValues[indexPath.row];
    NSString *path = binding.subscriptionUri;
    
    cell.textLabel.text = path;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)binding.handles.count];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete) {
        GOMBinding *binding = [self.gomClient.bindings.allValues objectAtIndex:indexPath.row];
        if ([self.delegate respondsToSelector:@selector(observerViewController:didRemoveObserverWithPath:)]) {
            [self.delegate observerViewController:self didRemoveObserverWithPath:binding.subscriptionUri];
        }
        [self.tableView reloadData];
    }
}

#pragma mark - UITextFieldDelegate

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

#pragma - mark UI handling

- (void)slideUp
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (isSlidUp == NO) {
            CGFloat height = 350.0;
            [UIView animateWithDuration:0.25
                             animations:^{
                                 self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.bounds.size.height - height);
                                 self.inputContainer.frame = CGRectMake(self.inputContainer.frame.origin.x, self.view.bounds.size.height - height, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
                             }
                             completion:^(BOOL isComplete) {
                                 isSlidUp = YES;
                             }
             ];
        }
    }
}

- (void)slideDown
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        if (isSlidUp) {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.bounds.size.height - self.inputContainer.frame.size.height);
                                 self.inputContainer.frame = CGRectMake(self.inputContainer.frame.origin.x, self.view.bounds.size.height - self.inputContainer.frame.size.height, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
                             }
                             completion:^(BOOL isComplete) {
                                 isSlidUp = NO;
                             }
             ];
        }
    }
}

- (IBAction)addGomObserver:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(observerViewController:didAddObserverWithPath:)]) {
        [self.delegate observerViewController:self didAddObserverWithPath:self.observerPathField.text];
    }
    [self.tableView reloadData];
}

- (IBAction)done:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didFinishManagingObservers:)]) {
        [self.delegate didFinishManagingObservers:self];
    }
}

@end
