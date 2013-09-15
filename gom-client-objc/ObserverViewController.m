//
//  ObserverViewController.m
//  gom-client-objc
//
//  Created by Julian Krumow on 14.09.13.
//  Copyright (c) 2013 ART+COM. All rights reserved.
//

#import "ObserverViewController.h"

@interface ObserverViewController ()
{
    BOOL isSlidUp;
}
@end

@implementation ObserverViewController
@synthesize observers = _observers;

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

- (void)setObservers:(NSMutableArray *)observers
{
    _observers = observers;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.observers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"observerCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"observerCell"];
    }
    
    cell.textLabel.text = self.observers[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UITableViewCellEditingStyleDelete) {
        NSString *path = [self.observers objectAtIndex:indexPath.row];
        [self.observers removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        
        if ([self.delegate respondsToSelector:@selector(observerViewController:didRemoveObserverWithPath:)]) {
            [self.delegate observerViewController:self didRemoveObserverWithPath:path];
        }
    }
}

#pragma - mark UI handling

- (void)slideUp
{
    if (isSlidUp == NO) {
        CGFloat height = 350.0;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            height = 500.0;
        }
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.bounds.size.height - height);
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
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.view.bounds.size.height - self.inputContainer.frame.size.height);
                             self.inputContainer.frame = CGRectMake(self.inputContainer.frame.origin.x, self.view.bounds.size.height - self.inputContainer.frame.size.height, self.inputContainer.frame.size.width, self.inputContainer.frame.size.height);
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

- (IBAction)addGomObserver:(id)sender {
    [self.observers addObject:self.observerPathField.text];
    [self.tableView reloadData];
    
    if ([self.delegate respondsToSelector:@selector(observerViewController:didAddObserverWithPath:)]) {
        [self.delegate observerViewController:self didAddObserverWithPath:self.observerPathField.text];
    }
}

@end
