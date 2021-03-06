//
//  ObserverViewController.h
//  gom-client-objc
//
//  Created by Julian Krumow on 14.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GOMClient.h"

@protocol ObserverViewControllerDelegate;
@interface ObserverViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) id<ObserverViewControllerDelegate> delegate;
@property (weak, nonatomic) GOMClient *gomClient;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *observerPathField;
@property (weak, nonatomic) IBOutlet UIView *inputContainer;

- (IBAction)addGomObserver:(id)sender;
- (IBAction)done:(id)sender;

@end

@protocol ObserverViewControllerDelegate <NSObject>

- (void)observerViewController:(ObserverViewController *)observerViewController didAddObserverWithPath:(NSString *)path;
- (void)observerViewController:(ObserverViewController *)observerViewController didRemoveObserverWithPath:(NSString *)path;
- (void)didFinishManagingObservers:(ObserverViewController *)observerViewController;

@end