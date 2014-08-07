//
//  ViewController.h
//  gom-client-objc
//
//  Created by Julian Krumow on 13.09.13.
//  Copyright (c) 2013 ART+COM AG. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GOMClient.h"
#import "GOMGnpHandler.h"
#import "ObserverViewController.h"

@interface ViewController : UIViewController <GOMGnpHandlerDelegate, ObserverViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *consoleView;
@property (weak, nonatomic) IBOutlet UIView *inputContainer;
@property (weak, nonatomic) IBOutlet UITextField *attributeField;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UIButton *observerButton;


- (IBAction)retrievePressed:(id)sender;
- (IBAction)createPressed:(id)sender;
- (IBAction)updatePressed:(id)sender;
- (IBAction)deletePressed:(id)sender;

- (IBAction)manageObservers:(id)sender;
@end
